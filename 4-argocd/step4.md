# Deploy to development deployment

Let's deploy our sample application.

We only have one Kubernetes cluster, so we will be deploying our app to the same cluster in which we installed Argo CD. You can also easily attach other clusters to Argo CD and use it to deploy apps to to those.

Create a namespace called `dev` to simulate a development environment for deployment:

```
kubectl create namespace dev
```{{execute}}

In the UI, click on `+ NEW APP`.

Fill in the form as follows, using details pertaining to your fork of the sample app. Make sure to replace the placeholder `GITHUB_NS` with the proper value. Leave any fields not mentioned below at their default value.
```
GENERAL
Application Name: go-sample-app-dev
Project: default
SYNC POLICY: Automatic

SOURCE
Repository URL: https://github.com/<GITHUB_NS>/go-sample-app.git
Revision: HEAD
Path: ops/overlays/dev

DESTINATION
Cluster: https://kubernetes.default.svc
Namespace: dev
```

The Kustomize files contain a reference to the app image, which Argo CD assumes has been created already:
```
head -n 4 go-sample-app/ops/overlays/dev/kustomization.yaml
```{{execute}}

Additionally, if you look through the contents of the repo, you'll see it specifies all of the necessary information that Kubernetes needs for deployment. By now you will have noticed that we've chosen to lay out our gitops yaml using Kustomize, which has advantages for re-use and simplicity at scale, but Argo CD would support other yaml file layouts as well.

Finally, note that the cluster we specified as our destination (aliased as  "in-cluster" by Argo CD by default) refers to the same cluster into which Argo CD is installed. It is possible to attach other clusters to Argo CD and deploy to those as well. Since we only have one cluster, we will just use the "in-cluster" option.

Before hitting 'CREATE', click on 'EDIT AS YAML'. Notice that you can define an application declaratively in yaml and create the app without using the UI.

Click 'CANCEL' to exit the yaml editor and then click 'CREATE' to create the app in Argo CD.

Wait till you see the new app appear. If you don't see it within a few moments, refresh the Dashboard tab.


## Try it out

Wait for the deployment to finish:

```
kubectl rollout status deployment/go-sample-app -n dev
```{{execute}}

Set up port-forwarding again and test the app:

```
kubectl port-forward service/go-sample-app 8080:8080 -n dev 2>&1 > /dev/null &
APP_PID=$!
```{{execute}}

Send a request. Validate that the app responds with "Hello, sunshine!"

```
curl localhost:8080
```{{execute}}

## Cleanup
Stop the port-forwarding process for our application.

```
kill -9 ${APP_PID} && wait $!
```{{execute}}

Let's explore what's happened...
