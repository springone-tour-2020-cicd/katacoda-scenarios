# Add a Trigger

Objective:
Up until this point you’ve probably had this question pop up into your head: I can **manually** run my Tekton Pipeline, but how do I **automatically** run my pipeline?
Maybe you want to automatically run your pipeline every time you create a pull request, push code to a repo, or merge a pull request into the master branch.
Thankfully, the Tekton Triggers project solves this problem by automatically connecting events to your Tekton Pipelines.

In this step, you will:
- Set up Tekton Triggers to automatically trigger the pipeline when a GitHub pull request is created

## Trigger Templates
As mentioned before, the `TriggerTemplate` resource defines a specification of a `PipelineRun`.
Hence, we should take our existing `PipelineRun` resource, and wrap it in a new `TriggerTemplate` so it can be created dynamically.

Let's start with renaming the file and nesting the `PipelineRun` inside a specification.

```
cd tekton
mv build-pipeline-run.yaml build-trigger-template.yaml
yq p -i build-trigger-template.yaml spec.resourcetemplates[+]
```{{execute}}

Now we can add anything specific to the `TriggerTemplate` in there.

```
{ yq m -x - build-trigger-template.yaml >tmp.yaml && mv tmp.yaml build-trigger-template.yaml; } <<EOF
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerTemplate
metadata:
  name: build-trigger-template
EOF
```{{execute}}

Each `TriggerTemplate` has parameters that can be substituted anywhere within the `PipelineRun` specification.
Let's add a couple of our own.

```
yq m -i -x build-trigger-template.yaml - <<EOF
spec:
  params:
  - name: REPO_URL
    description: The repository url to build and deploy.
  - name: BRANCH_NAME
    description: The branch to build and deploy.
  - name: IMAGE
    description: Name and tag of the Docker container in the Deployment.
EOF
```{{execute}}

Of course we also need to use these parameters inside our `PipelineRun` specification.

```
yq w -i build-trigger-template.yaml "spec.resourcetemplates[0].spec.params.(name==repo-url).value" "\$(params.REPO_URL)"
yq w -i build-trigger-template.yaml "spec.resourcetemplates[0].spec.params.(name==branch-name).value" "\$(params.BRANCH_NAME)"
yq w -i build-trigger-template.yaml "spec.resourcetemplates[0].spec.params.(name==image).value" "\$(params.IMAGE)"
```{{execute}}

In order to generate new `PipelineRun` resources upon each trigger, we need to make sure the name is unique every time we create a `PipelineRun`.

```
yq w -i build-trigger-template.yaml "spec.resourcetemplates[0].metadata.generateName" "build-pipeline-run-"
yq d -i build-trigger-template.yaml "spec.resourcetemplates[0].metadata.name"
```{{execute}}

Let's take a look at our eventual `TriggerTemplate`.

```
yq r -C build-trigger-template.yaml
```{{execute}}

## Trigger Bindings

The `TriggerBinding` specifies the values to use for your `TriggerTemplate`’s parameters.
The REPO_URL and REVISION parameters are especially important because they are extracted from the pull request event body.
Looking at the [GitHub pull request event documentation](https://developer.github.com/v3/activity/events/types/#pullrequestevent), you can find the JSON path for values of the REPO_URL and REVISION in the event body.

Go ahead and create the new `TriggerBinding` resource.

For the version we can use the current date and time as a quick solution.

```
BUILD_DATE=`date +%Y.%m.%d-%H.%M.%S`
cat <<EOF >build-trigger-binding.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerBinding
metadata:
  name: build-trigger-binding
spec:
  params:
  - name: REPO_URL
    value: \$(body.repository.clone_url)
  - name: BRANCH_NAME
    value: \$(body.pull_request.head.sha)
  - name: IMAGE
    value: ${IMG_NS}/go-sample-app:${BUILD_DATE}
EOF
```{{execute}}


## Event Listeners

The `EventListener` defines a list of triggers.
This Listener will pair the `TriggerTemplate` with the `TriggerBindings`.

```
cat <<EOF >build-event-listener.yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: EventListener
metadata:
  name: build-event-listener
spec:
  serviceAccountName: build-bot
  triggers:
  - name: build-trigger
    template:
      name: build-trigger-template
    bindings:
    - name: build-trigger-binding
EOF
```{{execute}}

## Apply the trigger

```
kubectl apply \
    -f sa.yaml \
    -f pv.yaml \
    -f pvc.yaml \
    -f build-pipeline.yaml \
    -f build-trigger-template.yaml \
    -f build-trigger-binding.yaml \
    -f build-event-listener.yaml
```{{execute}}
s
## Test it out

Wait for the deployment to finish.

```
kubectl rollout status deployment/el-build-event-listener
```{{execute}}

Let's port-forward our service.

```
kubectl port-forward --address 0.0.0.0 svc/el-build-event-listener 8080:8080 2>&1 > /dev/null &
```{{execute}}

Now we can trigger a pull request event, which should create a new `PipelineRun`.

```
curl \
    -H 'X-GitHub-Event: pull_request' \
    -H 'Content-Type: application/json' \
    -d '{
      "repository": {"clone_url": "'"https://github.com/${IMG_NS}/go-sample-app"'"},
      "pull_request": {"head": {"sha": "master"}}
    }' \
localhost:8080
```{{execute}}

Next, verify the `PipelineRun` executes without any errors.

```
tkn pipelinerun list
tkn pipelinerun logs -f
```{{execute}}

Stop the port-forwarding process:
```
pkill kubectl && wait $!
```{{execute}}
