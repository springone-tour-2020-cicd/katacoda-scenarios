# Run the tasks

In this step we will create `TaskRun` resources that lint, test and build the go application, as well as building the container image of the application and publishing it to Docker Hub.

## Lint step

Let's create a TaskRun to run the `golangci-lint` Task to validate our Go package.

```
cat <<EOF >lint-taskrun.yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: lint-my-code
spec:
  taskRef:
    name: golangci-lint
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
  params:
  - name: package
    value: github.com/tektoncd/pipeline
  - name: flags
    value: --verbose
EOF
kubectl apply -f lint-taskrun.yaml
```{{execute}}

Let's create a TaskRun to run the `test-my-code` Task to run unit-tests on our Go package.

```
cat <<EOF >test-taskrun.yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: test-my-code
spec:
  taskRef:
    name: golang-test
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
  params:
  - name: package
    value: github.com/tektoncd/pipeline
  - name: packages
    value: ./pkg/...
EOF
kubectl apply -f test-taskrun.yaml
```{{execute}}

This TaskRun runs the Task to compile commands from tektoncd/pipeline. golangci-lint.

```
cat <<EOF >build-taskrun.yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: build-my-code
spec:
  taskRef:
    name: golang-build
  workspaces:
  - name: source
    persistentVolumeClaim:
      claimName: my-source
  params:
  - name: package
    value: github.com/tektoncd/pipeline
EOF
kubectl apply -f build-taskrun.yaml
```{{execute}}

There are two values in the YAML document that need to be changed.

The task run defines the `git` resource and `image` resource as embedded resources to the `TaskRun`.

The git resource is defined in the input section

```
inputs:
  resources:
    - name: source
      resourceSpec:
        type: git
        params:
          - name: url
            value: # REPLACE https://github.com/markpollack/spring-sample-app
          - name: revision
            value: master
```
**The `url` parameter value should be set to the URL of your forked repository of the sample application**

The image resource is defined in the output section

```
outputs:
  resources:
    - name: image
      resourceSpec:
        type: image
        params:
          - name: url
            value: # REPLACE markpollack/spring-sample-app:1.0.0
```

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

If you navigate to your account on [Docker Hub](https://hub.docker.com/), you will see your published image.

Now, instead of running a once off task, let's create a pipeline that is more typical in a CI scenario of multiple steps.  On to the next step!




