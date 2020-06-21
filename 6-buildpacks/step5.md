# From polling to pushing

Objective:
As mentioned before, kpack will by default, poll the source code repo for commits every 5 minutes, and automatically re-build the image if it detects a new commit.

This means kpack is not a sequential part of the build pipeline like Kaniko or the Tekton Buildpack Task.
This is fine, as long as you always wish to build an image regardless of linting and testing feedback.

In this step, you will:
- Make kpack builds conditional on linting and testing feedback, using a push instead of a poll model

## Update the build pipeline to trigger kpack

We can trigger kpack at the end of the build pipeline by updating the `Image` resource.
The kpack controller tracks all `Image` resources in the cluster.
If the Git revision of an `Image` were to change, the controller will automatically kick off a build and push.

First of all we need to get remove the two existing image related tasks from the build pipeline.

```
cd ../tekton
yq d build-pipeline.yaml "spec.tasks.(name==verify-digest)"
yq d build-pipeline.yaml "spec.tasks.(name==build-image)"
```{{execute}}

You can now create a `Task` responsible for updating the `Image` file with the new revision.
This `Task` is very similar to the one we created for promoting newly pushed images to the dev environment in the triggers [triggers](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/5-manage-triggers) scenarios.

```
cat <<EOF >update-image-revision-task.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: update-image-revision
spec:
  workspaces:
    - name: source
  params:
    - name: GITHUB_TOKEN_SECRET
      type: string
      description: Name of the secret holding the github-token.
      default: github-token
    - name: GITHUB_TOKEN_SECRET_KEY
      type: string
      description: Name of the secret key holding the github-token.
      default: GITHUB_TOKEN
    - name: REVISION
      type: string
      description: The source code repository's Git revision to build with kpack.
EOF
```{{execute}}

You can now add two steps.
The first step modifies the `Image` with the new revision.

```
cat <<EOF >>update-image-revision-task.yaml
  steps:
  - name: update-revision
    image: mikefarah/yq
    workingDir: \$(workspaces.source.path)
    script: |
        cd kpack
        yq w -i image.yaml "spec.source.git.revision" "\$(GIT_COMMIT)"
EOF
```{{execute}}

And the second step commits the changes.

```
cat <<EOF >>update-image-revision-task.yaml
  - name: git-commit
    image: gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:v0.12.1
    workingDir: \$(workspaces.source.path)
    script: |
      git remote set-url origin https://${GITHUB_USER}:\${GITHUB_TOKEN}@github.com/${GITHUB_NS}/go-sample-app-ops.git
      git config user.name build-bot
      git config user.email build-bot@bots.bot
      git checkout -b temp-branch
      git add kpack/image.yaml
      git commit -m "Setting revision to current source code repo commit to trigger kpack"
      git checkout master
      git merge temp-branch
      git push origin master
    env:
      - name: GITHUB_TOKEN
        valueFrom:
          secretKeyRef:
            name: \$(params.GITHUB_TOKEN_SECRET)
            key: \$(params.GITHUB_TOKEN_SECRET_KEY)
EOF
```{{execute}}

Take a look at the entire `Task`, and apply it to the cluster.

```
yq r -C update-image-revision-task.yaml
kubectl apply -f update-image-revision-task.yaml
```{{execute}}

## Turn off polling

You can now turn off the automatic polling, by changing the `updatePolicy` to `external`.

```
yq m -i builder.yaml - <<EOF
spec:
  updatePolicy: external
EOF
```{{execute}}
