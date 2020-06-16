# ROUND 2 - make a code change and re-deploy

In this step, you will:
1. Make a code change to the app
2. Re-build the image
3. Update the ops yaml
4. Re-deploy the app and test it

## Make a code change to the app
Use the following command to change "Hello, world!" to "Hello, sunshine!":
```
sed -i '' 's/world/sunshine/g' go-sample-app/hello-server.go
```{{execute}}

## Re-build the image
Re-build the image:

```
pack build $IMG_NS/go-sample-app:1.0.0 \
     --path go-sample-app \
     --builder gcr.io/paketo-buildpacks/builder:base \
     --publish
```{{execute}}

## Update ops yamls
The only value that needs to be updated is the image digest:
```
IMG_SHA_OLD=$IMG_SHA
IMG_SHA=$(curl --silent -X GET https://hub.docker.com/v2/repositories/$IMG_NS/go-sample-app/tags/1.0.1 | jq '.images[].digest' -r); echo $IMG_SHA
sed -i '' "s|$IMG_SHA_OLD|$IMG_SHA|g" go-sample-app-ops/deployment.yaml
```{{execute}}

## Re-deploy the image
Even though only the `deployment.yaml` was updated, you can point to the whole ops directory to re-deploy. Kubernetes will only update the resources that changed:

```
kubectl apply -f go-sample-app-ops -n=dev
```{{execute}}

# Re-test the app

Set up port-forwarding again and test the app. This time, you should get a response of "Hello, sunshine!":
```
kubectl port-forward service/go-sample-app 8080:8080 -n=dev 2>&1 > /dev/null &
KPID="$!"
curl localhost:8080
```{{execute}}

## Cleanup
Stop the port-forwarding process:
```
kill $KPID
```{{execute}}