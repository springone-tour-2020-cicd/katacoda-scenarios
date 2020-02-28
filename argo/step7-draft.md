# With KNative

???

# YAML for an Argo CD App

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: spring-sample-app
spec:
  destination:
    namespace: production
    server: 'https://kubernetes.default.svc'
  source:
    path: overlays/production
    repoURL: 'https://github.com/springone-tour-2020-cicd/spring-sample-app-ops.git'
    targetRevision: HEAD
  project: default
  syncPolicy:
    automated:
      prune: false
      selfHeal: false

# WIP...

Play around with Argo CD UI. For example, click on the `pod` box in the graph and click `Delete`. Kubernetes will recreate the pod, and Argo CD will update the graph with the newly created pod.

Any change to the ops repo on GitHub will trigger ##### WIP...

Let's make a change and watch argo propagate it.

open app:

new dash, change port to 80, remove applications (or put link here)

Any change to gitops will trigger argo.

Let's change replicas.

Back to Argo, refresh, see two more pods.









