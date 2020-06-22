# Initial build & deploy

Objective:
Understand the basic workflow of deploying an application to Kubernetes. 
In subsequent steps, you will build on this basic flow.

In this step, you will:
- Clone a sample app repo
- Test the app locally
- Build an image for the app
- Publish the image to Docker Hub
- Create Kubernetes deployment manifests
- Deploy to Kubernetes
- Test the deployed application

## Clone app repo
You will be working with a sample app that is publicly available on GitHub.

Start by cloning the app repo and listing the contents. 
The app is a simple application written in Go.

```
git clone https://github.com/springone-tour-2020-cicd/go-sample-app.git && cd go-sample-app
ls
```{{execute}}

## Test app

Test it locally to see how it behaves. First, start the 'hello-server' process in the background:

```
go run hello-server.go 2>&1 > /dev/null &
```{{execute}}

Next, send a request. Validate that the app responds with "Hello, world!" (if it fails initially, give the server a couple of seconds to finish starting up, and try again).

```
curl localhost:8080
```{{execute}}

Stop the app:

```
pkill hello-server && wait $!
```{{execute}}

## Build app image

In order to deploy the app to Kubernetes, it needs to be packaged as a container image.

There are various ways to turn an app into an image, ranging from Dockerfile scripts to higher level abstractions. 
In this step, you will use a Dockerfile script included in the app repo. 
The `docker build` command will find the file called `Dockerfile` automatically. 
The build will pull a base image called 'golang' from Docker Hub, build the app into a binary, and then copy the binary into a minimal _scratch_-based final image.

```
docker build . -t go-sample-app
```{{execute}}

Docker saves the image to the local docker daemon by default. List it using the following command:

```
docker images | grep go-sample-app
```{{execute}}


## Publish image registry

The scenario environment is pre-configured with access to a Kubernetes cluster. 
In order to deploy the image to the cluster, you must publish the image to a registry that the cluster can access. 
For this purpose, we will use Docker Hub.

To publish the image to a registry, you need to assign it an alias (aka a tag) that includes the fully-qualified repository name (e.g. _docker.io/some_namespace/image_name_). 
The Docker Hub registry address (docker.io) is the default, so you simply need to add your namespace to the image name, which is already saved in $IMG_NS. 
It is also good practice to tag the image with a version.

Log in to Docker Hub. At the prompt, enter your access token.

```
docker login -u $IMG_NS
```{{execute}}

Now, use the `docker tag` and `docker push` commands to publish the image to Docker Hub. 
Notice that we are assigning a version of `1.0.0` to the image.

```
docker tag go-sample-app $IMG_NS/go-sample-app:1.0.0
docker push $IMG_NS/go-sample-app:1.0.0
```{{execute}}

Navigate to your account on [Docker Hub](https://hub.docker.com) to see the published image.

## Create Kubernetes manifests

A deployment can be done _imperatively_ using a CLI and command-line options operating on running resources, or _declaratively_ using a config file that describes the desired deployment. 
Imperative commands describe how to arrive at a desired state, and the command options are limited to those exposed through the CLI, whereas the declarative approach consists of configuration manifests that express - or declare, as it were - the desired state itself, serving as a blueprint and "source of truth" for a running system. 
Configuration file also make it possible to configure any aspect of a given resource.
The declarative approach follows the methodology of "infrastructure as code" and is the approuch you will use here.

Using the following commands, you will create configuration manifests for a Kubernetes `deployment` and `service`. The deployment resource will deploy and manage the pod in which the application will run, and the service will make the application accessible outside of the cluster.
 
You'll notice that, as a convenience, we are leveraging imperative commands to create the manifests, but we are using the flags `--dry-run=client` and `-o yaml` to simply write the configuration to a yaml file rather than create any resources on the cluster.

Create a manifest for the deployment. 

```
mkdir ops
kubectl create deployment go-sample-app --image=$IMG_NS/go-sample-app:1.0.0 -n dev --dry-run=client -o yaml > ops/deployment.yaml
```{{execute}}

Create a manifest for the service. 

```
kubectl create service clusterip go-sample-app --tcp=8080:8080 -n dev --dry-run=client -o yaml > ops/service.yaml
```{{execute}}

Review the generated manifests:

```
cat ops/deployment.yaml
cat ops/service.yaml
```{{execute}}

## Deploy app to Kubernetes

You are now ready to deploy the application to Kubernetes.

Creating a namespace called `dev`, matching the namespace that was included in the dry-run commands above:

```
kubectl create ns dev
```{{execute}}

Apply the yaml files to Kubernetes:

```
kubectl apply -f ops
```{{execute}}

You can use the following command to wait until the deployment "rollout" succeeds:

```
kubectl rollout status deployment/go-sample-app -n dev
```{{execute}}

You can list the deployed resources using. At this point the deployment and pod `READY` column should show `1/1`.

```
kubectl get all -n dev
```{{execute}}

## Test deployed app

To test the app, you can use port-forwarding to forward traffic from a local endpoint (e.g. localhost:8080) to the service you just created. 
Run the following command to start a port-forwarding process in the background:

```
kubectl port-forward service/go-sample-app 8080:8080 -n dev 2>&1 > /dev/null &
```{{execute}}

Send a request. 
Validate that the app responds with "Hello, world!"

```
curl localhost:8080
```{{execute}}

## Cleanup

Stop the port-forwarding process:

```
pkill kubectl && wait $!
```{{execute}}
