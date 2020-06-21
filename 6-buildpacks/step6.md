# The entire flow

Objective:
You now have all the necessary building blocks to put entire build and deploy pipeline together.

## Deploy Argo CD

First of all, instruct Argo CD to automatically keep our CI/CD pipeline, including the updated `Image` from the previous step, in sync with the cluster.
#### TODO: folder structure

```
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
```{{execute}}

Apply all the Argo CD configuration to the cluster.

```
kubectl create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl apply -f
```{{execute}}
