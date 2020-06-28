# Test the end-to-end workflow

Objective:

Run and validate the workflow end-to-end.

In this step, you will:
- Make a code change to go-sample-app to generate a new git commit id
- Send the new git commit if to the Tekton event listener in the cluster
- Observer the workflow automatically process the change end-to-end

## Test it out

Make a change to your go-sample-app application and watch the change flow through the workflow.

First push an application code change to GitHub:

```
cd /workspace/go-sample-app
sed -i 's/friends/pipeline/g' hello-server.go
git add hello-server.go
git commit -m "Hello pipeline!"
git push origin master
```{{execute}}

Obtain the commit id (SHA) and send a webhook using the local port-forwarded _build_ event-listener. This will trigger Tekton to create a new PipelineRun. 

```
SHA=$(git rev-parse origin/master)

curl \
    -H 'X-GitHub-Event: pull_request' \
    -H 'Content-Type: application/json' \
    -d '{
      "repository": {"clone_url": "'"https://github.com/${GITHUB_NS}/go-sample-app"'"},
      "pull_request": {"head": {"sha": "'"${SHA}"'"}}
    }' \
localhost:8081
```{{execute}}

Verify the `PipelineRun` executes without any errors.

```
tkn pipelinerun list
tkn pipelinerun logs -f
```{{execute}}

By the end of the Tekton build pipeline run execution, you should see new commit in your ops repo with an updated cicd/kpack/image.yaml.

## Validate that Argo CD deploys the updated image.yaml

Argo CD will immediately notice the new ops `image.yaml` and apply it to Kubernetes.

Open Argo CD UI using the browser tab in the scenario and navigate to the Argo CD Application tile that corresponds to the image. Confirm that Argo CD reports a deployment in the lcuster.

## Validate that kpack builds the image

As soon as Argo CD applies the update image.yaml to the cluster, kpack will build an image for that app code revision.

A new build should kick off automatically.

```
kubectl get builds
```{{execute}}

You can also track the progress of the build using the commands you used earlier:

Update the LATEST_BUILD and BUILD_NR env vars
```
LATEST_BUILD=$(kubectl get builds -o yaml | yq r - "items[-1].metadata.name") \
             && echo "Latest build: ${LATEST_BUILD}"
BUILD_NR=$(kubectl get builds -o yaml | yq r - "items[-1].metadata.labels.[image.build.pivotal.io/buildNumber]")
echo "LATEST_BUILD=${LATEST_BUILD}"
echo "BUILD_NR=${BUILD_NR}"
```{{execute}}

```
kubectl describe build ${LATEST_BUILD}
```{{copy}}

```
kubectl describe build ${LATEST_BUILD} | grep Revision
kubectl describe build ${LATEST_BUILD} | grep reason | head -1
```{{execute}}

```
kubectl get pods | grep ${LATEST_BUILD}
```{{execute}}

```
logs -image go-sample-app -build ${BUILD_NR}
```{{execute}}

When the build completes, you should see a new image on your [Docker Hub](https://hub.docker.com) account.

## Simulate a webhook from Docker Hub

Now we can simulate an image pushed event, which should create a "ops-dev" new `PipelineRun`.

Get the tag of the last image that was published and send it to the ops-dev event listener in the cluster.

```
TAG=$(logs -image go-sample-app -build $BUILD_NR | grep kpack- | grep index.docker.io | cut -d ":" -f2)

curl \
   -H 'Content-Type: application/json' \
   -d '{
         "push_data": {
           "tag": "'"${TAG}"'"
         }
       }' \
localhost:8082
```{{execute}}

Validate that the new `PipelineRun` executes without any errors.

```
tkn pipelinerun list
tkn pipelinerun logs -f
```{{execute}}

When the Tekton pipeline completes, Tekton will update the tag in the go-sampl-app deployment.yaml file, and push the change to the ops repo on GitHub.

Once Tekton pushes the change to GitHub, Argo CD will detect the change and apply the updated app deployment manifest to Kubernetes.

Go to the Argo CD UI and validate that Argo CD has applied the updated manifest and that the application has been deployed to Kubernetes.

```
kubectl get deploy -n dev

kubectl rollout status deployment/dev-go-sample-app -n dev
```{{execute}}

# Test the app

Your code change is now deployed to your dev environment!

Set up port-forwarding to your deployed application and test the app:

```
kubectl port-forward service/dev-go-sample-app 8083:8080 -n dev 2>&1 > /dev/null &
```{{execute}}

Send a request and validate that the app responds with "Hello, pipeline!"

```
curl localhost:8083
```{{execute}}