# Use Buildpacks in Tekton Pipeline

Objective:
Learn how you can use a Tekton Task to build apps using Cloud Native Buildpacks within a Tekton Pipeline.

In this step, you will:
- Update your Tekton build pipeline to use Buildpacks instead of Dockerfile

## Update the build pipeline yaml

The build pipeline you configured in previous scenarios uses a Kaniko task to build an image using the Dockerfile in the app repo, and push the image to Docker Hub. Instead, we will use a The [Buildpacks task](https://github.com/tektoncd/catalog/blob/v1beta1/buildpacks/README.md).

Use `yq -x` to overwrite the build-image task configuration:

```
cd tekton
yq d -i build-pipeline.yaml "spec.tasks.(name==build-image)"
yq m -i -a build-pipeline.yaml - <<EOF
spec:
  tasks:
  - name: build-image
    taskRef:
      name: buildpacks-v3
    runAfter:
      - fetch-repository
      - lint
      - test
    workspaces:
      - name: source
        workspace: shared-workspace
    params:
      - name: BUILDER_IMAGE
        value: gcr.io/paketo-buildpacks/builder:base-platform-api-0.3
      - name: CACHE
        value: buildpacks-cache
    resources:
      outputs:
        - name: image
          resource: build-image
EOF
```{{execute}}

This buildpacks task requires a slightly different configuration for the image reference. The following commands removes the kaniko-specific configuration and adds the buildpacks configuration:

```
yq d -i build-pipeline.yaml - <<EOF
spec:
  params:
  - name: image
    description: reference of the image to build
EOF
```{{execute}}

```
yq m -i build-pipeline.yaml - <<EOF
spec:
  resources:
    - name: build-image
      type: image
EOF
```{{execute}}

## Introduce new `PersistentVolume` and `PersistentVolumeClaim`

First we need to create a Persistent Volume.

```
cat <<EOF >buildpacks-cache-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: buildpacks-cache-pv
spec:
  capacity:
    storage: 3Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  hostPath:
    path: "/mnt/data"
EOF
```{{execute}}

Create the Persistent Volume Claim:

```
cat <<EOF >>buildpacks-cache-pvc.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: buildpacks-cache-pvc
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
EOF
```{{execute}}

## Update the build pipeline run yaml

The difference in the way the image is configured betwee the kaniko and buildpacks task also requires a change to the pipeline run resource.

```
yq d -i build-pipeline-run.yaml 'spec.params.(name==image)'

yq m -i build-pipeline-run.yaml - <<EOF
spec:
  resources:
    - name: build-image
      resourceRef:
        name: buildpacks-app-image
  podTemplate:
    volumes:
      - name: buildpacks-cache
        persistentVolumeClaim:
          claimName: buildpacks-cache-pvc
EOF
```{{execute}}

The resourceRef and persistentVolumeClaim above require new resources as well:

```
cat <<EOF >buildpacks-app-image.yaml
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: buildpacks-app-image
spec:
  type: image
  params:
    - name: url
      value: ${IMG_NS}/go-sample-app:1.0.3
EOF
```{{execute}}

## Deploy Tekton resources

Since this is a new scenario, before running the updated pipeline, you need to re-install the Tekton CRDs, as well as the tasks being used in the build pipeline.

```
# Install Tekton CRDs
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.13.2/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# Install Tasks to clone app repo, lint and test the Go app
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/git/git-clone.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/golang/lint.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/golang/tests.yaml
#kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/kaniko/kaniko.yaml

# Install new buildpacks Task to build image
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/buildpacks/buildpacks-v3.yaml
```{{execute}}

At this point you should see the four Tasks installed from the TektonCD Catalog, and no pipelines yet:

```
tkn task list
tkn pipeline list
```{{execute}}

## Configure authentication for Docker Hub

You have already logged in to docker, so you are ready to create the registry `Secret`.

```
kubectl create secret generic regcred  --from-file=.dockerconfigjson=/root/.docker/config.json --type=kubernetes.io/dockerconfigjson
```{{execute}}


## Apply the updated pipeline

```
kubectl apply -f sa.yaml \
              -f pv.yaml \
              -f pvc.yaml \
              -f buildpacks-cache-pv.yaml \
              -f buildpacks-cache-pvc.yaml \
              -f buildpacks-app-image.yaml
```{{execute}}

```
tkn pipelines create -f build-pipeline.yaml
```{{execute}}

```
kubectl apply -f build-pipeline-run.yaml
```{{execute}}

# Check status

```
tkn pipelineruns list
```{{execute}}

Get more info
```
tkn pipelineruns describe build-pipeline-run
```{{execute}}

## Test it out

Wait for the deployment to finish.

```
kubectl rollout status deployment/el-tekton-go-event-listener
```{{execute}}

Let's port-forward our service.

```
kubectl port-forward --address 0.0.0.0 svc/el-tekton-go-event-listener 8080:8080 2>&1 > /dev/null &
```{{execute}}

Now we can trigger a pull request event, which should create a new `PipelineRun`.

```
curl \
    -H 'X-GitHub-Event: pull_request' \
    -H 'Content-Type: application/json' \
    -d '{
      "repository": {"clone_url": "'"https://github.com/${IMG_NS}/go-sample-app"'"},
      "pull_request": {"head": {"sha": "master"}}
    }' \
localhost:8080
```{{execute}}

Next, verify the `PipelineRun` executes without any errors.

```
tkn pipelinerun list
tkn pipelinerun logs -f
```{{execute}}

Stop the port-forwarding process:
```
pkill kubectl && wait $!
```{{execute}}



