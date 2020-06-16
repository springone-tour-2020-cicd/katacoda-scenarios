# Promote to production

In this step, you will:
1. Introduce a prod environment
2. Duplicate the service and deployment yamls
3. Use `yq` to manipulate the YAML resources
4. Deploy the image to the prod environment and test it

## Introduce prod environment

Begin by creating a new namespace called `prod` that will serve as our production environment:

```
kubectl create namespace prod
```{{execute}}

## Duplicate the yamls

Your `deployment.yaml` and `service.yaml` files currently have a reference to the `dev` namespace, which needs to be changed for the production environment.

Start by making a production copy of your ops files.

```
mv ops ops-dev
cp -r ops-dev ops-prod
```{{execute}}

## Manipulate resources with `yq`

We need to change the namespace in the prod files. We could do this using `sed -i “s/dev/prod/g” deployment-prod.yaml`, but this is error prone. The `yq` command line tool is better suited for the job as it understands the yaml structure and can be used to make more controlled changes.

Run the following commands to update the value of the namespace field in the metadata section of the prod yaml files:

```
yq w -i ops-prod/deployment.yaml "metadata.namespace" "prod"
yq w -i ops-prod/service.yaml "metadata.namespace" "prod"
```{{execute}}

## Deploy and test

Deploy the image to the production namespace:

```
kubectl apply -f ops-prod
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
Stop the port-forwarding process:

```
pkill kubectl && wait $!
```{{execute}}
