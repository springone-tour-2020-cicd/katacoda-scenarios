# ROUND 1 - initial build & deploy

Objective:
Understand the basic workflow of deploying an application to Kubernetes. In subsequent steps, we will build on this basic flow.

In this step, you will:
- Clone a sample app repo
- Test the app locally
- Build an image for the app
- Publish the image to Docker Hub
- Create "ops" config files for deployment to Kubernetes
- Deploy to Kubernetes
- Test the deployed application

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

There are various ways to turn an app into an image, ranging from Dockerfile scripts to higher level abstractions. In this step, you will use a Dockerfile script included in the app repo. The `docker build` command will find the file called `Dockerfile` automatically. The build will pull a base image called 'golang' from Docker Hub, build the app into a binary, and then copy the binary into a minimal _scratch_-based final image.

```
docker build . -t go-sample-app
```{{execute}}

Docker saves the image to the local docker daemon by default. List it using the following command:

```
docker images | grep go-sample-app
```{{execute}}


## Publish image to a registry
The scenario environment is pre-configured with access to a Kubernetes cluster. In order to deploy the image to the cluster, you must publish the image to a registry that the cluster can access. For this purpose, we will use Docker Hub.

To publish the image to a registry, you need to assign it an alias (aka a tag) that includes the fully-qualified repository name (e.g. _docker.io/some_namespace/image_name_). The Docker Hub registry address (docker.io) is the default, so you simply need to add your namespace to the image name. It is also good practice to tag the image with a version.

 For convenience, start by setting the following environment variable to your Docker Hub namespace (your user or org name). You can copy and paste the following command into the terminal window, then delete the placeholder and replace it with your namespace:

```
IMG_NS=<YOUR_DH_NAMESPACE>
```{{copy}}

Next, log in to Docker Hub. At the prompt, enter your access token.

```
docker login -u $IMG_NS
```{{execute}}

Now, use the `docker tag` and `docker push` commands to publish the image to Docker Hub. Notice that we are assigning a version of `1.0.0` to the image.

```
docker tag go-sample-app $IMG_NS/go-sample-app:1.0.0
docker push $IMG_NS/go-sample-app:1.0.0
```{{execute}}

You can see the new repository created in the registry:

https://hub.docker.com/repository/docker/$IMG_NS/go-sample-app/tags

## Deploy image to Kubernetes
You are now ready to deploy the image to Kubernetes.

A deployment can be done _imperatively_ using a CLI and command-line options operating on running resources, or _declaratively_ using a config file that describes the desired deployment. The latter is aligned with an "infrastructure as code" methodology, wherein the config files serve as a blueprint and "source of truth" for deployments, and they enable configuration of any aspect of the resource (as opposed to being limited to those exposed through the CLI).

Using the following commands, you will create config files that express - or declare, as it were - the desired deployment. You will be using these declarative config files throughout this course. You'll notice that we are using imperative commands to create the yaml config files, but we are using the flags `--dry-run=client` and `-o yaml` to simply write the declarative configuration to a file rather than create any resources on Kubernetes.

First, create a yaml for a new namespace called `dev`:

```
mkdir ops
kubectl create namespace dev --dry-run=client -o yaml > ops/namespace.yaml
```{{execute}}

Then, create a yaml for the deployment. The deployment will eventually create three resources in Kubernetes: deployment, replica set, and pod.

```
kubectl create deployment go-sample-app --image=$IMG_NS/go-sample-app:1.0.0 -n dev --dry-run=client -o yaml > ops/deployment.yaml
```{{execute}}

In order to make the application accessible outside of the Kubernetes cluster, you need to expose it using a service. Run the following command to create the declarative definition of the service:

```
kubectl create service clusterip go-sample-app --tcp=8080:8080 -n dev --dry-run=client -o yaml > ops/service.yaml
```{{execute}}

You can review the declarative definitions of these resources:

```
cat ops/namespace.yaml
cat ops/deployment.yaml
cat ops/service.yaml
```{{execute}}

## Deploy & test the application

Apply the yaml files to Kubernetes:

```
kubectl apply -f ops/namespace.yaml
kubectl apply -f ops/deployment.yaml
kubectl apply -f ops/service.yaml
```{{execute}}

You can list the deployed resources using:

```
kubectl get all -n dev
```{{execute}}

You can also use the following command to wait until the deployment "rollout" succeeds:

```
kubectl rollout status deployment/go-sample-app -n dev
```{{execute}}

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
pkill kubectl && wait $!
```{{execute}}
