# Deploy to development environment

Objective:
Deploy the sample application to the dev environment.

In this step, you will:
* Configure the application in Argo CD
* Observe the deployment through the UI
* Observe the deployment through the `argocd` and `kubectl` CLIs
* Test the deployed application

## Configure the application in Argo CD for deployment to dev

There are several ways to configure an application in Argo CD. 
You can use the UI, the CLI, or you can use `kubectl` to apply a YAML configuration of the Argo Application CRD. 
We will review all three.

In the UI, click on `+ NEW APP`. Configure the app as shown below.
Leave any fields not mentioned below at their default value. 
Notice that the configuration points only to the ops YAML files. 
ArgoCD will apply these files to Kubernetes. 
These files contain everything Kubernetes needs to deploy the application.

When you are done configuring the new app, scroll up to the top of the form. 
You can click `EDIT AS YAML` to see the Application resource in YAML format. 
When you are ready, click `CREATE`.

```
GENERAL
Application Name: go-sample-app-dev
Project: default

SOURCE
Repository URL:  
Revision: HEAD
Path: ops/overlays/dev

DESTINATION
Cluster: https://kubernetes.default.svc
Namespace: dev
```
Note on `Cluster` field configuration: we are deploying the sample app into the same cluster where Argo CD is installed, but you can also attach other clusters as targets for app deployments.

As a point of information, the CLI command to create the same application would be:
```
> argocd app create go-sample-app-dev \
>        --repo https://github.com/${GITHUB_NS}/go-sample-app.git \
>        --path ops/overlays/dev \
>        --dest-namespace dev \
>        --dest-server https://kubernetes.default.svc
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

## Make an ops change

Make a change to the dev overlay configuration:
```
cd ops/overlays/dev
echo "namePrefix: dev-" >> kustomization.yaml
```{{execute}}

Check the change into GitHub. 
You will need to authenticate using your [Personal Access Token](https://github.com/settings/tokens):

```
git add -A
git commit -m 'add prefix dev-'
git push origin master
```{{execute}}

Go back to the UI, and wait (or refresh) until you Argo CD reports that the app is out of sync. 
You should see that the deployed application is still healthy (green hearts), but that the declared desired state is different from the actual runtime state (yellow circles). 
Do **not** click Sync again - we will trigger Argo to sync in a few steps.

You can explore the UI further to get a sense for the additional information and insight that Argo CD can provide.

You can also use the `argocd` CLI to explore the apps and their status:
```
argocd app list
```{{execute}}
and
```
argocd app get go-sample-app-dev
```{{execute}}

You should see that argocd reports on 4 resources: the service and deployment with the original names, and the service and deployment with the `dev-` prefix. 
It reports that two healthy and two two are missing, and that all are out of sync:

```
> GROUP  KIND        NAMESPACE  NAME               STATUS     HEALTH   HOOK  MESSAGE
>        Service     dev        go-sample-app      OutOfSync  Healthy        service/go-sample-app created
> apps   Deployment  dev        go-sample-app      OutOfSync  Healthy        deployment.apps/go-sample-app created
>        Service     dev        dev-go-sample-app  OutOfSync  Missing
> apps   Deployment  dev        dev-go-sample-app  OutOfSync  Missing

```

## Enable automatic sync

Rather than sync the app manually again, you can set the sync policy to 'Automatic'. 
Let's do this using the CLI:

```
argocd app set go-sample-app-dev --sync-policy automated
```{{execute}}

Check the app status again:

```
argocd app get go-sample-app-dev
```{{execute}}

Argo now reports that 4 resources are deployed, the old and the new. 
All are healthy, but two are still out of sync. 
Since the particular configuration change altered the name of the resources, in effect it created new resources, rather than updating the existing ones. 
Notice the message for the ones that are out of sync says that pruning is required. 

```
> GROUP  KIND        NAMESPACE  NAME               STATUS     HEALTH   HOOK  MESSAGE
> apps   Deployment  dev        go-sample-app      OutOfSync  Healthy        ignored (requires pruning)
>        Service     dev        go-sample-app      OutOfSync  Healthy        ignored (requires pruning)
>        Service     dev        dev-go-sample-app  Synced     Healthy        service/dev-go-sample-app created
> apps   Deployment  dev        dev-go-sample-app  Synced     Healthy        deployment.apps/dev-go-sample-app created
```

Enabling pruning tells ArgoCD to delete resources that are not reflected in the declared state (ops files). 
By default, and as a safety mechanism, automatic pruning is disabled. 
You can enable it for all syncs, or you can manually apply it for a single sync. 
Go back to the UI and click on 'SYNC'. 
In the pop-up, check the option to prune, then hit Synchronize. 
You should see the two older resources disappear.
