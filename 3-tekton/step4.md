# Install the tasks

We can now install the required tasks that will be part of our pipeline.

The [git task](https://github.com/tektoncd/catalog/blob/v1beta1/git/git-clone.yaml) can be leveraged to provide Tekton the source code.  
The [golang tasks](https://github.com/tektoncd/catalog/blob/v1beta1/golang/README.md) provide an easy and quick way to lint, build and test Go apps.  
The [kaniko task](https://github.com/tektoncd/catalog/blob/v1beta1/kaniko/README.md) builds source into a container image using Google's [kaniko](https://github.com/GoogleCloudPlatform/kaniko) tool.

## Install tasks

Go ahead and install the predefined `git`, `golang` and `kaniko` tasks.

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/git/git-clone.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/golang/lint.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/golang/build.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/golang/tests.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/kaniko/kaniko.yaml
```{{execute}}


Now if you list the tasks installed in the cluster you will see five new tasks along with the `echo-hello-world` task from the previous step.

```
tkn task list
```{{execute}}

```
$ tkn task list
NAME               AGE
echo-hello-world   10 minutes ago
git-clone          6 seconds ago
golang-build       6 seconds ago
golang-test        6 seconds ago
golangci-lint      6 seconds ago
kaniko             6 seconds ago
```

Let's take a closer look at the `golang-build` task.

```
curl https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/golang/build.yaml
```{{execute}}

The command that the task executes is mentioned under the `build` step.

```
steps:
  - name: build
    image: golang:$(params.version)
    workingDir: $(workspaces.source.path)
    script: |
      go build $(params.flags) $(params.packages)
    env:
    - name: GOPATH
      value: /workspace
    - name: GOOS
      value: "$(params.GOOS)"
    - name: GOARCH
      value: "$(params.GOARCH)"
    - name: GO111MODULE
      value: "$(params.GO111MODULE)"
```

The value of the properties and environment variables will be set when we create the TaskRun resource that references this Task.

With these predefined Tasks installed in the cluster, we can now compose these Tasks in a Pipeline.

