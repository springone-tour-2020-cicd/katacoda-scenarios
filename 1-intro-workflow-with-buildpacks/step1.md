# ROUND 1 - initial build & deploy

In this step, you will:
1. Clone a sample app repo
2. Build an image for the app and publish the image to Docker Hub
3. Create the ops yaml files for the image
4. Deploy the app to Kubernetes and test it

Please wait until `Environment ready!` appears in the terminal window.

## Clone app repo
The [hub CLI](https://hub.github.com/hub.1.html) enables you to clone and fork GitHub repos from the command line. Use the `hub clone` command to clone the sample application, a simple "Hello World" app written in Go. You will need to enter your GitHub username and access token at the prompts:

```
hub clone springone-tour-2020-cicd/go-sample-app
```{{execute}}

## Build app image
There are various ways to build an image from source code, ranging from Dockerfile to higher level abstractions. In this scenario, you will use [buildpacks](https://buildpacks.io). Specifically, you will use the [pack CLI](https://github.com/buildpacks/pack), together with [Paketo Buildpacks](https://github.com/paketo-buildpacks).

You will build the image and publish it to Docker Hub on one easy step, but first, you must log in to Docker Hub.

Copy the following command to the terminal and replace the placeholder with your Docker Hub namespace:

```
IMG_NS=<YOUR_DH_USERNAME_OR_ORG>
```{{copy}}

Next, log in to Docker Hub and enter your access token at the prompt:
docker login -u $IMG_NS

Now, use the `pack build` command to build the image. The `builder` will produce the image, and the `--publish` flag instructs `pack` to publish the image to the registry:

```
pack build $IMG_NS/go-sample-app:1.0.0 \
     --path go-sample-app \
     --builder gcr.io/paketo-buildpacks/builder:base \
     --publish
```{{execute}}

## Create ops files (yamls) for deployment to Kubernetes
Start by creating a namespace to deploy the application:

```
kubectl create ns dev
```{{execute}}

Next, create a directory in which to save the ops files:

```
mkdir go-sample-app-ops
cd go-sample-app-ops
```{{execute}}

You could use the image tag from above (1.0.0) to deploy the image, but let's use the image digest instead. Use the following command to get the image digest:

```
IMG_SHA=$(curl --silent -X GET https://hub.docker.com/v2/repositories/$IMG_NS/go-sample-app/tags/1.0.0 | jq '.images[].digest' -r)
echo $IMG_SHA
```{{execute}}

Use the `kubectl create` command to create the deployment yaml file. The `--dry-run=client` option just creates the yaml file without deploying the image to Kubernetes:

```
kubectl create deployment go-sample-app --image=$IMG_NS/go-sample-app@$IMG_SHA --dry-run=client -o yaml > go-sample-app-ops/deployment.yaml
```{{execute}}

The `deployment.yaml` will create a Kubernetes deployment, replica set, and pod(s). You will also need to create a service, so that you can expose the application via an accessible IP address.

Use the `kubectl create` command to create the service yaml file. In orer to do so, you must first deploy the image to Kubernetes:

```
kubectl apply -f go-sample-app-ops/deployment.yaml -n=dev
kubectl expose deployment go-sample-app --port=8080 --target-port=8080 --dry-run=client -o yaml > go-sample-app-ops/service.yaml
```{{execute}}

## Test the app
To test the app, you must also deploy the service:
```
kubectl apply -f go-sample-app-ops/service.yaml -n=dev
```{{execute}}

The service exposes the app outside of the cluster. You can now use port-forwarding to forward traffic from `localhost:8080`. for example, to the service you just created. Use the `kubectl port-forward` command, as follows. We will run the port-forwarding in the background so that we can test the app in this same terminal window:

```
kubectl port-forward service/go-sample-app 8080:8080 -n=dev 2>&1 > /dev/null &
KPID="$!"
```{{execute}}

Now, test the app. You should get a response of "Hello, world!":
```
curl localhost:8080
```{{execute}}

## Cleanup
Stop the port-forwarding process:
```
kill $KPID
```{{execute}}
