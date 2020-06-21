# Add a Deployment Pipeline

Objective:
Assuming the `PipelineRun` finished successfully, you now have a new image in your Docker Hub account.
That image's reference however needs to be manually updated in the Kustomize files.
Let's make a pipeline for this purpose as well.

In this step, you will:
- Trigger the new pipeline by reacting to Docker Hub changes

## Introduce the new Trigger

Whenever a new image gets pushed to Docker Hub, our pipeline needs to run.
Create a new `TriggerTemplate` using the `Pipeline` you just created.

```
cat <<EOF >bump-dev-trigger-template.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerTemplate
metadata:
  name: bump-dev-trigger-template
spec:
  resourcetemplates:
  - apiVersion: tekton.dev/v1beta1
    kind: PipelineRun
    metadata:
      generateName: bump-dev-pipeline-run-
    spec:
      pipelineRef:
        name: bump-dev-pipeline
      workspaces:
      - name: shared-workspace
        persistentvolumeclaim:
          claimName: workspace-pvc
      params:
      - name: tag
        value: \$(params.tag)
      - name: repo-url
        value: https://github.com/${GITHUB_NS}/go-sample-app.git
      - name: branch-name
        value: master
      - name: github-token-secret
        value: github-token
      - name: github-token-secret-key
        value: GITHUB_TOKEN
      serviceAccountName: build-bot
  params:
  - name: tag
    description: Tag of the new Docker image.
EOF
```{{execute}}

Take a look at the entire `TriggerTemplate`, and apply it to the cluster.

```
yq r -C bump-dev-trigger-template.yaml
kubectl apply -f bump-dev-trigger-template.yaml
```{{execute}}

## Add a TriggerBinding


```
BUILD_DATE=`date +%Y.%m.%d-%H.%M.%S`
cat <<EOF >bump-dev-trigger-binding.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerBinding
metadata:
  name: bump-dev-trigger-binding
spec:
  params:
  - name: tag
    value: \$(body.push_data.tag)
EOF
```{{execute}}


## Link it up with an EventListener

Let's pair the `TriggerTemplate` with the `TriggerBindings` using a new `EventListener`.

```
cat <<EOF >bump-dev-event-listener.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: EventListener
metadata:
  name: bump-dev-event-listener
spec:
  serviceAccountName: build-bot
  triggers:
  - name: bump-dev-trigger
    template:
      name: bump-dev-trigger-template
    bindings:
    - ref: bump-dev-trigger-binding
EOF
```{{execute}}

## Apply the trigger

```
kubectl apply -f bump-dev-trigger-template.yaml -f bump-dev-trigger-binding.yaml -f bump-dev-event-listener.yaml
```{{execute}}

## Test it out

Wait for the deployment to finish.

```
kubectl rollout status deployment/el-bump-dev-event-listener
```{{execute}}

Let's port-forward our service.

```
kubectl port-forward --address 0.0.0.0 svc/el-bump-dev-event-listener 8080:8080 2>&1 > /dev/null &
```{{execute}}

Now we can trigger a pull request event, which should create a new `PipelineRun`.

```
curl \
    -H 'Content-Type: application/json' \
    -d '{
          "push_data": {
            "tag": "1.0.0"
          }
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

