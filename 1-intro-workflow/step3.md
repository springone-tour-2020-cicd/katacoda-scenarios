# ROUND 3 - make the deployment environment-specific

In this step, you will:
1. Introduce a new environment
2. Duplicate the service and deployment yamls
3. Use `yq` to manipulate resources
4. Deploy both environments to Kubernetes and test it

## Introduce new environment

For the purpose of this lab we will simply create a new namespace `prod` which will act as our production environment.

```
kubectl create namespace prod
```{{execute}}

## Duplicate the yamls

Our `deployment.yaml` and `service.yaml` currently have a reference to the `dev` namespace, which should be changed for the production environment.
Let's start by making a production copy of our deployment and service yamls.

```
cd ops
cp deployment.yaml deployment-prod.yaml
cp service.yaml service-prod.yaml
```{{execute}}

## Manipulate resources with `yq`

We need to change the namespace value in the metadata sections.
We can easily do this using `sed -i “s/dev/prod/g” deployment-prod.yaml`, although this is error prone.
The `yq` command line tool is better suited for the job as it understands the yaml structure.

Let's first install `yq`.

```
wget -o- -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/3.3.2/yq_linux_amd64
chmod +x /usr/local/bin/yq
```{{execute}}

We can now update the namespace in the yaml files.

```
yq w -i deployment-prod.yaml "metadata.namespace" "prod"
yq w -i service-prod.yaml "metadata.namespace" "prod"
```{{execute}}

## Deploy and test

Let's apply the changes to our Kubernetes cluster.

```
kubectl apply -f .
```{{execute}}

We can now test the production deployment.

```
kubectl port-forward service/go-sample-app 8080:8080 -n prod 2>&1 > /dev/null &
```{{execute}}

Test the app.
```
curl localhost:8080
```{{execute}}

## Cleanup

Stop the port-forwarding process:
```
pkill kubectl
```{{execute}}

