# Deploy to development deployment

Objective:
Deploy the sample application to the dev environment.

In this step, you will:
* Configure the application in Argo CD
* Observe the deployment through the UI
* Observe the deployment through the `argocd` and `kubectl` CLIs
* Test the deployed application

## Configure the application in Argo CD for deployment to dev

There are several ways to configure an application in Argo CD.
You can use the UI, the CLI, or you can use kubectl to apply a YAML configuration of the Argo Application CRD.

We will review all three, but ultimately, we will use the declarative approach and save the YAML file in GitHub.

In the UI, click on `+ NEW APP`. Fill in the form as shown bellow.
Leave any fields not mentioned below at their default value.
Make sure to replace the placeholder `$GITHUB_NS` with the proper value.
Do **not** click on `CREATE` yet.

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

Note that since we only have one Kubernetes cluster, we are deploying the app to the same cluster in which Argo CD is installed (`in-cluster` or `https://kubernetes.default.svc` in the Argo CD configuration).
However, you can also attach other clusters and use Argo CD to deploy apps to those.

When you are finished entering the config values shown above, scroll up and click 'EDIT AS YAML'.
Review the configuration.

Go ahead and click `CREATE` in the UI.
However, we will also save the YAML to GitHub.
Run the following command create the YAML file.

```
mkdir -p /workspace/go-sample-app/cicd
cd  /workspace/go-sample-app/cicd
cat <<EOF >deploy-dev.yaml
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
```{{execute}}

Wait till you see the new Application appear in the UI.
If you don't see it within a few moments, refresh the Dashboard tab.

## Explore the deployment

Argo CD applies the configuration declared in the ops files to the Kubernetes cluster.
Thereafter, Kubernetes takes care of creating and managing the necessary resources.
If there is a change to the ops files, Argo CD re-applies the updated ops configuration.

If you refresh the Argo CD UI tab, you should eventually see the app health and status indicators turn green.

Click on the box that represents your app deployment.
Green hearts mean healthy, green circles with checkmarks mean synced with the ops files in the Git repository.

You should see a visual representation of all of the Kubernetes resources related to the app's deployment.
You should see the same resources you observed in earlier scenarios: a Service, a Deployment, a ReplicaSet, and a Pod (labeled `svc`, `deploy`, `rs`, and `pod` in Argo CD UI).
Mouse over the corresponding boxes to see a pop-up with additional info.

You will also see an Endpoint resource in Argo CD. Endpoints are not listed by `kubectl get all` command, but you can list them using `kubectl get endpoints`.

Validate the resources in Kubernetes:
```
kubectl get all -n dev
kubectl get endpoints -n dev
```{{execute}}

## Test the app

Wait for the deployment to finish:

```
kubectl rollout status deployment/go-sample-app -n dev
```{{execute}}

Set up port-forwarding to the app:

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

## Explore with argocd CLI

You can also use the argocd CLI to explore the app deployment:
```
argocd app list
```{{execute}}
and
```
argocd app get go-sample-app-dev
```{{execute}}

Finally, as we mentioned earlier, you can query for Argo CD Applications and ApplicationProjects:
```
kubectl get applications,appprojects -n argocd
```{{execute}}
