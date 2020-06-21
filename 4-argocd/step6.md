# Reconciliation Loop

Having declarative resources available in a Git repository gives us the ability to automatically sync an application when the desired manifests in Git are updated.
We have demonstrated this with the Automatic Sync feature turned on.
Changes made in Git were automatically deployed to the cluster.

However, the deployment in the cluster may diverge from the desired state declared in the Git manifests. One case may be an emergency change that must be applied to the live cluster. Such exceptions are not ideal, but they may be necessary and justifiable in some situations. In these cases, Argo CD will also detect a divergence in state, but by default it will not automatically re-apply the declarative manifests to the cluster.

This functionality can be enabled, but, just as with automatic pruning, it is disabled by default, as a safety mechanism.

To enable automatic sync when the live cluster's state deviates from the state defined in Git, run the following command:

```
argocd app set go-sample-app-prod --self-heal
```{{execute}}

Now go ahead and delete the deployment from production. By deleting the deployment, we are ensuring Kubernetes will not recreate it (as opposed to simply deleting a pod, for example, which Kubernetes woult recover).

```
kubectl delete deploy prod-go-sample-app -n prod
```{{execute}}

Argo CD will now detect the divergence, and try to reconcile the state of Git with the cluster.

You can verify the new deployment in the UI by clicking into the application `go-sample-app-prod` and clicking on `History and Rollback`. You should see two entries.

Having the self-healing capabilities allows us to recover from changes to the cluster that cannot be recovered by Kubernetes' own reconciliation.
