# Deploy to development environment

Objective:


Deploy the sample application to the dev environment.

In this step, you will:
* Configure the application in Argo CD
* Manually sync the ops files with the cluster
* Observe the deployment
* Test the deployed application
* Enable automatic sync

## Configure the application in Argo CD for deployment to dev

There are several ways to configure an application in Argo CD.
You can use the UI, the CLI, or you can use `kubectl` to apply a YAML configuration of the Argo Application CRD.
We will review the UI and CLI approaches in this step, and the declarative approach in an upcoming step.

In the UI, click on `+ NEW APP`. Configure the app as shown below.
Leave any fields not mentioned below at their default value.
Notice that the configuration points only to the ops YAML files.
Argo CD will apply these files to Kubernetes.
These files contain everything Kubernetes needs to deploy the application.

When you are done configuring the new app, scroll up to the top of the form.
You can click `EDIT AS YAML` to see the Application resource in YAML format.
When you are ready, click `CREATE`.

```
GENERAL
Application Name: go-sample-app-dev
Project: default

SOURCE
Repository URL: https://github.com/<GITHUB_NS>/go-sample-app.git
Revision: HEAD
Path: ops/overlays/dev

DESTINATION
Cluster: https://kubernetes.default.svc
Namespace: dev
```
Note on `Cluster` field configuration: we are deploying the sample app into the same cluster where Argo CD is installed, but you can also attach other clusters as targets for app deployments.

As a point of information, the CLI command to create the same application would be:
```
argocd app create go-sample-app-dev \
       --repo https://github.com/${GITHUB_NS}/go-sample-app.git \
       --path ops/overlays/dev \
       --dest-namespace dev \
       --dest-server https://kubernetes.default.svc
```

## Sync and review the application

You should see a tile appear representing the application you just created.
Refresh the page if it doesn't appear on its own.

The app tile status should be "OutOfSync", reflected also in the yellow coloring.
This means that the ops files declare a state that is not reflected in the cluster, which is expected since the application has not yet been deployed to the cluster.
Since we left the 'Sync Policy' at the default value of 'Manual', Argo CD is not automatically applying the ops files to Kubernetes.

Click on the Sync icon on the app tile, then click 'Synchronize' in the pop-up.
The tile should turn green, and the status should show that the app is healthy (green heart) and synced (green circle with checkmark).

## Explore the deployment

Click on the box that represents your app deployment.
You should see a visual representation of the Kubernetes resources related to the app's deployment.
Mouse over the corresponding boxes to see a pop-up with additional info; click on the boxes to see even more information.

Validate the resources in Kubernetes:
```
kubectl get all -n dev
kubectl get endpoints -n dev
kubectl get endpointslice -n dev
```{{execute}}

## Test the app

Set up port-forwarding to the app:

```
kubectl port-forward service/go-sample-app 8081:8080 -n dev 2>&1 > /dev/null &
APP_PID=$!
```{{execute}}

Send a request. Validate that the app responds with "Hello, sunshine!"

```
curl localhost:8081
```{{execute}}

## Cleanup
Stop the port-forwarding process for our application.

```
kill ${APP_PID} && wait $!
```{{execute}}

## Enable automatic sync

To avoid having to sync manually in the future, set the sync policy to 'Automatic'. You can do this through the UI or the CLI.

```
argocd app set go-sample-app-dev --sync-policy automated
```{{execute}}
