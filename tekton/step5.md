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
```

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
```

Also note that we require a workspace to write our cloned files into.
Let's add the parameters and the workspace using `yq`.

```
yq m pipeline.yaml - <<EOF
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
    description: |
      This workspace will receive the cloned git repo and be passed
      to the next Task for the repo's README.md file to be read.
EOF
```
We can now add the `golangci-lint` Task to validate our Go package.

```
yq m pipeline.yaml - <<EOF
spec:
  tasks:
    - name: run-lint
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
yq m pipeline.yaml - <<EOF
spec:
  tasks:
    - name: run-test
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
yq m pipeline.yaml - <<EOF
spec:
  tasks:
    - name: run-build
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
yq m pipeline.yaml - <<EOF
spec:
  tasks:
  - name: kaniko
    taskRef:
      name: kaniko
    runAfter:
    - fetch-repository
    - run-lint
    - run-test
    - run-build
    workspaces:
    - name: source
      workspace: shared-workspace
    params:
    - name: IMAGE
      value: $(params.image)
    - name: EXTRA_ARGS
      value: "--skip-tls-verify"
EOF
```{{execute}}

This task needs a new parameter called `image`.
Let's add it as well to the parameter section.

```
yq m pipeline.yaml - <<EOF
spec:
  params:
  - name: image
    description: reference of the image to build
EOF
```{{execute}}

Finally, we should verify whether our push was successful.
We can do this by adding a task that verifies the digest.

```
yq m pipeline.yaml - <<EOF
spec:
  tasks:
  - name: verify-digest
    runAfter:
    - kaniko
    params:
    - name: digest
      value: $(tasks.kaniko.results.IMAGE-DIGEST)
    taskSpec:
      params:
      - name: digest
      steps:
      - name: bash
        image: ubuntu
        script: |
          echo $(params.digest)
          case .$(params.digest) in
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


--------------


**The `url` parameter value should be set to the Docker Hub repository name.  The version `1.0.0` should match what you have in the `pom.xml` file in your github repository of the sample application.**

After changing the two `url` values, execute the taskrun

```
kubectl apply -f jib-maven-taskrun.yaml
```{{execute}}


Now let's get a description of the `TaskRun` that was created.

```
tkn taskrun describe jib-maven-taskrun
```{{execute}}


To view the logs

```
tkn taskrun logs --follow jib-maven-taskrun
```{{execute}}


After a bit of time to download the images that the task will use has completed, you will see many log entries for the downloading of maven artifacts.

At the end of the log, you will see a successful push of the image to Docker Hub as shown below.


```
[build-and-push] [INFO] Built and pushed image as markpollack/spring-sample-app:1.0.0
[build-and-push] [INFO]
[build-and-push] [INFO] ------------------------------------------------------------------------
[build-and-push] [INFO] BUILD SUCCESS
[build-and-push] [INFO] ------------------------------------------------------------------------
[build-and-push] [INFO] Total time:  5.269 s
[build-and-push] [INFO] Finished at: 2020-02-15T23:05:09Z
[build-and-push] [INFO] ------------------------------------------------------------------------
```



Now, instead of running a once off task, let's create a pipeline that is more typical in a CI scenario of multiple steps.  On to the next step!


In this step we will create `Pipeline` resources that lint, test and build the go application, as well as building the container image of the application and publishing it to Docker Hub.


