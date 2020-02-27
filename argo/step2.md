# Install Argo CD

Let's begin by installing Argo CD to our Kubernetes cluster.

Create a namespace for our Argo CD installation:
```
kubectl create namespace argocd
```{{execute}}

Install Argo CD:
```
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```{{execute}}


### What was installed?

Review the output of `kubectl apply` command to see the list of resources created. Notice that it includes a handful of deployments. You can get more info using:
```
kubectl get all -n argocd
```{{execute}}

The installation also includes a couple of Custom Resource Definitions (CRDs), providing Kubernetes primitives for Argo CD concepts of Application and ApplicationProject. You can list these by running:
```
kubectl api-resources --api-group argoproj.io
```{{execute}}

You can always list resources created by Argo CD by querying for these CRDs. We haven't created any yet, so we expect the following command to return an empty result:
```
kubectl get applications,appprojects
```{{execute}}

### Expose Argo CD Server

Notice in the output of the `kubectl get all` command above that none of the services have EXTERNAL-IPs assigned. `argocd-server` is the API endpoint with which the CLI and UI will communicate, so it makes sense to expose the corresponding service. To do so, run the following command:
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```{{execute}}

Watch the progress on the change by running the following command. As soon as you see a value assigned to EXTERNAL-IP, type <kbd>Ctrl</kbd>+<kbd>C</kbd> to continue.
```
kubectl get service argocd-server -n argocd --watch
```{{execute}}

Finally, for convenience, let's save the new EXTERNAL-IP in the following environment variable:
```
export ARGOCD_SERVER=`kubectl get service argocd-server -n argocd -o json | jq --raw-output .status.loadBalancer.ingress[0].ip`
echo "ARGOCD_SERVER=$ARGOCD_SERVER"
```{{copy}}

As a final sanity check, you can make sure all Argo CD pods are in `Running` state:
```
kubectl get pods -n argocd
```{{execute}}



Next, let's log in to Argo CD.