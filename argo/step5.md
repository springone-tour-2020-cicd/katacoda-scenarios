# Explore the deployment

If you refresh the Dashboard tab, you should eventually see the app health and status indicators turn green.

Click on the box that represents your app deployment. Green hearts mean healthy, green circles with checkmarks mean syncd with the gitops repo.

You should see a visual representation of all of the resources related to the app's deployment.

# Compare with Kubernetes

Take a look at the resources that were created in Kubernetes. Recall we specified the default namespace in our app configuration, so we can check for the resources created there:
```
kubectl get all -n dev
```{{execute}}

You should see a service, deployment, a replica set, and a pod.

Return to the Dashboard and identify the four boxes in the graph of app resources that correspond to these four resources. Note that each box has an icon on the left indicating the type of resource (`svc`, `deploy`, `rs`, and `pod`), and additional info pops up if you mouse over the box as well.

You will also see a ConfigMap and an Endpoint in Argo CD that were not listed by the `kubectl get all` command. This is because `kubectl get all` does not return these resource types, but you can replace `all` with the type to see them.

# Explore with argocd CLI

You can also use the argocd CLI to explore the app deployment:
```
argocd app list
```{{execute}}
and
```
argocd app get spring-sample-app-dev
```{{execute}}

Finally, as we mentioned earlier, you can query for Argo CD Applications and ApplicationProjects:
```
kubectl get applications,appprojects -n argocd
```{{execute}}