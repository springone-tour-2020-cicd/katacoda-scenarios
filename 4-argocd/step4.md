# Deploy to development deployment

Objective:
Deploy the sample application to the dev environment.

In this step, you will:
* ...

## Configure the dev app deployment

In the UI, click on `+ NEW APP`.

Fill in the form as shown bellow. Make sure to replace the placeholder `GITHUB_NS` with the proper value. Leave any fields not mentioned below at their default value. When you are finished entering the config values shown below, scroll up and click 'CREATE'.

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

Wait till you see the new app appear. If you don't see it within a few moments, refresh the Dashboard tab.

Note that since we only have one Kubernetes cluster, we are deploying the app to the same cluster in which Argo CD is installed (`in-cluster` or `https://kubernetes.default.svc` in the ArgoCD configuration). However, you can also attach other clusters and use Argo CD to deploy apps to to those.

The ops files you created earlier contain all of the necessary information that Kubernetes needs for deployment. ArgoCD simply needs to apply them to the Kubernetes cluster. As you can observe, ArgoCD supports the use of kustomize to compose yaml files.

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

## Save ArgoCD app config as YAML

The app configuration can also be declared as YAML:
```
mkdir -p /workspace/go-sample-app/cicd
cd  /workspace/go-sample-app/cicd
cat <<EOF deploy-dev.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: go-sample-app-dev
spec:
  destination:
    namespace: dev
    server: 'https://kubernetes.default.svc'
  source:
    path: ops/overlays/dev
    repoURL: 'https://github.com/${GITHUB_NS}/go-sample-app.git'
    targetRevision: HEAD
  project: default
  syncPolicy:
    automated:
      automated:
        prune: false
        selfHeal: false
EOF
```

# WIP TODO CLEANUP:
, click on 'EDIT AS YAML'. Notice that you can define an application declaratively in yaml and create the app without using the UI.
Click 'CANCEL' to exit the yaml editor and then click 'CREATE' to create the app in Argo CD.

Let's explore what's happened...
