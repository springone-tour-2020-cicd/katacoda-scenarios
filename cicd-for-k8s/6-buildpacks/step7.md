# Use Argo CD to automate applying Image updates to kpack

Objective:

First instinct might be to extend the Tekton pipeline to apply the updated `image.yaml` file directly to Kubernetes. However, our workflow already includes a tool that is purpose-built, not to mention easier to configure, for applying manifests to Kubernetes: Argo CD. 

In this step, you will:
- Configure Argo CD to sync the kpack `image.yaml` file to the cluster

## Using Argo CD to trigger kpack

Go to the directory in the ops repo containing manifests for Argo CD. Recall that this directory currently contains two "Application" resources - one for go-sample-app deployment to dev, and another for go-sample-app deployment to prod.

```
cd /workspace/go-sample-app-ops/cicd/argo
ls
```{{execute}}

Create a new Argo CD "Application" for the `image.yaml` file. Notice that the repoURL points to your ops repo, which has all of your Kubernetes manifests, and specifically to the `cicd/kpack` subdirectory, which has the `image.yaml` and `builder.yaml` file. A change to either of these will trigger Argo CD to update the cluster, which in turn will trigger kpack. Pretty cool :-)

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
    path: cicd/kpack
    repoURL: https://github.com/${GITHUB_NS}/go-sample-app-ops.git
    targetRevision: HEAD
  syncPolicy:
    automated: {}
EOF
```{{execute}}

## Test the solution

In the next scenario, you will test the full solution, including this step. 