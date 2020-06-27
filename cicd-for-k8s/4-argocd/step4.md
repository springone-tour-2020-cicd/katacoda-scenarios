# Driving change through GitOps

Objective:


Show how any change to the ops repo on GitHub causes Argo CD to update the deployment.

In this step, you will:
* Update the ops manifest for dev to point to a new image
* Observe how Argo CD automatically drives the deployment
* Test the deployed application

# Deploy a new image

Let's simulate an application upgrade deployment. From previous scenarios, you should have the following two images in Docker Hub:
- "Hello, world!" (1.0.0)
- "Hello, sunshine!" (1.0.1)

Since "Hello, sunshine!" is currently deployed, let's update the tag to deploy version 1.0.0, "Hello, world!"

Change the tag value in the dev overlay configuration:

```
yq m -i -x ops/overlays/dev/kustomization.yaml - <<EOF
images:
  - name: ${IMG_NS}/go-sample-app  # used for Kustomize matching
    newTag: 1.0.0
EOF
```{{execute}}

Push the change to GitHub so Argo CD can detect it.

```
git commit -am "Switched back to 1.0.0"
git push origin master
```{{execute}}

Now sit back and watch Argo CD update the deployment.

## Test the app

Wait for the deployment to finish:

```
kubectl rollout status deployment/go-sample-app -n dev
```{{execute}}

Set up port-forwarding again and test the app:

```
kubectl port-forward service/go-sample-app 8081:8080 -n dev 2>&1 > /dev/null &
APP_PID=$!
```{{execute}}

Send a request. Validate that the app responds with "Hello, world!" again.

```
curl localhost:8081
```{{execute}}

## Cleanup
Stop the port-forwarding process for our application.

```
kill ${APP_PID} && wait $!
```{{execute}}
