# ROUND 2 - make a code change and re-deploy

Objective:
Understand the basic workflow of deploying an **update** to the application using a declarative approach. In subsequent steps, we will continue to build on this flow.

In this step, you will:
1. Make a code change to the app
2. Re-build the image
3. Update the ops files
4. Deploy the new image & re-test

## Make a code change to the app
Use the following command to change "Hello, world!" to "Hello, sunshine!":

```
sed -i 's/world/sunshine/g' hello-server.go
```{{execute}}

## Re-build the image
Re-build the image and push it to the registry as version 1.0.1:

```
docker build . -t go-sample-app -t localhost:5000/apps/go-sample-app:1.0.1
docker push localhost:5000/apps/go-sample-app:1.0.1
```{{execute}}

## Update ops yamls
The only value in the ops files that needs to be updated is the image version in deployment.yaml:

```
sed -i 's|1.0.0|1.0.1|g' ops/deployment.yaml
```{{execute}}

## Re-deploy the image
This time, apply the _declarative_ definitions of the deployment and service. Kubernetes will update the resources that have changed (in this case, just the deployment):

```
kubectl apply -f ops
```{{execute}}

# Re-test the app

Set up port-forwarding again and test the app. This time you should get a response of "Hello, sunshine!":

```
kubectl port-forward service/go-sample-app 8080:8080 -n dev 2>&1 > /dev/null &
curl localhost:8080
```{{execute}}

## Cleanup

Stop the port-forwarding process:

```
pkill kubectl
```{{execute}}
