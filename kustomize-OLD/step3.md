An [off-the-shelf configuration](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/glossary.md#off-the-shelf-configuration) is a kustomization and associated resources that are published in a location for shared use.  Think of it as a Maven repository but for Kubernetes resoruces.

Let's begin by changing into the `off-the-shelf` directory.

```
cd /workspace/kustomize-labs/off-the-shelf
```{{execute}}
<br>

Open the file `/workspace/kustomize-labs/off-the-shelf/kustomization.yaml`{{open}} in the editor.

The first field to look at is the `resources:` field which points to a GitHub repository and its version.  

```
resources:
  - github.com/kustomizations/spring-boot-web?ref=1.0.0
```

This is the reusable set of Kubernetes resource definitions that we will be 'customizing'.  In this case the resource definitions are for a Spring Web application that has actuator endpoints which will be used for liveliness and readiness probes.  

You can navigate to GitHub and [look at the off-the-shelf configuration](https://github.com/kustomizations/spring-boot-web).  It is very similar to what was used in the previous `simple` step of the tutorial.


The first change to the resource definitions is to refer to your own container image of your application and its version.

<br>
```
images:
  - name: markpollack/spring-sample-app  # used for Kustomize matching
    newName: <YOUR-DOCKERHUB-USERNAME>/spring-sample-app
    newTag: 1.0.0
```

**NOTE:** Replace `<YOUR-DOCKERHUB-USERNAME>` in this file with your Docker Hub user name and make sure you have an image with that tag on [DockerHub](dockerhub.com).

<br>


The next change adds a `namePrefix` to all resources, so they can be easily identified as belonging to you.  The `commonLabels` field will it will add the specified labels to all kubernetes resources.   

**NOTE:** Replace the label with your own value.

The last part of the `kustomization.yaml` file is showing one of the several [Generators](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/fields.md#generators) that `kustomize` supports.

 In this case, we are using a `configMapGenerator` that creates `ConfigMap` resources.  No surprise there.  In this case we are using the generator that reads key-value pairs from a properties file and will put those key-value pairs into the environment.  Editing a properties file is easier than adding the environment variables into a deployment YAML file.


will pull key-value pairs from the file `env.properties` and expose them as environment variables to the application running in the container.  

The `env.properties` file already contains the key-value pair `SPRING_PROFILES_ACTIVE=dev`.

**NOTE:** The `Deployment` resource in the off-the-shelf customization is expecting to reference a config map named `spring-configmap-env`.

## Create Resources and apply to cluster

The version of `kustomize` that is bundled with `kubectl` doesn't understand how to process the `envs` field of `configMapGenerator` so we will use the `kustomize` CLI directly to create the resource definitions and apply that to the cluster using `kubectl`

```
kustomize build . | kubectl apply -f -
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

`curl`ing the endpoint, you will see the following profile in the response.

```
profile='dev'
```

If you do not see the pod in the `Running` state, look at the logs and description of the pod to determine what went wrong.  You can easily delete all the resources created by issuing the following command

```
kubectl delete all -l app.kubernetes.io/name=spring-sample-app
```{{execute}}
<br>


Congrats! Now onto supporting different deployment environments.

