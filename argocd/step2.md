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

## Disable the Kustomize load restrictor

Kustomize v3 allows us to disable the [security check introduced in Kustomize v2](https://kubernetes-sigs.github.io/kustomize/faq/#security-file-foo-is-not-in-or-below-bar) that prevents kustomizations from reading files outside their own directory root.
This was meant to help protect the person inclined to download kustomization directories from the web and use them without inspection to control their production cluster.
In our case we can safely disable this feature and preserve our folder structure.

```
yq m <(kubectl get cm argocd-cm -o yaml -n argocd) <(cat << EOF
data:
  kustomize.buildOptions: --load_restrictor none
EOF
) | kubectl apply -f -
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