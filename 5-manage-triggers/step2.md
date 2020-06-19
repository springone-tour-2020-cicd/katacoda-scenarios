# Add a Deployment Pipeline

Objective:
Assuming the `PipelineRun` finished successfully, you now have a new image in your Docker Hub account.
That image's reference however needs to be manually updated in the Kustomize files.
Let's make a pipeline for this purpose as well.

In this step, you will:
- Create a new `Pipeline` and `PipelineRun` specification inside another `TriggerTemplate`
- Trigger the new pipeline by reacting to Docker Hub changes

## Introduce a new Task

```
cat <<EOF >deploy-kustomize-task.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deploy-kustomize-task
spec:
  resources:
    inputs:
    - name: git-source
      type: git
  workspaces:
    - name: source
EOF
```execute

We can now add two steps.
The first step modifies the development overlay with the new tag.

```
cat <<EOF >>deploy-kustomize-task.yaml
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

```
cat <<EOF >>deploy-kustomize-task.yaml
  - name: deploy-to-dev
    image: nekottyo/kustomize-kubeval
    workingDir: $(workspaces.source.path)
    script: |
        #!/usr/bin/env sh

        cd /workspace/go-sample-app/ops/overlays/dev

        # First check if a dryrun is successful
        echo "[INFO] Starting dry run..."
        kustomize build --load_restrictor none . | kubectl apply --dry-run=server -f -

        if [ $? != 0 ]; then
          echo "[ERROR] Dry run of deployment was unsuccessful. Please review errors above for more details. Service will not be deployed."
          exit 1
        fi
        # If it's good then run
        echo "[INFO] Starting deployment..."
        kustomize build --load_restrictor none . | kubectl apply -f -
        kubectl rollout status deploy/go-sample-app -n dev
        if [ $? != 0 ]; then
          echo "[ERROR] Deployment was unsuccessful. Please review errors above for more details. Service was not deployed."
          exit 1
        fi
```execute

```
yq r -C deploy-kustomize-task.yaml
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
