# Install Argo CD

Let's begin by installing Argo CD to our Kubernetes cluster.

Create a namespace for our Argo CD installation:
```
kubectl create namespace argocd
```{{execute}}

Install Argo CD:
```
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```{{execute}}


## What was installed?

Review the output of the `kubectl apply` command to see the list of resources created. Notice that it includes a handful of deployments. You can get more info using:
```
kubectl get all -n argocd
```{{execute}}

The installation also includes a couple of Custom Resource Definitions (CRDs), providing Kubernetes primitives for Argo CD concepts of Application and ApplicationProject. You can list these by running:
```
kubectl api-resources --api-group argoproj.io 
```{{execute}}

You can always list resources created by Argo CD by querying for these CRDs. We haven't created any yet, so we expect the following command to return an empty result:
```
kubectl get applications,appprojects -n argocd
```{{execute}}

## Port-forward the Argo CD Server

`argocd-server` is the API endpoint with which the CLI and UI will communicate, so it makes sense to port-forward the corresponding service. To do so, run the following command:
```
kubectl rollout status deployment/argocd-server -n argocd
kubectl port-forward --address 0.0.0.0 svc/argocd-server 8080:80 -n argocd 2>&1 > /dev/null &
```{{execute}}

As a final sanity check, you can make sure all Argo CD pods are in `Running` state:
```
kubectl get pods -n argocd
```{{execute}}



Great! We're ready to begin using Argo CD.