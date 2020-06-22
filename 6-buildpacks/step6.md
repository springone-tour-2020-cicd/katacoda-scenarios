# From polling to pushing

Objective:
As mentioned before, kpack will by default, poll the source code repo for commits every 5 minutes, and automatically re-build the image if it detects a new commit.

This means kpack is not a sequential part of the build pipeline like Kaniko or the Tekton Buildpack Task.
This is fine, as long as you always wish to build an image regardless of linting and testing feedback.

In this step, you will:
- Make kpack builds conditional on linting and testing feedback, using a push instead of a poll model

We can trigger kpack at the end of the build pipeline by updating the `Image` resource.
The kpack controller tracks all `Image` resources in the cluster.
If the Git revision of an `Image` were to change, the controller will automatically kick off a build and push.

## Change the Git revision in a new Task

Create the `Task` responsible for updating the `Image` file with the new revision.
This `Task` is very similar to the one we created for promoting newly pushed images to the dev environment in the triggers [triggers](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/5-manage-triggers) scenarios.

```
cd ../tekton
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
        cd cicd/kpack
        yq w -i image.yaml "spec.source.git.revision" "\$(params.REVISION)"
EOF
```{{execute}}

And the second step commits the changes.

```
cat <<EOF >>update-image-revision-task.yaml
  - name: git-commit
    image: gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:v0.12.1
    workingDir: \$(workspaces.source.path)
    script: |
      apk add tree
      tree
      git remote set-url origin https://${GITHUB_USER}:\${GITHUB_TOKEN}@github.com/${GITHUB_NS}/go-sample-app-ops.git
      git config user.name build-bot
      git config user.email build-bot@bots.bot
      git checkout -b temp-branch
      git add cicd/kpack/image.yaml
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

## Update the build pipeline

We can now use this newly created `Task` to trigger kpack.

First of all we need to remove the two existing image related tasks from the build pipeline, as well as the image resource.

```
yq d -i build-pipeline.yaml "spec.tasks.(name==verify-digest)"
yq d -i build-pipeline.yaml "spec.tasks.(name==build-image)"
yq d -i build-pipeline.yaml "spec.resources"
```{{execute}}

The `Image` manifest is now part of the ops repository, instead of the source code repository.
You'll need to clone this repository as well to make any changes to it.

```
yq m -i -a build-pipeline.yaml - <<EOF
spec:
  tasks:
    - name: fetch-ops-repository
      runAfter:
        - fetch-repository
        - lint
        - test
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: shared-ops-workspace
      params:
        - name: url
          value: https://github.com/${GITHUB_NS}/go-sample-app-ops.git
        - name: revision
          value: master
        - name: deleteExisting
          value: "true"
EOF
```{{execute}}

As you can see the `fetch-ops-repository` task is now using a different workspace.
Make sure to add the new workspace to the list of workspaces for the pipeline.

```
yq m -i -a build-pipeline.yaml - <<EOF
spec:
  workspaces:
    - name: shared-ops-workspace
      description: This workspace will receive the cloned Git ops repo and be passed to the next Task.
EOF
```{{execute}}

Next, you'll need to reference the new `update-image-revision` `Task`, and add another git-clone before it.

```
yq m -i -a build-pipeline.yaml - <<EOF
spec:
  tasks:
    - name: update-image-revision
      taskRef:
        name: update-image-revision
      runAfter:
        - fetch-repository
        - lint
        - test
        - fetch-ops-repository
      workspaces:
        - name: source
          workspace: shared-ops-workspace
      params:
        - name: GITHUB_TOKEN_SECRET
          value: \$(params.github-token-secret)
        - name: GITHUB_TOKEN_SECRET_KEY
          value: \$(params.github-token-secret-key)
        - name: REVISION
          value: \$(params.revision)
EOF
```{{execute}}

Don't forget to add the new parameters to the pipeline.

```
yq m -i -a build-pipeline.yaml - <<EOF
spec:
  params:
    - name: github-token-secret
      type: string
      description: Name of the secret holding the github-token.
    - name: github-token-secret-key
      description: Name of the secret key holding the github-token.
EOF
```{{execute}}

And you can also remove the image parameter, as that will be generated by kpack.

```
yq d -i build-pipeline.yaml "spec.params.(name==image)"
```{{execute}}

Take a look at the entire `Pipeline`.

```
yq r -C build-pipeline.yaml
```{{execute}}

## Update the trigger

Changing the pipeline of course also means you have to update the `TriggerTemplate`.

Start by adding the missing parameters.

```
yq d -i build-trigger-template.yaml "spec.resourcetemplates[0].spec.params"
yq m -i build-trigger-template.yaml - <<EOF
spec:
  resourcetemplates:
    - spec:
        params:
          - name: repo-url
            value: \$(params.REPO_URL)
          - name: revision
            value: \$(params.REVISION)
          - name: github-token-secret
            value: github-token
          - name: github-token-secret-key
            value: GITHUB_TOKEN
EOF
```{{execute}}

The new workspace also needs to be assigned a `PersistentVolumeClaim` in the `TriggerTemplate`.

```
yq m -i build-trigger-template.yaml - <<EOF
spec:
  resourcetemplates:
    - spec:
        workspaces:
          - name: shared-workspace
            persistentvolumeclaim:
              claimName: workspace-pvc
          - name: shared-ops-workspace
            persistentvolumeclaim:
              claimName: workspace-pvc
EOF
```{{execute}}

And also remove the unused `IMAGE` parameter from the `TriggerTemplate`.

```
yq d -i build-trigger-template.yaml "spec.params.(name==IMAGE)"
```{{execute}}

Take a look at the entire `TriggerTemplate`.

```
yq r -C build-trigger-template.yaml
```{{execute}}

Finally also get rid of the `IMAGE` parameter from the `TriggerBinding` as well.

```
yq d -i build-trigger-template.yaml "spec.params.(name==IMAGE)"
```{{execute}}

Go ahead and apply the resources to the cluster.

```
kubectl apply -f .
```{{execute}}

## Turn off polling

You can now turn off the automatic polling, by changing the `updatePolicy` to `external`.

```
cd ../kpack
yq m -i builder.yaml - <<EOF
spec:
  updatePolicy: external
EOF
```{{execute}}

Go ahead and apply the `Builder` to the cluster as well.

```
kubectl apply -f builder.yaml
```{{execute}}

## Using Argo CD to trigger kpack

If you would now trigger the build pipeline, the `Image` file will be modified with a new revision in Git.
For now, you'd have to apply the new `Image` modification to the cluster manually, or have another `Task` in the pipeline that does this.

We can however use Argo CD for this as well.
Argo CD should pick up the changed manifest and apply it to the cluster automatically.

Instruct Argo CD to automatically keep our CI/CD pipeline, including the updated `Image` from the previous step, in sync with the cluster.
For this you can add two Argo CD `Application` resources.

The first one will track changes in kpack manifests, including the `Image` resource.

```
cd ../argo
cat <<EOF >argo-deploy-image.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: go-sample-app-image
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  project: default
  source:
    path: cicd/kpack
    repoURL: https://github.com/andreasevers/go-sample-app-ops.git
    targetRevision: HEAD
  syncPolicy:
    automated: {}
EOF
```{{execute}}

The second one will track changes in Tekton manifests, including your pipelines.

```
cat <<EOF >argo-deploy-tekton.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: tekton
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  project: default
  source:
    path: cicd/tekton
    repoURL: https://github.com/andreasevers/go-sample-app-ops.git
    targetRevision: HEAD
  syncPolicy:
    automated: {}
EOF
```{{execute}}

Let's move on to put the entire flow together.
