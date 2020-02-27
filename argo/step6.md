# Deploy to production environment

Create a namespace

```
kubectl create namespace production
```{{execute}}
<br>


Create another ArgoCd 'Application' but this time using the `argocd` CLI

```
argocd app create spring-sample-app-production --repo https://github.com/markpollack/spring-sample-app-ops.git --path overlays/production --dest-namespace production --dest-server https://kubernetes.default.svc --sync-policy automated
```{{execute}}


## Try it out

```
kubectl -n production port-forward service/mark-service 81:80
```{{execute T1}}

Then curl the port-forwarded endpoint

```
curl localhost:81
```{{execute T2}}

Stop the port-forwarding by executing `# Ctrl-C`{{execute interrupt T1}}








