# Deploy to production environment

Create a namespace called `production` to simulate a production environment for deployment:

```
kubectl create namespace production
```{{execute}}

Create another Argo CD 'Application', this time using the `argocd` CLI:
```
argocd app create spring-sample-app-production --repo https://github.com/${GITHUB_NS}/spring-sample-app-ops.git --path overlays/production --dest-namespace production --dest-server https://kubernetes.default.svc --sync-policy automated
```{{execute}}

Go back to the UI and click on `Applications`. You should see the new applicaiton there.

## Try it out
```
kubectl -n production port-forward service/mark-service 81:80
```{{execute T1}}

Then curl the port-forwarded endpoint
```
curl localhost:81
```{{execute T2}}

You should see output such as:
```
"hello, world.  {app name='spring-sample-app', version='1.0.0', profile='production'}
```

In this case the value of the profile is coming from the env properties file in the `overlays/production ` directory that we specified when creating the Application:
```
echo ""
cat spring-sample-app-ops/overlays/production/env.properties
```{{execute}}

Stop the port-forwarding by executing `# Ctrl-C`{{execute interrupt T1}}








