# Pruning

Objective:


Understand use cases where resources need to be deleted from the cluster

In this step, you will:
* Make an ops change that results in extraneous resources
* Observe the deployment through the UI
* Use a manual sync to remove the extraneous resources

## Make an ops change

Add a prefix for resource names in the dev overlay configuration:

```
#echo "namePrefix: dev-" >> ops/overlays/dev/kustomization.yaml
yq w -i ops/overlays/dev/kustomization.yaml namePrefix dev-
```{{execute}}

Check the change into GitHub.

```
git commit -am 'Add prefix dev-'
git push origin master
```{{execute}}

Go back to the UI, and wait (or refresh) until Argo CD reports that the app is out of sync.
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
All are healthy, but two are out of sync.
Since the particular configuration change altered the name of the resources, in effect it created new resources, rather than updating the existing ones.
Notice the message for the ones that are out of sync says that pruning is required.

```
> GROUP  KIND        NAMESPACE  NAME               STATUS     HEALTH   HOOK  MESSAGE
> apps   Deployment  dev        go-sample-app      OutOfSync  Healthy        ignored (requires pruning)
>        Service     dev        go-sample-app      OutOfSync  Healthy        ignored (requires pruning)
>        Service     dev        dev-go-sample-app  Synced     Healthy        service/dev-go-sample-app created
> apps   Deployment  dev        dev-go-sample-app  Synced     Healthy        deployment.apps/dev-go-sample-app created
```

Enabling pruning tells Argo CD to delete resources that are not reflected in the declared state (ops files).
By default, and as a safety mechanism, automatic pruning is disabled.
You can enable it for all syncs, or you can manually apply it for a single sync.
Go back to the UI and click on 'SYNC'.
In the pop-up, check the option to prune, then hit Synchronize.
You should see the two older resources disappear.

Once again, check the app status using the CLI:
```
argocd app get go-sample-app-dev
```{{execute}}
