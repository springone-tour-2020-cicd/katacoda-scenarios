# Just for fun...

You are done with the  workflow!

For fun, before concluding this scenario, create a new Application in Argo CD pointing to the `cicd/tekton` directory in the ops repo.

```
cd /workspace/go-sample-app-ops/cicd/argo

cat <<EOF >argo-deploy-tekton.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: tekton
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  project: default
  source:
    path: cicd/tekton
    repoURL: https://github.com/${GITHUB_NS}/go-sample-app-ops.git
    targetRevision: HEAD
  syncPolicy:
    automated: {}
EOF
```{{execute}}

Apply this manifest to the cluster
```
k apply -f argo-deploy-tekton.yaml
```{{execute}}

## Log in using the Argo CD UI

Take a look at the various Argo CD Applications.
You'll notice Argo CD now also tracks and visualizes all the Tekton resources.
