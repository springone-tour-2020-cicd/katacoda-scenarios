# Reconciliation Loop

Having declarative resources available in a Git repository gives us the ability to automatically sync an application when it detects differences between the desired manifests in Git, and the live state in the cluster.
We have demonstrated this with the Automatic Sync feature turned on.
Changes made in Git were automatically deployed to the cluster.
However, changes that are made to the live cluster will not trigger automated sync by default.
To enable automatic sync when the live cluster's state deviates from the state defined in Git, run the following command:

```
argocd app set go-sample-app-prod --self-heal
```{{execute}}

Now go ahead and delete the deployment from production.

```
kubectl delete deploy prod-go-sample-app -n prod
```{{execute}}

Argo CD will now detect the divergence, and try to reconcile the state of Git with the cluster.

You can verify the new deployment in the UI by clicking into the application `go-sample-app-prod` and clicking on `History and Rollback`. You should see two entries.

Having the self-healing capabilities allows us to recover from changes to the cluster that cannot be recovered by Kubernetes' own reconciliation.