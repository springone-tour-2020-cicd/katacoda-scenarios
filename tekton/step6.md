# Run the pipeline

In order for us to instantiate the pipeline, we need to create a `PipelineRun` resource.

Let's start with the following resource, linking up to the `Pipeline` resource, as well as the `PersistentVolumeClaim` we created in step 3.

```
cat <<EOF >pipeline-run.yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: tekton-go-pipeline-run
spec:
  pipelineRef:
    name: tekton-go-pipeline
  workspaces:
  - name: shared-workspace
    persistentvolumeclaim:
      claimName: tekton-tasks-pvc
EOF
```

We also have to set a value for each parameter that each Task expects.

For starters, we need your Docker Hub namespace (your user or org name).
You can copy and paste the following command into the terminal window, then delete the placeholder and replace it with your namespace:

```
IMG_NS=<YOUR_DH_USERNAME_OR_ORG>
```{{copy}}

Now we can set the correct image name.
For the version we can use the current date and time as a quick solution.

```
BUILD_DATE=`date +%Y.%m.%d-%H.%M.%S`
yq m -i pipeline.yaml - <<EOF
spec:
  params:
  - name: image
    value: ${IMG_NS}/go-sample-app:${BUILD_DATE}
EOF
```

For the `git-clone` Task, we need to know your git repository containing the Go application.
You can copy and paste the following command into the terminal window, then delete the placeholder and replace it with your GitHub username or org:

```
GITHUB_NS=<YOUR_GH_USERNAME_OR_ORG>
```{{copy}}

Let's add the repository URL to the list of parameters.

```
yq m -i pipeline.yaml - <<EOF
spec:
  params:
  - name: repo-url
    value: github.com/${GITHUB_NS}/go-sample-app
EOF
```

Finally, we'll need to tell the `git-clone` Task which branch to clone.
Let's take `master` for now.

```
yq m -i pipeline.yaml - <<EOF
spec:
  params:
  - name: branch-name
    value: master
EOF
```

Let's take a look at our entire `PipelineRun` resource.

```
more pipeline-run.yaml
```{{execute}}

If you're ready to execute the pipeline, issue the following command.

```
kubectl apply -f pipeline-run.yaml
```

If you navigate to your account on [Docker Hub](https://hub.docker.com/), you will see your published image.