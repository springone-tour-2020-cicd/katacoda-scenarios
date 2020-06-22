# Promote to production

Objective:
Understand the basic workflow of **promoting** a deployment to a downstream environment.

In this step, you will:
1. Introduce a production environment
2. Create production manifests
3. Deploy the image to prod and test

## Introduce production environment

Create a namespace called `prod` that will serve as the production environment:

```
kubectl create ns prod
```{{execute}}

## Create production manifests

Your `deployment.yaml` and `service.yaml` files contain a reference to the `dev` namespace,.
This value must be set to `prod` to deploy to the production environment.

Start by making a copy of the existing manifests.

```
cd ops
cp deployment.yaml deployment-prod.yaml
cp service.yaml service-prod.yaml
```{{execute}}

There are several ways to change the value of the namespace in the prod files. One common approach for manipulating files is `sed` (for example, `sed -i '' "s/dev/prod/g" *-prod.yaml`), but this is error prone. It is more suitable to use a tool like `yq` that understands yaml structure and therefore enables you to make more controlled changes.

Run the following commands to update the value of the metadata.namespace nodes in the prod yaml files:

```
yq w -i deployment-prod.yaml "metadata.namespace" "prod"
yq w -i service-prod.yaml "metadata.namespace" "prod"
```{{execute}}

## Deploy and test

Deploy the app to the production namespace by applying the new manifests to the cluster:

```
kubectl apply -f deployment-prod.yaml
kubectl apply -f service-prod.yaml
```{{execute}}

Wait for the deployment to finish:

```
kubectl rollout status deployment/go-sample-app -n prod
```{{execute}}

Set up port-forwarding again and test the app:

```
kubectl port-forward service/go-sample-app 8080:8080 -n prod 2>&1 > /dev/null &
```{{execute}}

Send a request. Validate that the app responds with "Hello, sunshine!"

```
curl localhost:8080
```{{execute}}

## Cleanup

Stop the port-forwarding process and return to the app's root directory:

```
pkill kubectl && wait $!
cd ..
```{{execute}}
