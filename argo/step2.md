# Install Argo CD

Let's begin by creating a namespace for our ArgoCD installation:
```
kubectl create namespace argocd
```{{execute}}


Now, install ArgoCD:
```
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```{{execute}}

ArgoCD includes a Dashboard. In order to use it, let's assign an external IP address to the correspondning service:
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```{{execute}}

Watch the progress on the change by running the following command. As soon as you see a value assigned to EXTERNAL-IP, hit <kbd>Ctrl</kbd>+<kbd>C</kbd> to continue.
```
kubectl get service argocd-server -n argocd --watch
```{{execute}}

Click on the tab titled `Dashboard`. This tab is defaulting to localhost:80 in the tutorial environment, so it will automatically open the ArgoCD dashboard UI.

You can also use the following link if you prefer to open the UI in a separate browser tab:

https://[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com

Next, let's log in!
