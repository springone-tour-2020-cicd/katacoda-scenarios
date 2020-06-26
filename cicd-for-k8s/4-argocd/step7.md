# Self-Healing Reconciliation Loop

Objective:


Understand the use case for a self-healing sync.

In this step, you will:
* Enable automatic self-healing in Argo CD
* Create a change in the live deployment that Kubernetes would not recover
* Observe Argo CD heal the deployment based on the declared state

## Enable automatic self-healing

As we have seen in the previous steps, one benefit of GitOps is the ability to create or update the running state based on a change in the desired/declared state. 
Tools like Argo CD make it easy to do this automatically when the declared state is updated.

However, the running state may diverge from the declared state, even when no change has been made to the declarative manifests. 
For example, an emergency situation may arise wherein a change must be applied directly to the cluster. 
Such situations are not ideal, but they may be necessary and justifiable in some situations.

In these cases, Argo CD will also detect a divergence in state, but by default it will not automatically re-apply the declarative manifests to the cluster. This feature is called self-healing. As with automatic pruning, automatic self-healing is disabled by default, as a safety mechanism.

Enable automatic self-healing for the production application:

```
argocd app set go-sample-app-prod --self-heal
```{{execute}}

## Delete the prod deployment

Delete the deployment from production. By deleting the deployment, we are ensuring Kubernetes will not recreate it (as opposed to simply deleting a pod, for example, which Kubernetes would recreate).

```
kubectl delete deploy prod-go-sample-app -n prod
```{{execute}}

## Observe self-healing

Argo CD will detect the divergence and reconcile the actual state of the cluster with the state declared in the ops manifests.

You can verify the new deployment in the UI by clicking into the application `go-sample-app-prod` and clicking on `History and Rollback`. You should see two entries in the history.

Having the self-healing capabilities allows us to recover from changes to the cluster that cannot be recovered by Kubernetes' own reconciliation.
