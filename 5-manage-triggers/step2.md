# Add a Deployment Pipeline

Objective:
Assuming the `PipelineRun` finished successfully, you now have a new image in your Docker Hub account.
That image's reference however needs to be manually updated in the Kustomize files.
Let's make a pipeline for this purpose as well.

In this step, you will:
- Create another `Task`, responsible for modifying the image tag on the development overlay
- Create a new `Pipeline` and `PipelineRun` specification inside another `TriggerTemplate`
- Trigger the new pipeline by reacting to Docker Hub changes

## Introduce a new Task

```
cat <<EOF >bump-dev-task.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: bump-dev-task
spec:
  resources:
    inputs:
    - name: git-sources
      type: git
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
EOF
```execute

We can now add two steps.
The first step modifies the development overlay with the new tag.

```
cat <<EOF >>bump-dev-task.yaml
  steps:
  - name: update-image-tag
    image: mikefarah/yq
    workingDir: $(workspaces.source.path)
    script: |
        #!/usr/bin/env sh

        echo "[INFO] Updating tags..."
        BUILD_DATE=`date +%Y.%m.%d-%H.%M.%S`
        cd go-sample-app/ops/overlays/dev
        yq m -i -x kustomization.yaml - <<EOF
        images:
          - name: ${GITHUB_NS}/go-sample-app  # used for Kustomize matching
            newTag: \${BUILD_DATE}
        EOF
```execute

And the second step deploys the new resources to the `dev` namespace.
This step however requires your GitHub username to be able to push.

You can copy and paste the following command into the terminal window, then append your GitHub login:

```
# Fill this in with your GitHub login
GITHUB_USER=
```{{copy}}

Note: If your GitHub login is the same as the GitHub username or org which contains the `go-sample-app`, you can simply execute the following command instead.

```
GITHUB_USER=$GITHUB_NS
```{{execute}}

The Task also needs your GitHub access token to authenticate with the Git server.
You can copy and paste the following command into the terminal window, then append your GitHub login:

```
# Fill this in with your GitHub access token
GITHUB_TOKEN=
```{{copy}}

```
kubectl create secret generic github-token --from-literal=GITHUB_TOKEN=${GITHUB_TOKEN}
```{{execute}}

```
cat <<EOF >>bump-dev-task.yaml
  - name: git-commit
    image: gcr.io/tekton-releases/github.com/tektoncd/pipeline/cmd/git-init:v0.12.1
    workingDir: $(workspaces.source.path)
    script: |
      git remote set-url origin https://${GITHUB_USER}:\${GITHUB_TOKEN}@github.com/${GITHUB_NS}/go-sample-app.git
      git config user.name build-bot
      git config user.email build-bot@bots.bot
      git add go-sample-app/ops/overlays/dev/kustomization.yaml
      git commit -m "Automatically promoting dev version"
      git push origin master
    env:
      - name: GITHUB_TOKEN
        valueFrom:
          secretKeyRef:
            name: $(params.GITHUB_TOKEN_SECRET)
            key: $(params.GITHUB_TOKEN_SECRET_KEY)
```{{execute}}

```
yq r -C bump-dev-task.yaml
```{{execute}}

## Introduce the new Pipeline

```
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: tekton-go-pipeline
spec:
  params:
    - name: repo-url
      type: string
      description: The git repository URL to clone from.
    - name: branch-name
      type: string
      description: The git branch to clone.
    - name: image
      description: reference of the image to build
  workspaces:
    - name: shared-workspace
      description: |
        This workspace will receive the cloned git repo and be passed
        to the next Task for the repo's README.md file to be read.
  tasks:
    - name: fetch-repository
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: url
          value: $(params.repo-url)
        - name: revision
          value: $(params.branch-name)
    - name: lint
      taskRef:
        name: golangci-lint
      runAfter:
        - fetch-repository
      workspaces:
        - name: source
          workspace: shared-workspace
      params:
        - name: package
          value: github.com/tektoncd/pipeline
    - name: test
      taskRef:
        name: golang-test
      runAfter:
        - fetch-repository
      workspaces:
        - name: source
          workspace: shared-workspace
      params:
        - name: package
          value: github.com/tektoncd/pipeline
    - name: build
      taskRef:
        name: golang-build
      runAfter:
        - fetch-repository
      workspaces:
        - name: source
          workspace: shared-workspace
      params:
        - name: package
          value: github.com/tektoncd/pipeline
    - name: kaniko
      taskRef:
        name: kaniko
      runAfter:
        - fetch-repository
        - lint
        - test
        - build
      workspaces:
        - name: source
          workspace: shared-workspace
      params:
        - name: IMAGE
          value: $(params.image)
    - name: verify-digest
      runAfter:
        - kaniko
      params:
        - name: digest
          value: $(tasks.kaniko.results.IMAGE-DIGEST)
      taskSpec:
        inputs:
          params:
            - name: digest
              value: $(params.digest)
        steps:
          - name: bash
            image: ubuntu
            script: |
              echo $(inputs.params.digest)
              case .$(inputs.params.digest) in
                ".sha"*) exit 0 ;;
                *)       echo "Digest value is not correct" && exit 1 ;;
              esac
```
