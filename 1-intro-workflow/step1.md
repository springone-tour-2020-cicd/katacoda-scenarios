# ROUND 1 - initial build & deploy

Objective:
Understand the basic workflow of deploying an application to Kubernetes. In subsequent steps, we will build on this basic flow.

In this step, you will:
- Clone a sample app repo
- Test the app locally
- Build an image for the app
- Publish the image to Docker Hub
- Deploy the app to Kubernetes
- Save the deployment definitions as yaml-formatted "ops" files
- Test the deployed app

## Local environment setup
Please wait until `Environment ready!` appears in the terminal window.

## Clone app repo
We will be working with a sample app that is publicly available on GitHub.

Start by cloning the app repo and listing the contents:

```
git clone https://github.com/springone-tour-2020-cicd/go-sample-app.git /workspace/go-sample-app
cd /workspace/go-sample-app
ls
```{{execute}}

This is a simple "hello world" app written in Go. Test it locally by running the following commands to start the 'hello-server' process in the background and send a request. Validate that the app responds with "Hello, world!":

```
go run hello-server.go &
curl localhost:8080
```{{execute}}

Stop the app:

```
pkill hello-server
```{{execute}}

## Build app image
In order to deploy the app to Kubernetes, it needs to be packaged as a container image.

There are various ways to turn an app into an image, ranging from Dockerfile scripts to higher level abstractions. In this step, you will use the Dockerfile script included in the app repo. The `docker build` command will find the file called `Dockerfile` automatically:

```
docker build . -t go-sample-app
```{{execute}}

Docker saves the image to the local docker daemon by default. List it using the following command:

```
docker images | grep go-sample-app
```{{execute}}


## Publish image to a registry
The scenario environment is pre-configured with access to a Kubernetes cluster. In order to deploy the image to the cluster, you must publish the image to an registry that the cluster can access. For this purpose, we will use Docker Hub.

To publish the image to a registry, you need to assign it an alias (a.k.a. a tag) that includes the registry address and the repository name. It is also good practice to tag the image with a version. The Docker Hub registry address is the default, so you can simply tag the image using the repository name and a version.

First, for convenience, copy the following command to the terminal and replace `<YOUR_DH_USERNAME>` with your Docker Hub username:

```
IMG_REPO=<YOUR_DH_USERNAME>
```{{copy}}

Next, log in to Docker Hub. At the prompt, enter your access token.

```
docker login -u $IMG_REPO
```{{execute}}

Now, use the `docker tag` and `docker push` commands to publish the image to Docker Hub:

```
docker tag go-sample-app $IMG_REPO/go-sample-app:1.0.0
docker push $IMG_REPO/go-sample-app:1.0.0
```{{execute}}

You can see the new repository created in the registry:

https://hub.docker.com/repository/docker/$IMG_REPO/go-sample-app/tags

## Deploy image to Kubernetes
You are now ready to deploy the image to Kubernetes. Start by creating a new `dev` namespace:

```
kubectl create ns dev
```{{execute}}

A deployment can be done _imperatively_ or _declaratively_. In the following steps, you will do the initial deployment imperatively and, at the same time, save the deployment definition to a file in order to do it declaratively in the future. 

Run the following `kubectl create` command to deploy the image and save the declarative configuration to a file:

```
mkdir ops
kubectl create deployment go-sample-app --image=$IMG_REPO/go-sample-app:1.0.0 -n dev -o yaml > ops/deployment.yaml
```{{execute}}

The deployment creates three Kubernetes resources: deployment, replica set, and pod. You can list the deployed resources using:

```
kubectl get all -n dev
```{{execute}}

Re-run the above command every few seconds until the deployment status is 1/1.

Review the declarative definition of these resources in the `deployment.yaml` file using:

```
cat ops/deployment.yaml
```{{execute}}

In order to make the application accessible outside of the Kubernetes cluster, we need to expose it using a service. Run the following command to create the service _imperatively_ and save the _declarative_ definition of the service at the same time:

```
kubectl expose deployment go-sample-app --port 8080 --target-port 8080 -n dev -o yaml > ops/service.yaml
```{{execute}}

We will be using the deployment and service YAML files in subsequent steps. Before moving on the the next step, let's test the deployed application.

## Test the app
To test the app, you can use port-forwarding to forward traffic from a local endpoint (e.g. localhost:8080) to the service you just created. Run the following command to start a port-forwarding process in the background andd send a request to the app. Validate that the app responds with "Hello, world!":

```
kubectl port-forward service/go-sample-app 8080:8080 -n dev 2>&1 > /dev/null &
curl localhost:8080
```{{execute}}

## Cleanup
Stop the port-forwarding process:

```
pkill kubectl
```{{execute}}
