# ROUND 1 - initial build & deploy

Objective:
Understand the basic workflow of deploying an application to Kubernetes. In subsequent steps, we will build on this basic flow.

In this step, you will:
- Clone a sample app repo
- Test the app locally
- Build an image for the app
- Publish the image to Docker Hub
- Deploy the image to Kubernetes
- Save the deployment definitions as yaml-formatted "ops" files
- Test the deployed app

## Local environment setup
Please wait until `Environment ready!` appears in the terminal window.

## Clone app repo
We will be working with a sample app that is publicly available on GitHub.

Start by cloning the app repo and listing the contents. The app is a simple application written in Go.

```
git clone https://github.com/springone-tour-2020-cicd/go-sample-app.git /workspace/go-sample-app
cd /workspace/go-sample-app
ls
```{{execute}}

Test it locally to see how it behaves. First, start the 'hello-server' process in the background:

```
go run hello-server.go &
```{{execute}}

Next, send a request. Validate that the app responds with "Hello, world!"

```
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
The scenario environment is pre-configured with access to a Kubernetes cluster. In order to deploy the image to the cluster, you must publish the image to a registry that the cluster can access. For this purpose, we will use Docker Hub.

To publish the image to a registry, you need to assign it an alias (aka a tag) that includes the registry address and the repository name. It is also good practice to tag the image with a version. The Docker Hub registry address is the default, so you can simply tag the image using the repository name and a version.

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

A deployment can be done _imperatively_ using a command and command-line options, or _declaratively_ using a config file that describes the desired deployment. The latter is aligned with an "infrastructure as code" methodology, where the config files serve as a blueprint for deployments.

Using the following commands, you will create config files that describe - or declare, as it were - the desired deployment. You will be using these declarative config files throughout this course. One trick for creating the config files to use the imperative command with flags `--dry-run` and `-o yaml` to simply write the declarative configuration to a file rather than create any resources on Kubernetes.

First, create the deployment yaml:

```
mkdir ops
kubectl create deployment go-sample-app --image=$IMG_REPO/go-sample-app:1.0.0 -n dev --dry-run -o yaml > ops/deployment.yaml
```{{execute}}

Review the declarative definition of these resources in the `deployment.yaml` file using:

```
cat ops/deployment.yaml
```{{execute}}

Apply the yaml file to deploy the image to Kubernetes:

```
kubectl apply ops/deployment.yaml
```{{execute}}

The deployment creates three Kubernetes resources: deployment, replica set, and pod. You can list the deployed resources using:

```
kubectl get all -n dev
```{{execute}}

Re-run the above command every few seconds until the deployment status is 1/1.

In order to make the application accessible outside of the Kubernetes cluster, you need to expose it using a service. Run the following command to create the declarative definition of the service, and then apply that configuration to the cluster:

```
kubectl expose deployment go-sample-app --port 8080 --target-port 8080 -n dev --dry-run -o yaml > ops/service.yaml
kubectl apply ops/service.yaml
```{{execute}}

## Test the app
To test the app, you can use port-forwarding to forward traffic from a local endpoint (e.g. localhost:8080) to the service you just created. Run the following command to start a port-forwarding process in the background:

```
kubectl port-forward service/go-sample-app 8080:8080 -n dev 2>&1 > /dev/null &
```{{execute}}

Send a request. Validate that the app responds with "Hello, world!"

```
curl localhost:8080
```{{execute}}

## Cleanup
Stop the port-forwarding process:

```
pkill kubectl
```{{execute}}
