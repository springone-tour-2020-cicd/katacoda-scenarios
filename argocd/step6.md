# Deploy to production environment

Create a namespace called `prod` to simulate a production environment for deployment:

```
kubectl create namespace prod
```{{execute}}

Create another Argo CD 'Application', this time using the `argocd` CLI:
```
argocd app create go-sample-app-prod --repo https://github.com/${GITHUB_NS}/go-sample-app.git --path ops/overlays/prod --dest-namespace prod --dest-server https://kubernetes.default.svc --sync-policy automated
```{{execute}}

Go back to the UI and click on `Applications`. You should see the new application there.

## Try it out

```
kubectl port-forward service/go-sample-app 8080:8080 -n dev 2>&1 > /dev/null &
APP_PID=$!
```{{execute}}

Send a request. Validate that the app responds with "Hello, sunshine!"

```
curl localhost:8080
```{{execute}}

## Cleanup
Stop the port-forwarding process for our application.

```
kill -9 ${APP_PID} && wait $!
```{{execute}}



