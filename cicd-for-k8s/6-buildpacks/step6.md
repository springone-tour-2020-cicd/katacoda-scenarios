# Deliberate image builds

Objective:

Fine-tune the workflow so that `kpack` only builds images from code that has been tested.

In this step, you will:
- Remove image-building configuration from Tekton
- Configure Tekton to update the revision in the kpack Image manifest
- Test the updated Tekton pipeline

## Delegate all image-building to kpack

kpack will be responsible for building images and publishing them to Docker Hub, so you can remove this functionality and its configuration dependencies from your Tekton build pipeline.

Go to the 'ops' repository, to the directory containing Tekton configuration.

```
cd /workspace/go-sample-app-ops/cicd/tekton
```{{execute}}

Remove the configuration for building images using the Kaniko task for Dockerfile from Tekton.

```
yq d -i build-pipeline.yaml "spec.tasks.(name==verify-digest)"
yq d -i build-pipeline.yaml "spec.tasks.(name==build-image)"
yq d -i build-pipeline.yaml "spec.params.(name==image)"
yq d -i build-trigger-template.yaml 'spec.resourcetemplates[0].spec.params.(name==image)'
```{{execute}}

You can use the `git diff` command to reiview/validate the changes.
```
git diff
```{{execute}}

## Configure Tekton to push a change to the ops repo (`cicd/kpack/image.yaml` file)

The `image.yaml` file is located in the `ops/cicd/kpack` directory of the `go-sample-app-**ops**` repository.
In order for Tekton to update this file, it must clone this repository from GitHub.

Add a task to the pipeline to clone the ops repository.

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

This task has a dependency on a new workspace (`shared-ops-workspace`), which will be used for the repo clone. 
Add the new workspace to the list of workspaces for the pipeline.

```
yq m -i -a build-pipeline.yaml - <<EOF
spec:
  workspaces:
    - name: shared-ops-workspace
      description: This workspace will receive the cloned Git ops repo and be passed to the next Task.
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

## Create a Tekton Task to update the `image.yaml` file

Run the following command to create the manifest for a Task that updates the revision node of kpack's `image.yaml` file.
The Task has two steps:
- the first step uses yq to update the image.yaml file; it sets the the revision node to the git commit id of the app source code that was just tested
- the second step pushes the change to Github

```
cd /workspace/go-sample-app-ops/cicd/tekton

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
  steps:
  - name: update-revision
    image: mikefarah/yq
    workingDir: \$(workspaces.source.path)
    script: |
        cd cicd/kpack
        yq w -i image.yaml "spec.source.git.revision" "\$(params.REVISION)"
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

## Provide access rights to push to GitHub

In order to push the updated image.yaml file to GitHub, Tekton will need write access to the ops repo. Notice that the task above references a Secret called `github-token`. You need to create this Secret in the cluster.

You already provided your GitHub token in step 1, and it is saved in the GITHUB_TOKEN environment variable, so you can simply run the following command to create a new `Secret` in the cluster.

```
kubectl create secret generic github-token --from-literal=GITHUB_TOKEN=${GITHUB_TOKEN}
```{{execute}}

Review the Task.

```
yq r -C update-image-revision-task.yaml
```{{execute}}

## Use the new Task in the Pipeline

Update the Pipeline to include the new task you just created.

```
yq m -i -a build-pipeline.yaml - <<EOF
spec:
  params:
    - name: github-token-secret
      type: string
      description: Name of the secret holding the github-token.
    - name: github-token-secret-key
      description: Name of the secret key holding the github-token.
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

Take a look at the entire `Pipeline`.

```
yq r -C build-pipeline.yaml
```{{execute}}

## Update the trigger

The new parameters also need to be added to the `TriggerTemplate`.

```
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

Take a look at the entire `TriggerTemplate`.

```
yq r -C build-trigger-template.yaml
```{{execute}}

## Test the updated pipeline

Apply the resources to the cluster.

```
kubectl apply -f .
```{{execute}}

Navigate to your **ops** repo on [GitHub](https://github.com). After some time you should see a new commit. The updated `image.yaml` file should have a git commit id in the revision node. Validate that the commit id corresponds to the latest commit id in your **app** repo.

You will not yet see kpack building an image, nor will you see a new image in Docker Hub. This is because Tekton has only updatded the `image.yaml` file in the ops repo. The file has not been applied to Kubernetes.

We will take care of that in the next step.