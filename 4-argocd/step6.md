# Deploy to production environment

Objective:
Use a declarative approach to deploy the sample application to the prod environment.

In this step, you will:
* Generate yaml files to represent the dev and prod Argo CD Application resources
* Use the prod resource to configure Argo CD
* Observe the deployment of the app to the prod environment
* Test the deployed application

## Configure the application in Argo CD for deployment to prod

For prod, we will use a declarative approach to create the application.

First, use the `argocd` CLI to extract the dev app spec programmatically and save it to a file:

```
mkdir /workspace/go-sample-app/cicd/argo
cd  /workspace/go-sample-app/cicd/argo

cat <<EOF >argo-deploy-dev.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: go-sample-app-dev
EOF

echo "$(argocd app get go-sample-app-dev -o yaml | yq r - spec | yq p - spec)" >> argo-deploy-dev.yaml
```{{execute}}

Make a copy of the file for prod, and replace 'dev' with 'prod' inside the file.
Review the file.
```
sed 's/dev/prod/g' argo-deploy-dev.yaml > argo-deploy-prod.yaml
yq r -C argo-deploy-prod.yaml
```{{execute}}

Apply the change.
```
kubectl apply -f argo-deploy-prod.yaml -n argocd
```{{execute}}

Go back to the UI and click on Applications in the breadcrumb on the upper left.
You should see a second tile, representing the prod deployment in the prod namespace.

## Try it out

```
kubectl rollout status deployment/prod-go-sample-app -n prod
kubectl port-forward service/prod-go-sample-app 8081:8080 -n prod 2>&1 > /dev/null &
APP_PID=$!
```{{execute}}

Send a request. Validate that the app responds with "Hello, sunshine!"

```
curl localhost:8081
```{{execute}}

The container should now have printed the environment variable for production.

```
kubectl logs $(kubectl get pods -n prod -o jsonpath="{.items[0].metadata.name}") -n prod
```{{execute}}

## Cleanup
Stop the port-forwarding process for our application.

```
kill ${APP_PID} && wait $!
```{{execute}}
