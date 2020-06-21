# The entire flow

Objective:
You now have all the necessary building blocks to put entire build and deploy pipeline together.

## Deploy Argo CD applications

First of all, instruct Argo CD to automatically keep our CI/CD pipeline, including the updated `Image` from the previous step, in sync with the cluster.
#### TODO: folder structure

```
cd ../cicd
cat <<EOF >argo-deploy-image.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: go-sample-app-image
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  project: default
  source:
    path: kpack
    repoURL: https://github.com/andreasevers/go-sample-app-ops.git
    targetRevision: HEAD
  syncPolicy:
    automated: {}
EOF
```{{execute}}

Now apply all the Argo CD configuration to the cluster.

```
kubectl create ns dev
kubectl create ns prod
kubectl create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl apply -f . -n argocd
```{{execute}}

## Deploy Tekton pipelines

Make sure all the pipelines are deployed.

```
cd ../tekton
kubectl apply -f .
```{{execute}}

## Test it out

Wait for the deployment to finish.

```
kubectl rollout status deployment/el-build-event-listener
kubectl rollout status deployment/el-ops-dev-event-listener
```{{execute}}

Let's port-forward our service.

```
kubectl port-forward --address 0.0.0.0 svc/el-build-event-listener 8080:8080 2>&1 > /dev/null &
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

## Port-forward the Argo CD Server

Wait until Argo CD is fully initialized. This may take a few minutes.

```
kubectl rollout status deployment/argocd-server -n argocd
```{{execute}}

In order to expose the Argo CD API endpoint (`argocd-server`) so that you can reach it using the argocd CLI and UI, set up port-forwaring:

```
kubectl port-forward --address 0.0.0.0 svc/argocd-server 8080:80 -n argocd 2>&1 > /dev/null &
```{{execute}}

## Log in using the argocd CLI

First, we need to obtain login credentials. The default admin username is `admin`.
In order to get the default admin password, run:
```
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```{{execute}}

## Log in using the Argo CD UI

Click on the tab titled `Argo CD UI`.
This tab is pointing to localhost:8080, so it should open the Argo CD dashboard UI.
Click the refresh icon at the top of the tab if it does not load automatically.

Alternatively, you can click on the link below and open in a separate tab in your browser:

https://[[HOST_SUBDOMAIN]]-8080-[[KATACODA_HOST]].environments.katacoda.com

Enter the same credentials you used for the CLI.
