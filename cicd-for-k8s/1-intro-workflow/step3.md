# Make a code change and re-deploy

Objective:


Understand the basic workflow of deploying an **update** to the application.

In this step, you will:
1. Make a code change to the app
2. Re-build the image
3. Update the deployment manifests
4. Deploy the new image & re-test

## Make a code change to the app

Use the following command to change "Hello, world!" to "Hello, sunshine!":

```
sed -i 's/world/sunshine/g' hello-server.go
```{{execute}}

## Re-build the image

Re-build the image and push it to the registry as version 1.0.1:

```
docker build . -t go-sample-app -t $IMG_NS/go-sample-app:1.0.1
docker push $IMG_NS/go-sample-app:1.0.1
```{{execute}}

## Update the deployment manifests

The only value in the ops files that needs to be updated is the image version in deployment.yaml:

```
sed -i 's|1.0.0|1.0.1|g' ops/deployment.yaml
```{{execute}}

## Re-deploy the image

You can run `kubectl apply` using the directory containing the ops files:

```
kubectl apply -f ops
```{{execute}}

## Re-test the app

Once again, wait for the deployment to finish:

```
kubectl rollout status deployment/go-sample-app -n dev
```{{execute}}

Set up port-forwarding again and test the app:

```
kubectl port-forward service/go-sample-app 8080:8080 -n dev 2>&1 > /dev/null &
```{{execute}}

Send a request.  This time you should get a response of "Hello, sunshine!"

```
curl localhost:8080
```{{execute}}

## Cleanup

Stop the port-forwarding process:

```
pkill kubectl && wait $!
```{{execute}}
