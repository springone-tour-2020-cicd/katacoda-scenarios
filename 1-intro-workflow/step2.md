# ROUND 2 - make a code change and re-deploy

In this step, you will:
1. Make a code change to the app
2. Re-build the image
3. Update the ops yaml
4. Re-deploy the app and test it

## Make a code change to the app
Use the following command to change "Hello, world!" to "Hello, sunshine!":
```
cd /workspace/go-sample-app
sed -i 's/world/sunshine/g' hello-server.go
```{{execute}}

## Re-build the image
Re-build the image and push it to Docker Hub as version 1.0.1:

```
CGO_ENABLED=0 go build -i -o hello-server
docker build . -t go-sample-app
docker tag go-sample-app $IMG_REPO/go-sample-app:1.0.1
docker push $IMG_REPO/go-sample-app:1.0.1
```{{execute}}

## Update ops yamls
The only value that needs to be updated is the image digest in deployment.yaml:
```
IMG_SHA_OLD=$IMG_SHA
IMG_SHA=$(curl --silent -X GET https://hub.docker.com/v2/repositories/$IMG_REPO/go-sample-app/tags/1.0.1 | jq '.images[].digest' -r)
sed -i "s|$IMG_SHA_OLD|$IMG_SHA|g" /workspace/go-sample-app-ops/deployment.yaml
```{{execute}}

## Re-deploy the image
Even though only the `deployment.yaml` was updated, you can point to the whole ops directory to re-deploy. Kubernetes will only update the resources that changed:

```
kubectl apply -f /workspace/go-sample-app-ops -n=dev
```{{execute}}

# Re-test the app

Set up port-forwarding again and test the app:

```
kubectl port-forward service/go-sample-app 8080:8080 -n=dev 2>&1 > /dev/null &
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