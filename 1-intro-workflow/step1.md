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
hub clone springone-tour-2020-cicd/go-sample-app /workspace/go-sample-app
```{{execute}}

## Build app image
There are various ways to build an image from source code, ranging from Dockerfile to higher level abstractions. In this scenario, you will build the app locally and package it into an image using a simple Dockerfile.

First build the app locally:
```
cd /workspace/go-sample-app
CGO_ENABLED=0 go build -i -o hello-server
```{{execute}}

Test out the app locally. Start the process in the background, send a request, and then kill the process. The hello-server process should respond with "Hello, world!":

```
./hello-server &
curl localhost:8080
pkill hello-server
```{{execute}}

Next, create a Dockerfile to package the app binary into an image. The Dockerfile simply needs to copy the binary into the image and set the app launch command:
```
cat <<EOF >Dockerfile
FROM scratch
COPY hello-server /
ENTRYPOINT ["/hello-server"]
EOF
```{{execute}}

Now, build the image. The Dockerfile will be used by default:
```
docker build . -t go-sample-app
```{{execute}}

The image is in the local Docker daemon:

```
docker images | grep go-sample-app
```{{execute}}

 To publish it to Docker Hub, you first need to tag the image appropriately and authenticate against Docker Hub.

First, copy the following command to the terminal and replace `<YOUR_DH_USERNAME>` with your Docker Hub username:

```
IMG_REPO=<YOUR_DH_USERNAME>
```{{copy}}

Log in to Docker Hub and enter your access token at the prompt:

```
docker login -u $IMG_REPO
```{{execute}}

Now, use the `docker tag` and `docker push` to publish the image with a versioned tag to Docker Hub::

```
docker tag go-sample-app $IMG_REPO/go-sample-app:1.0.0
docker push $IMG_REPO/go-sample-app:1.0.0
```{{execute}}

## Create ops files for deployment to Kubernetes
Start by creating a namespace to deploy the application:

```
kubectl create ns dev
```{{execute}}

Next, create a directory in which to save the ops files:

```
mkdir ops
cd ops
```{{execute}}

You could use the image tag from above (1.0.0) to deploy the image, but let's use the image digest instead. Use the following command to get the image digest:

```
IMG_SHA=$(curl --silent -X GET https://hub.docker.com/v2/repositories/$IMG_REPO/go-sample-app/tags/1.0.0 | jq '.images[].digest' -r)
echo $IMG_SHA
```{{execute}}

Use the `kubectl create` command to create the deployment yaml file. The `--dry-run` option just creates the yaml file without deploying the image to Kubernetes:

```
kubectl create deployment go-sample-app --image=$IMG_REPO/go-sample-app@$IMG_SHA -n dev --dry-run -o yaml > deployment.yaml
```{{execute}}

The `deployment.yaml` defines the Kubernetes deployment, including replica set and pod. You will also need to create a service, so that you can expose the application via an accessible IP address.

Use the `kubectl create` command to create the service yaml file. In orer to do so, you must first deploy the image to Kubernetes:

```
kubectl apply -f deployment.yaml
kubectl expose deployment go-sample-app --port 8080 --target-port 8080 -n dev --dry-run -o yaml > service.yaml
```{{execute}}

## Test the app
To test the app, you must also deploy the service:
```
kubectl apply -f service.yaml -n=dev
```{{execute}}

The service exposes the app outside of the cluster. You can now use port-forwarding to forward traffic from `localhost:8080`. for example, to the service you just created. Use the `kubectl port-forward` command, as follows. We will run the port-forwarding in the background so that we can test the app in this same terminal window:

```
kubectl port-forward service/go-sample-app 8080:8080 -n dev 2>&1 > /dev/null &
```{{execute}}

Now, test the app. You should get a response of "Hello, world!":
```
curl localhost:8080
```{{execute}}

## Cleanup
Stop the port-forwarding process:
```
pkill kubectl
```{{execute}}
