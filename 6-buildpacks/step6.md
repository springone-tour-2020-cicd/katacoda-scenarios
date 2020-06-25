# Deliberate image builds

Objective:

Fine-tune the workflow so that `kpack` only builds images from code that has been tested.

In this step, you will:
- Review the options to address this issue
- Implement a solution wherein Tekton triggers kpack builds
- Test the solution

## Examine the options

Given our setup of Tekton and kpack, when a commit occurs on the master branch of the sample app repo, both Tekton and kpack will be independently triggered. 
Tekton will lint & test the code, and then build & publish an image to Docker Hub using the Buildpacks task. 
At the same time, kpack will build & publish an image to Docker Hub using Buildpacks as well.

There are a couple of issues with this setup:
1. For every commit to the master branch, two processes are building identical images. We only need one - either the Tekton Buildpacks task, or kpack. Given kpack's advantages (easier and more centralized configuration, ability to respond to builder and run image updates, and ability to rebase), we will opt for kpack. This means we can remove the Buildpacks task from the Tekton pipeline.
2. kpack will build images for all commits to master, irrespective of whether or not they pass testing. It would be prefereable to introduce some coordination so that kpack only builds from code that Tekton has successfully tested. There are several ways to resolve this issue. One solution, for example, is to use git branches and configure kpack to listen on a branch that receives only tested commits. Another approach is to configure kpack to build from a specific git commit, rather than a branch. Both solutions are valid, as others may be, and depend on the workflow appropriate for a particular team or organization.

In this step, we will solve these issues by removing the Buildpacks task and configuring Tekton to set the `revision` node of the kpack image.yaml file with the specific git commit that has passed testing. kpack will continue to rebuild when the Builder changes, and it will continue to rebase as well, but it will only build from the specific git commits that are explicitly configured in the Image resource.

One question remains: how should we configure the mechanics of the communication between Tekton and kpack? In keeping with the methodology we have been applying thus far, the first step is to update the kpack image.yaml in the ops repo with the git commit id every time Tekton validates a code change. This means we need a new Tekton task that will push a change to GitHub.

The second step is to apply the update image.yaml to the cluster. At first glance, it might seem natural to configure Tekton to do this. After all, producing an artifact is usually the last step of CI, the hand-off between CI and CD, so it seems intuitive for the "CI tool" to finish the CI workflow. However, in reality we have a tool that is purpose built to detect and apply manifest changes to Kubernetes: Argo CD. Rather than configure Tekton with access to the cluster, we can simply configure Argo CD to monitor the ops/cici/kpack directory in the ops repo. When Tekton updates the image.yaml in GitHub, Argo CD will apply the change to the cluster, and then kpack will create a new image in Docker Hub. It's a beautiful thing. Let's make it happen.

## Delegate image-building to kpack

kpack will be responsible for building images and publishing them to Docker Hub, so you can remove this functionality and its configuration dependencies from your Tekton build pipeline.

```
yq d -i build-pipeline.yaml "spec.tasks.(name==build-image)"
yq d -i build-pipeline.yaml "spec.resources"
yq d -i build-pipeline.yaml "spec.params.(name==image)"
yq d -i build-trigger-binding.yaml "spec.params.(name==IMAGE)"
yq d -i build-trigger-template.yaml "spec.params.(name==IMAGE)"
yq d -i build-trigger-template.yaml "spec.resourcetemplates[0].spec.params"
```{{execute}}

## Clone the ops repo in the build pipeline

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

This task uses a new workspace for the repo clone. You need to add the new workspace to the list of workspaces for the pipeline.

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

# Provide access rights to push to GitHub

Now that you have a clone of the ops repo in your Pipeline, you need to grant Tekton the authority to push the updated `image.yaml` file to GitHub. 

If your GitHub username is the same as your namespace/org, execute the following command.

```
GITHUB_USER=$GITHUB_NS
```{{execute}}

Otherwise, copy the following command to the terminal and provide your GitHub username.

```
# Fill this in with your GitHub login
GITHUB_USER=
```{{copy}}

Copy and paste the following command to the terminal window and provide your GitHub access token.

```
# Fill this in with your GitHub access token
GITHUB_TOKEN=
```{{copy}}

Use the token to create a new `Secret`.

```
kubectl create secret generic github-token --from-literal=GITHUB_TOKEN=${GITHUB_TOKEN}
```{{execute}}

Tekton can now use this Secret to push changes to GitHub.

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

Review the Task and apply it to the cluster.

```
yq r -C update-image-revision-task.yaml
kubectl apply -f update-image-revision-task.yaml
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

## Apply the new Tekton resources

Go ahead and apply the resources to the cluster.

```
kubectl apply -f .
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
    repoURL: https://github.com/${GITHUB_NS}/go-sample-app-ops.git
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
    repoURL: https://github.com/${GITHUB_NS}/go-sample-app-ops.git
    targetRevision: HEAD
  syncPolicy:
    automated: {}
EOF
```{{execute}}

Let's move on to put the entire flow together.
