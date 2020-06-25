# Use Buildpacks in Tekton Pipeline

Objective:
Learn how you can use a Tekton Task to build apps using Cloud Native Buildpacks within a Tekton Pipeline.

In this step, you will:
- Remove Tekton configuration used for the Dockerfile workflow
- Add Tekton configuration needed for a Buildpacks workflow
- Apply the updated Tekton resources
- Test the new workflow

## Remove Tekton configuration used for the Dockerfile workflow

The build pipeline you configured in previous scenarios uses a Kaniko task to build an image using the Dockerfile in the app repo.
Now that you understand the advantages of Cloud Native Buildpacks over Dockerfile, let's replace the Kaniko task with a Cloud Native Buildpacks task.

Go to the 'ops' repository, to the directory containing Tekton configuration.

```
cd ../go-sample-app-ops/cicd/tekton
```{{execute}}

You need to update Tekton Pipeline (`build-pipeline.yaml`) and TriggerTemplate (`build-trigger-template.yaml`).

First, remove the Kaniko `build-image` and `verify-digest` tasks.

```
yq d -i build-pipeline.yaml "spec.tasks.(name==verify-digest)"
yq d -i build-pipeline.yaml "spec.tasks.(name==build-image)"
```{{execute}}

Remove the Kaniko-specific image configuration.
```
yq d -i build-pipeline.yaml - <<EOF
spec:
  params:
  - name: image
    description: reference of the image to build
EOF
```{{execute}}

Remove the TriggerTemplate used for the image.

```
yq d -i build-trigger-template.yaml 'spec.resourcetemplates[0].spec.params.(name==image)'
```{{execute}}

## Add Tekton configuration needed for a Buildpacks workflow

Next, add a new `build-image` task based on the [Buildpacks task](https://github.com/tektoncd/catalog/blob/v1beta1/buildpacks/README.md) available in the Tekton catalog and configure it to use the same Paketo Buildpacks builder you used in the previous step.

```
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

Add the image configuration required by Buildpacks.

```
yq m -i build-pipeline.yaml - <<EOF
spec:
  resources:
    - name: build-image
      type: image
EOF
```{{execute}}

In order to leverage the caching features provided by Buildpacks, you need to configure an additional Persistent Volume Claim. In the Katacoda environment, this requires that you create a corresponding Persistent Volume as well.

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

Configure a new TriggerTemplate to use for the Buildpacks workflow.

```
yq m -i build-trigger-template.yaml - <<EOF
spec:
  resourcetemplates:
    - spec:
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

## Apply the updated Tekton resources

You should see four Tasks available in your Tekton installation, and no Pipelines yet:

```
tkn task list
tkn pipeline list
```{{execute}}

Apply the updated resources.

```
kubectl apply -f sa.yaml \
              -f pv.yaml \
              -f pvc.yaml \
              -f buildpacks-cache-pv.yaml \
              -f buildpacks-cache-pvc.yaml \
              -f buildpacks-app-image.yaml
```{{execute}}

```
kubectl apply -f build-pipeline.yaml \
              -f build-trigger-template.yaml \
              -f build-trigger-binding.yaml \
              -f build-event-listener.yaml
```{{execute}}

## Test it out

Wait for the deployment to finish.

```
kubectl rollout status deployment/el-build-event-listener
```{{execute}}

Port-forward the service to make it accessible from outside the cluster.

```
kubectl port-forward --address 0.0.0.0 svc/el-build-event-listener 8080:8080 2>&1 > /dev/null &
```{{execute}}

Trigger a pull request event, which should create a new `PipelineRun`.

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

Verify the `PipelineRun` executes without any errors.

```
tkn pipelinerun list
tkn pipelinerun logs -f
```{{execute}}

Stop the port-forwarding process.

```
pkill kubectl && wait $!
```{{execute}}
