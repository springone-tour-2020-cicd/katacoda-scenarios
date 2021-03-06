# Install and configure Argo CD

Objective:


Install and configure Argo CD.

In this step, you will:
* Install Argo CD and review the installation
* Configure options for handling of `kustomize`-based ops files
* Expose Argo CD API outside of the Kubernetes cluster
* Log in through the `argocd` CLI as well as the UI

## Install Argo CD

Create a namespace for the Argo CD installation, and install:

```
kubectl create ns argocd
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

By default, kustomize restricts kustomizations from reading files outside of their own directory root (more info [here](https://kubernetes-sigs.github.io/kustomize/faq/#security-file-foo-is-not-in-or-below-bar)).
This security check is meant to encourage people to inspect kustomization directories they may download from the internet before incorporating them into their deployments.
In our case, we can safely disable this feature and preserve our folder structure. To ensure this configuration is applied when we reinstall Argo CD, save it as a declarative manifest:

```
yq m <(kubectl get cm argocd-cm -o yaml -n argocd) <(cat << EOF
data:
  kustomize.buildOptions: --load_restrictor none
EOF
) | kubectl apply -f -
```{{execute}}

## Port-forward the Argo CD Server

Wait until Argo CD is fully initialized. This may take a few minutes.

```
kubectl rollout status deployment/argocd-server -n argocd
```{{execute}}

In order to expose the Argo CD API endpoint (`argocd-server`) so that you can reach it using the argocd CLI and UI, set up port-forwarding:

```
kubectl port-forward --address 0.0.0.0 svc/argocd-server 8080:80 -n argocd 2>&1 > /dev/null &
```{{execute}}

## Log in using the argocd CLI

The following commands will log you in through the `argocd` CLI.
```
ARGOCD_PASSWORD="$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)" && echo -e "Your ArgoCD password is:\n${ARGOCD_PASSWORD}"
argocd login localhost:8080 --insecure --username admin --password "${ARGOCD_PASSWORD}"
```{{execute T1}}

You will also need to use the UI in this scenario. 
Click on the tab titled `Argo CD UI`. 
This tab is pointing to localhost:8080, so it should open the Argo CD dashboard UI. 
Click the refresh icon at the top of the tab if it does not load automatically.

Alternatively, you can click on the link below and open in a separate tab in your browser:

https://[[HOST_SUBDOMAIN]]-8080-[[KATACODA_HOST]].environments.katacoda.com

Log in using the username _admin_ and password that was echoed to the terminal.
