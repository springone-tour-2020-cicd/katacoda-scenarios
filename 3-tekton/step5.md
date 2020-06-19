# Combine Tasks in a Pipeline

We can now create `TaskRun` resources for each of the `Tasks` we created.
However, many of the tasks depend on each other.
We'd love to run these tasks in sequence, as part of a pipeline.
For this, Tekton provides us the `Pipeline` and `PipelineRun` resources.

In this step we will create `Pipeline` resources that consist of `TaskRun` specifications, as well as `PipelineRun` resources that will execute the created `Pipeline` resources.

## Create the Pipeline

Let's start with creating a basic `Pipeline` resource, without any parameters, workspaces or tasks.

```
cat <<EOF >pipeline.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: tekton-go-pipeline
spec:
  params:
  workspaces:
  tasks:
EOF
```{{execute}}

As a first task, we need to clone the code.
Let's add the `git-clone` task to our pipeline.
We will need two parameters, `repo-url` and `branch-name`.

```
cat <<EOF >>pipeline.yaml
  - name: fetch-repository
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: shared-workspace
    params:
    - name: url
      value: \$(params.repo-url)
    - name: revision
      value: \$(params.branch-name)
EOF
```{{execute}}

Also note that we require a workspace to write our cloned files into.
Let's add the parameters and the workspace using `yq`.

```
yq m -i pipeline.yaml - <<EOF
spec:
  params:
  - name: repo-url
    type: string
    description: The git repository URL to clone from.
  - name: branch-name
    type: string
    description: The git branch to clone.
  workspaces:
  - name: shared-workspace
    description: This workspace will receive the cloned git repo and be passed to the next Task.
EOF
```{{execute}}

We can now add the `golangci-lint` Task to validate our Go package.

```
yq m -i -a pipeline.yaml - <<EOF
spec:
  tasks:
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
EOF
```{{execute}}

Next up is the `golang-test` Task to run unit-tests on our Go package.

```
yq m -i -a pipeline.yaml - <<EOF
spec:
  tasks:
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
EOF
```{{execute}}

Notice we also run this Task after `fetch-repo`, which means it will be done in parallel.
We can also add the `golang-build` Task in parallel to compile our code while our linter and test is running.

```
yq m -i -a pipeline.yaml - <<EOF
spec:
  tasks:
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
EOF
```{{execute}}

After fetching the repository, running the tests and linters, and building the code, we can now build the image and push to Docker Hub.

```
yq m -i -a pipeline.yaml - <<EOF
spec:
  tasks:
  - name: build-image
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
      value: \$(params.image)
EOF
```{{execute}}

This task needs a new parameter called `image`.
Let's add it as well to the parameter section.

```
yq m -i -a pipeline.yaml - <<EOF
spec:
  params:
  - name: image
    description: reference of the image to build
EOF
```{{execute}}

Finally, we should verify whether our push was successful.
We can do this by adding a task that verifies the digest.

```
yq m -i -a pipeline.yaml - <<EOF
spec:
  tasks:
  - name: verify-digest
    runAfter:
    - build-image
    params:
    - name: digest
      value: \$(tasks.build-image.results.IMAGE-DIGEST)
    taskSpec:
      inputs:
        params:
        - name: digest
          value: \$(params.digest)
      steps:
      - name: bash
        image: ubuntu
        script: |
          echo \$(inputs.params.digest)
          case .\$(inputs.params.digest) in
            ".sha"*) exit 0 ;;
            *)       echo "Digest value is not correct" && exit 1 ;;
          esac
EOF
```{{execute}}

Let's take a look at our entire pipeline file.

```
more pipeline.yaml
```{{execute}}

We can now add this `Pipeline` to our cluster.

```
tkn pipeline create -f pipeline.yaml
```{{execute}}

In the next step we'll add the necessary configuration to actually run this pipeline.
