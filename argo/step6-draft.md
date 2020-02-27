### With KNative

???


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



 argocd app create spring-sample-app-production --repo https://github.com/markpollack/spring-sample-app-ops.git --path overlays/production --dest-namespace production --dest-server https://kubernetes.default.svc
