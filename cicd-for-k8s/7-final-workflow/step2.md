# Apply the resources you created to the cluster

Objective:

Apply all the CI/CD building blocks you created in the previous scenarios.

In this step, you will:
- Apply the Argo CD Application manifests
- Apply the kpack Cluster manifest
- Apply the Tekton Pipeline, Task, and TriggerTemplate manifests
- Set up port-forwarding to expose the Tekton trigger event listeners outside of the cluster

## Apply all CI/CD resource manifests

Go to the cicd directory in the ops repo and review the list of manifests to apply

```
cd /workspace/go-sample-app-ops/cicd
tree
```{{execute}}

Apply all manifests.

```
kubectl apply -f ./argo -n argocd
```{{execute}}

```
kubectl apply -f ./kpack
```{{execute}}

```
kubectl apply -f ./tekton
```{{execute}}

## Port-forward to Tekton's trigger event listeners

First, wait for the Tekton deployment to finish.

```
kubectl rollout status deployment/el-build-event-listener
kubectl rollout status deployment/el-ops-dev-event-listener
```{{execute}}

When a code change is pushed to the app repo, or when a new image is pushed to Docker Hub, GitHub and Docker Hub use webhooks to send events to the Tekton event listeners.
However, the Katacoda environment is not reachable from the internet, so we must set up local port-forwarding to the event listeners and simulate the webhooks locally.

Set up port-forwarding to the build event listener. Upon new app repo commits, this event listener will trigger the build workflow.

```
kubectl port-forward --address 0.0.0.0 svc/el-build-event-listener 8081:8080 2>&1 > /dev/null &
```{{execute T3}}

Set up port-forwarding to the ops-dev event listener. When a new image is published to Docker Hub, this event listener will trigger the deployment workflow.

```
kubectl port-forward --address 0.0.0.0 svc/el-ops-dev-event-listener 8082:8080 2>&1 > /dev/null &
```{{execute T4}}
