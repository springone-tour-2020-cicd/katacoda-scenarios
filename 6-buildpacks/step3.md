# Use kpack to build images

Objective:
Use kpack, together with Paketo Buildpacks, to build an image for the sample app.

In this step, you will:
- Install kpack
- Configure kpack to build images when there is a new commit on the app repo

## Install kpack

`kpack` is a Kubernetes-native buildpack platform that runs as a service.  It can pull code from a source code or artifact repository, build an OCI image, and publish the image to a Docker registry.

Install kpack to the kubernetes cluster:

```
kubectl apply -f https://github.com/pivotal/kpack/releases/download/v0.0.9/release-0.0.9.yaml
```{{execute}}

Review the output to see the list of resources created. Notice that it includes two deployments (`kpack-controller` and `kpack-webhook`) in a namespace called `kpack`. These deployment resources comprise the kpack service itself:

```
kubectl get all -n kpack
```{{execute}}

Wait until the status of the two pods is `Running`.

The installation also includes several Custom Resource Definitions (CRDs) that provide Kubernetes primitives to configure kpack:
```
kubectl api-resources --api-group build.pivotal.io
```{{execute}}

We'll be able to list kpack resources that we create by querying for these CRDs. We haven't created any yet, so we expect the following command to return an empty result:
```
kubectl get builders,builds,clusterbuilders,images,sourceresolvers --all-namespaces
```{{execute}}

## Configure kpack

To build an image for our sample app, we need to configure a 'kpack` Image resource with:
- the builder to use
- the source code on GitHub
- the repository on Docker Hub, with proper write access


## Miscellaneous

kpack provides a CLI tool called `logs` specifically for accessing logs produced during image builds. `logs` is pre-installed in this environment - you can validate that by running `logs --help`{{execute}}.
