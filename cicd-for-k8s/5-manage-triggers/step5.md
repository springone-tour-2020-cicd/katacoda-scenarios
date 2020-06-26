# Add the promotion pipeline

Objective:

Now that you've sorted out the ops repository, you can start creating the promotion pipeline.

In this step, you will:
- Start off with creating your own `Task`, responsible for modifying the image tag on the development overlay

## Introduce a new Task

The `Task` you're going to build now, will be started right after the `git-clone` `Task` has run.
This means we can use the cloned Git sources as input to our Task.
We also need a couple of parameters to fulfil our task, such as the new image tag, and the GitHub access token `Secret`.

```
cd cicd/tekton
cat <<EOF >ops-dev-task.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: ops-dev
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
    - name: TAG
      type: string
      description: Name of the new image tag.
EOF
```{{execute}}

You can now add two steps.
The first step modifies the development overlay with the new tag.

```
cat <<EOF >>ops-dev-task.yaml
  steps:
  - name: update-image-tag
    image: mikefarah/yq
    workingDir: \$(workspaces.source.path)
    script: |
        cd ops/overlays/dev
        yq m -i -x kustomization.yaml - <<EOD
        images:
          - name: ${GITHUB_NS}/go-sample-app  # used for Kustomize matching
            newTag: \$(params.TAG)
        EOD
EOF
```{{execute}}

And the second step commits the changes.

```
cat <<EOF >>ops-dev-task.yaml
  - name: git-commit
    image: gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:v0.12.1
    workingDir: \$(workspaces.source.path)
    script: |
      git remote set-url origin https://${GITHUB_USER}:\${GITHUB_TOKEN}@github.com/${GITHUB_NS}/go-sample-app-ops.git
      git config user.name build-bot
      git config user.email build-bot@bots.bot
      git checkout -b temp-branch
      git add ops/overlays/dev/kustomization.yaml
      git commit -m "Automatically promoting dev version"
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
yq r -C ops-dev-task.yaml
kubectl apply -f ops-dev-task.yaml
```{{execute}}
