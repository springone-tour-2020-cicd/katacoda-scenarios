# Register your kubernetes cluster with Argo CD

Next, let's register the Kubernetes cluster with Argo CD, so that it can deploy apps to it.

Run the following command:
```
argocd cluster add
```{{execute}}

The available clusters are displayed. These are being read from your local kubectl config file, which was pre-configured when Kubernetes and kubectl were pre-installed into the tutorial environment.

The output should look something like this:
```
ERRO[0000] Choose a context name from:
CURRENT  NAME                         CLUSTER     SERVER
*        kubernetes-admin@kubernetes  kubernetes  https://172.17.0.63:6443
``````

Copy the value under the NAME column, and use it to register the cluster:
```
argocd cluster add <CLUSTER_NAME>
```{{copy}}

For example:
`argocd cluster add kubernetes-admin@kubernetes`

This command installs a ServiceAccount named argocd-manager into the kube-system namespace of the corresponding kubectl context and binds the service account to an admin-level ClusterRole. Argo CD uses this service account token to perform its management tasks (i.e. deploy/monitoring).

Switch back to UI and click on the gear icon on left side of the screen. Click on Clusters. You should see your cluster attached.