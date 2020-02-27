# Install Argo CD

Let's begin by installing Argo CD to our Kubernetes cluster.

Create a namespace for our Argo CD installation:
```
kubectl create namespace argocd
```{{execute}}

Now, install Argo CD:
```
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```{{execute}}

Review the output to see the list of resources created. Notice that it includes a handful of deployments. You can get more info using:
```
kubectl get all -n argocd
```{{execute}}

Wait until the status of the pods is `Running`. Notice that none of the services have external IPs by default.

The installation also includes a couple of Custom Resource Definitions (CRDs), providing Kubernetes primitives for Argo CD concepts of Application and ApplicationProject. You can list these by running:
```
kubectl api-resources --api-group argoproj.io
```{{execute}}

You can always list resources created by Argo CD by querying for these CRDs. We haven't created any yet, so we expect the following command to return an empty result:
```
kubectl get applications,appprojects
```{{execute}}



Next, let's log in to Argo CD.