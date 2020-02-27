# Explore the deployment

If you refresh the Dashboard tab, you should eventually see the app health and status indicators turn green.

Click on the box that represents your app deployment. Green hearts mean healthy, green circles with checkmarks mean syncd with the gitops repo.

You should see a visual representation of all of the resources related to the app's deployment.

# Compare with Kubernetes

Take a look at the resources that were created in Kubernetes. Recall we specified the default namespace in our app configuration, so we can check for the resources created there:
```
kubectl get all
```{{execute}}

You should see a service, deployment, a replica set, and a pod.

Return to the Dashboard and identify the four boxes in the graph of app resources that correspond to these four resources. Note that each box has an icon on the left indicating the type of resource (`svc`, `deploy`, `rs`, and `pod`), and additional info pops up if you mouse over the box as well.

You can also use the argocd CLI to explore the app deployment:
```
argocd app list
```{{execute}}
and
```
argocd app get spring-sample-app
```{{execute}}



##### WIP...

Let's make a change and watch argo propagate it.

open app:

new dash, change port to 80, remove applications (or put link here)

Any change to gitops will trigger argo.

Let's change replicas.

Back to Argo, refresh, see two more pods.


###### DELETE ME

other sample app:
Sample app:
https://github.com/argoproj/argocd-example-apps.git




