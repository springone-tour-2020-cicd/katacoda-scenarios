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
go run hello-server &
curl localhost:8080
```{{execute}}

Stop the app:

```
pkill hello-server
```{{execute}}

## Build app image
There are various ways to turn an app into an image. In this step, you will use the Dockerfile included in the app repo to build the image. The `docker build` command will find the file called `Dockerfile` automatically:

```
docker build . -t go-sample-app
```{{execute}}

Docker saves the image to the local docker daemon by default. List it using the following command:

```
docker images | grep go-sample-app
```{{execute}}

# Publish app image
Next, publish the image to a registry so that it is accessible for deployment to Kubernetes. There is a Docker registry running on the local docker daemon, listening on port 5000. We will use this registry for now.

To publish the image to a registry, you first need to name the image using the registry and repository information. It is also good practice to use a version tag. Run the following commands to rename and publish (aks tag and push) the image:

```
docker tag go-sample-app localhost:5000/apps/go-sample-app:1.0.0
docker push localhost:5000/apps/go-sample-app:1.0.0
```{{execute}}

You can see the image has been uploaded to the registry:

```
curl http://localhost:5000/v2/apps/go-sample-app/tags/list
```{{execute}}

## Deploy image to Kubernetes
The scenario environment is pre-configured with access to a Kubernetes cluster. Start by creating a namespace to deploy the app image:

```
kubectl create ns dev
```{{execute}}

Next, deploy the image. Use the `-o yaml` option to write the deployment yaml to a file at the same time.

```
mkdir ops
kubectl create deployment go-sample-app --image=localhost:5000/apps/go-sample-app:1.0.0 -n dev -o yaml > ops/deployment.yaml
```{{execute}}

`kubectl create` is an _imperative_ way to create a deployment. You can list the resources that comprise the deployment using:

```
kubectl get all -n dev
```{{execute}}

The `deployment.yaml` file contains the declarative definition of the deployment. Take a look using:

```
cat ops/deployment.yaml
```{{execute}}

In order to make the application accessible outside of the Kubernetes cluster, we need to expose it using a service. Run the following command to create the service _imperatively_ and save the _declarative_ definition of the service at the same time:

```
kubectl expose deployment go-sample-app --port 8080 --target-port 8080 -n dev -o yaml > ops/service.yaml
```{{execute}}

We will be using the deployment and service YAML files in the next step. Before moving on the the next step, let's test the deployed application.

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
