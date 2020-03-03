# Install kpack

Let's begin by installing kpack to our kubernetes cluster:
```
kubectl apply -f https://github.com/pivotal/kpack/releases/download/v0.0.6/release-0.0.6.yaml
```{{execute}}

Review the output to see the list of resources created. Notice that it includes two deployments (`kpack-controller` and `kpack-webhook`) in a namespace called `kpack`. These deployment resources comprise the kpack service itself:
```
kubectl get all -n kpack
```{{execute}}

Wait until the status of the two pods is `Running`.

The installation also includes several Custom Resource Definitions (CRDs) that give us Kubernetes primitives to configure kpack to pull code from a source code or artifact repository, build an OCI image, and publish the image to a Docker registry:
```
kubectl api-resources --api-group build.pivotal.io
```{{execute}}

We'll be able to list kpack resources that we create by querying for these CRDs. We haven't created any yet, so we expect the following command to return an empty result:
```
kubectl get builders,builds,clusterbuilders,images,sourceresolvers
```{{execute}}


Next, let's configure kpack to build images for our sample app.