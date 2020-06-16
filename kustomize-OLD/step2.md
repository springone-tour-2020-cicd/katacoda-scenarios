Let's begin by changing into the `simple` directory.


```
cd kustomize-labs/simple
```{{execute}}
<br>

The main file that drives Kustomize is `kustomization.yaml`  Open the file `/root/kustomize-labs/simple/kustomization.yaml`{{open}} in the editor.

The contents of `kustomization.yaml` are:

```
namePrefix: mark-
commonLabels:
  app.kubernetes.io/name: spring-sample-app
resources:
  - deployment.yaml
  - service.yaml
```
In this file there are a few top level [fields](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/fields.md) that you will often use. 
We will walk though this file line by line.

* The `namePrefix` field will prefix a string to the name of all the kubernetes resources processed by Kustomize.  In particular, this is useful if multiple users are sharing the same kubernetes namespace.  There are also corresponding `nameSuffix` field.
* The `commonLabels` field will apply the specified labels to all kubernetes resources processed by Kustomize.  This is useful for finding, visualization, and often deleting, resources that have a specific label.
* The `resources` field lists other files that will be processed by Kustomize.  In this case a fairly standard set of base Kubernetes resources, a Service and Deployment.

**NOTE:** In `deployment.yaml` the image used is `markpollack/spring-sample-app:1.0.0`.  Feel free to change it your forked version of the sample application hosted on Docker Hub.
**NOTE:** In `kustomization.yaml` feel free to change the `namePrefix` to your name.

## Create Resources and apply to cluster

You can see the output of running Kustomize on this file by executing the following command

```
kubectl apply -k . --dry-run=client -o yaml > manifest.yaml
```{{execute}}
<br>

Open the ``/root/kustomize-labs/simple/manifest.yaml`{{open}} in the editor and have a look around to see how the `namePrefix` and `commonLabels` field was used in the definition of the Kubernetes `Service` and `Deployment` resources. 

Now let's create the resources and apply them to the cluster.

```
kubectl apply -k .
```{{execute}}
<br>

You can see the resources created by executing

```
watch kubectl get all
```{{execute}}

Once the `STATUS` of the pod is `Running` state, Press `# Ctrl+C`{{execute interrupt T1}} to exit out of the watch.

Then look at the output from hitting the endpoint by using `curl` to access the `http` URL for your application's service that is returned from executing the command:

```
minikube service list
```{{execute}}


If you do not see the pod in the `Running` state, look at the logs and description of the pod to determine what went wrong.  You can easily delete all the resources created by issuing the following command

```
kubectl delete all -l app.kubernetes.io/name=spring-sample-app
```{{execute}}
<br>

Congrats! Now onto encapsulating this YAML in a reusable off-the-shelf kustomization.




