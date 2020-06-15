In this step we will introduce the production environment to our application.
For this we will create a new namespace `prod`.

```
kubectl create namespace prod
```{{execute}}

Our `deployment.yaml` and `service.yaml` currently have a reference to the `dev` namespace, which should be changed for the production environment.
Let's start by making a production copy of our deployment and service yamls.

```
cp deployment.yaml deployment-prod.yaml
cp service.yaml service-prod.yaml
```{{execute}}

We need to change the namespace value in the metadata sections.
We can easily do this using `sed -i “s/dev/prod/g” deployment-prod.yaml`, although this is error prone.
The `yq` command line tool is better suited for the job as it understands the yaml structure.

```
yq w -i deployment-prod.yaml "metadata.namespace" "prod"
yq w -i service-prod.yaml "metadata.namespace" "prod"
```{{execute}}

Let's apply the changes to our Kubernetes cluster.

```
kubectl apply -f .
```{{execute}}

We can now test the production deployment.

```
kubectl port-forward service/go-sample-app 8080:8080 -n=prod 2>&1 > /dev/null &
```{{execute}}

Test the app. This time you should get a response of "Hello, sunshine!":
```
curl localhost:8080
```{{execute}}

## Cleanup

Stop the port-forwarding process:
```
pkill kubectl
```{{execute}}
```
We've now successfully deployed our application to our new production namespace.
However, we've duplicated our code and had to mess around with imperative find and replace.
It's not very clear what the differences are between the environments either.

Let's take a look at other solutions.

Kustomize allows us to declaratively specify the differences between environments, in a Kubernetes-native way using CRDs (Custom Resource Definitions).

Create the following directory structure:

It contains a `base` subdirectory and two `overlay` subdirectories, one for development and one for production.

```
$ tree
.
├── base
│   └── kustomization.yaml
└── overlays
    ├── dev
    │   ├── env.properties
    │   └── kustomization.yaml
    └── prod
        ├── env.properties
        └── kustomization.yaml
```

## Look at the directory structure

Open the file `/root/spring-sample-app-ops/overlay/dev/kustomization.yaml`

In that file refer to your container image and its version.

<br>
```
images:
  - name: markpollack/spring-sample-app  # used for Kustomize matching
    newName: <YOUR-DOCKERHUB-USERNAME>/spring-sample-app
    newTag: 1.0.0
```

Looking at this file there is a reference to the base kustomization directory to pull in the kustomization resource defined there.

```
resources:
  - ../../base
```

The file `/root/spring-sample-app-ops/base/kustomization.yaml`{{open}} contains a reference to the off-the-shelf customization hosted on GitHub.

```
resources:
  - github.com/kustomizations/spring-boot-web?ref=1.0.0
```


## Deploy to the development environment

Execute

```
kustomize build ./overlays/dev | kubectl apply -f -
```

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


## Deploy to the production environment

Now let's create a new namespace `production`

```
kubectl create namespace production
```{{execute}}

Verify it has been created

```
kubectl get namespaces
```{{execute}}

Execute

```
kustomize build ./overlays/production | kubectl apply -n production -f -
```

You can see the resources created by executing

```
watch kubectl get all -n production
```{{execute}}

Once the `STATUS` of the pod is `Running` state, Press `# Ctrl+C`{{execute interrupt T1}} to exit out of the watch.

Then look at the output from hitting the endpoint by using `curl` to access the `http` URL for your application's service that is returned from executing the command:

```
minikube service list
```{{execute}}

`curl`ing the endpoint, you will see the following profile in the response.

```
profile='production'
```

