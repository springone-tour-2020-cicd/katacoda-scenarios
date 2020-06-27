
The second one will track changes in Tekton manifests, including your pipelines.

```
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