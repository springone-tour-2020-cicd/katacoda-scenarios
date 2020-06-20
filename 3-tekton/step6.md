# Run the pipeline

In order for us to instantiate the pipeline, we need to create a `PipelineRun` resource.

Let's start with the following resource, linking up to the `Pipeline` resource, as well as the `PersistentVolumeClaim` we created in step 3.

```
cat <<EOF >build-pipeline-run.yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: build-pipeline-run
spec:
  pipelineRef:
    name: build-pipeline
  workspaces:
  - name: shared-workspace
    persistentvolumeclaim:
      claimName: workspace-pvc
EOF
```{{execute}}

We also have to set a value for each parameter that each Task expects.

For starters, we need your Docker Hub namespace (your user or org name).
You can copy and paste the following command into the terminal window, then append your namespace:

```
# Fill this in with your DockerHub username or org
IMG_NS=
```{{copy}}

Now we can set the correct image name.
For the version we can use the current date and time as a quick solution.

```
BUILD_DATE=`date +%Y.%m.%d-%H.%M.%S`
yq m -i build-pipeline-run.yaml - <<EOF
spec:
  params:
  - name: image
    value: ${IMG_NS}/go-sample-app:${BUILD_DATE}
EOF
```{{execute}}

In order to push to Docker Hub, we need to share our build-bot `ServiceAccount` with the `Pipeline`.

```
yq m -i build-pipeline-run.yaml - <<EOF
spec:
  serviceAccountName: build-bot
EOF
```{{execute}}

For the `git-clone` Task, we need to know your git repository containing the Go application.
Let's add the repository URL to the list of parameters.

```
yq m -i -a build-pipeline-run.yaml - <<EOF
spec:
  params:
  - name: repo-url
    value: https://github.com/${GITHUB_NS}/go-sample-app.git
EOF
```{{execute}}

Finally, we'll need to tell the `git-clone` Task which branch to clone.
Let's take `master` for now.

```
yq m -i -a build-pipeline-run.yaml - <<EOF
spec:
  params:
  - name: branch-name
    value: master
EOF
```{{execute}}

Let's take a look at our entire `PipelineRun` resource.

```
more build-pipeline-run.yaml
```{{execute}}

If you're ready to execute the pipeline, issue the following command.

```
kubectl apply -f build-pipeline-run.yaml
```{{execute}}

The new pipelinerun should now be executing.
You can track its status by taking a look at the pipelineruns list.

```
tkn pipelineruns list
```{{execute}}

More details are available by describing the Pipelinerun.

```
tkn pipelineruns describe build-pipeline-run
```{{execute}}

Once all the steps have successfully finished, you can navigate to your account on [Docker Hub](https://hub.docker.com/), and see your published image with the new tag.
