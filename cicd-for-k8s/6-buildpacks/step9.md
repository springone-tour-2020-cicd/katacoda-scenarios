# OPTIONAL: Use Buildpacks in Tekton Pipeline

Objective:

If you are curious to know how you you can configure Tekton to use the [Buildpacks task](https://github.com/tektoncd/catalog/blob/v1beta1/buildpacks/README.md), you can follow the steps below. 
This implements Option 2 discusses in Step 5.

In this step, you will:
- Reset the ops repo by cloning the "shortcut" sample
- Remove Tekton configuration used for the Dockerfile workflow
- Install Buildpacks Task from the Tekton catalog
- Add Tekton configuration needed for a Buildpacks workflow
- Apply the updated Tekton resources
- Test the new workflow

## Reset the ops repo

First, get rid of the changes you made to the Tekton manifests in this scenario. The easiest way to do this is to use the shortcut repo:

```
cd /workspace
git clone https://github.com/springone-tour-2020-cicd/go-sample-app-ops.git go-sample-app-ops-temp
cd go-sample-app-ops-temp
git checkout scenario-5-finished
```

## Remove Tekton configuration used for the Dockerfile workflow

Remove the configuration for building images using the Kaniko task for Dockerfile from Tekton.

```
cd cicd/tekton

yq d -i build-pipeline.yaml "spec.tasks.(name==verify-digest)"
yq d -i build-pipeline.yaml "spec.tasks.(name==build-image)"
yq d -i build-pipeline.yaml "spec.params.(name==image)"
yq d -i build-trigger-template.yaml 'spec.resourcetemplates[0].spec.params.(name==image)'
```{{execute}}

You can use the `git diff` command to reiview/validate the changes.
```
git diff
```{{execute}}
```
yq d -i build-pipeline.yaml "spec.tasks.(name==verify-digest)"
yq d -i build-pipeline.yaml "spec.tasks.(name==build-image)"
yq d -i build-pipeline.yaml "spec.params.(name==image)"
yq d -i build-trigger-template.yaml 'spec.resourcetemplates[0].spec.params.(name==image)'
```{{execute}}

## Install Buildpacks Task from the Tekton catalog

Apply the Buildpacks manifest from the Tekton catalog

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/buildpacks/buildpacks-v3.yaml
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

You should the Tasks you installed in step 1, and no Pipelines yet:

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
      "repository": {"clone_url": "'"https://github.com/${GITHUB_NS}/go-sample-app"'"},
      "pull_request": {"head": {"sha": "master"}}
    }' \
localhost:8080
```{{execute}}

Verify the `PipelineRun` executes without any errors. It might take a few minutes to start seeing logs, and some more minutes to complete. The `fetch-repository` task will run first, followed by the `lint` and `test` tasks, and then the `build-image` task. At that point you should see evidence in the logs of the same lifecycle execution that you observed with `pack`. In this case, Tekton - rather than pack - is orchestrating the lifecycle, but it us using the same base images and the same buildpacks, so it will produce the same image.

```
tkn pipelinerun list
tkn pipelinerun logs -f
```{{execute}}

When the pipeline run completes, you should see a new image (go-sample-app:1.0.3) in your Docker Hub account.

Stop the port-forwarding process.

```
pkill kubectl && wait $!
```{{execute}}
