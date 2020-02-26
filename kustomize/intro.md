

The [Kustomize](https://kustomize.io/) project provides a template-free way to customize application configuration.  It is built into `kubectl` using the command `apply -k` and also as a standalone `kustomize` executable.

In this tutorial you will learn how to use several features of Kustomize to deploy a Spring Boot application to Kubernetes.

After this tutorial you will have:

* Used a simple kustomization to understand the basic feature set that is available.
* Used an `off-the-shelf` kustomization to better manage the the base set of Kubernetes resources that will be deployed. 
* Deployed the same Spring Boot application to multiple environments, with different resource specifications per environment.

Let's begin!

