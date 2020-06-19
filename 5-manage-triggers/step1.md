# Step Title Here

Objective:
Up until this point you’ve probably had this question pop up into your head: I can **manually** run my Tekton Pipeline, but how do I **automatically** run my pipeline?
Maybe you want to automatically run your pipeline every time you create a pull request, push code to a repo, or merge a pull request into the master branch.
Thankfully, the Tekton Triggers project solves this problem by automatically connecting events to your Tekton Pipelines.

In this step, you will:
- Learn about the components of Tekton Triggers and how they work
- Set up Tekton Triggers to automatically trigger the pipeline when a GitHub pull request is created

## Local environment setup
Please wait until `Environment ready!` appears in the terminal window.

## Trigger workflow
Tekton Triggers adds mainly three new resource types to Kubernetes: the `EventListener`, the `TriggerBinding` and the `TriggerTemplate`.

An `EventListener` creates a Deployment and Service that listen for events.
When the `EventListener` receives an event, it executes a specified `TriggerBinding` and `TriggerTemplate`.
A `TriggerBinding` then describes what information you want to extract from an event to pass to your `TriggerTemplate`.
And finally, a `TriggerTemplate` declares a specification for each Kubernetes resource you want to create when an event is received.

Let's go through each of these resources and apply them to our existing Tekton `PipelineRun`.

## Trigger Templates
As mentioned before, the `TriggerTemplate` resource defines a specification of a `PipelineRun`.
Hence, we should take our existing `PipelineRun` resource, and wrap it in a new `TriggerTemplate` so it can be created dynamically.

Let's start with renaming the file and nesting the `PipelineRun` inside a specification.

```
cd go-sample-app/tekton
mv pipeline-run.yaml trigger-template.yaml
yq p -i trigger-template.yaml spec.resourcetemplates[+]
```{{execute}}

Now we can add anything specific to the `TriggerTemplate` in there.

```
{ yq m -x - trigger-template.yaml >tmp.yaml && mv tmp.yaml trigger-template.yaml; } <<EOF
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerTemplate
metadata:
  name: tekton-go-template-trigger
EOF
```{{execute}}

Each `TriggerTemplate` has parameters that can be substituted anywhere within the `PipelineRun` specification.
Let's add a couple of our own.

```
yq m -i -x trigger-template.yaml - <<EOF
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
yq w -i trigger-template.yaml "spec.resourcetemplates[0].spec.params.(name==repo-url).value" "\$(params.REPO_URL)"
yq w -i trigger-template.yaml "spec.resourcetemplates[0].spec.params.(name==branch-name).value" "\$(params.BRANCH_NAME)"
yq w -i trigger-template.yaml "spec.resourcetemplates[0].spec.params.(name==image).value" "\$(params.IMAGE)"
```{{execute}}

## Trigger Bindings

The `TriggerBinding` specifies the values to use for your `TriggerTemplate`’s parameters.
The REPO_URL and REVISION parameters are especially important because they are extracted from the pull request event body.
Looking at the [GitHub pull request event documentation](https://developer.github.com/v3/activity/events/types/#pullrequestevent), you can find the JSON path for values of the REPO_URL and REVISION in the event body.

Go ahead and create the new `TriggerBinding` resource.

For the version we can use the current date and time as a quick solution.
We'll need your Docker Hub username or org for the `IMAGE` parameter.
Copy and paste the following command into the terminal window, then append your Docker Hub username or org:

```
# Fill this in with your Docker Hub username or org
IMG_NS=
```{{copy}}

```
BUILD_DATE=`date +%Y.%m.%d-%H.%M.%S`
apiVersion: triggers.tekton.dev/v1alpha1
   kind: TriggerBinding
   metadata:
     name: tekton-go-trigger-binding
   spec:
     params:
     - name: REPO_URL
       value: \$(body.repository.clone_url)
     - name: BRANCH_NAME
       value: \$(body.pull_request.head.sha)
     - name: IMAGE
       value: ${IMG_NS}/go-sample-app:${BUILD_DATE}
```{{execute}}


## Event Listeners

The `EventListener` defines a list of triggers.
Trigger will pair the `TriggerTemplate` with the `TriggerBindings`.

```
apiVersion: triggers.tekton.dev/v1alpha1
kind: EventListener
metadata:
  name: tekton-go-event-listener
spec:
  serviceAccountName: build-bot
  triggers:
  - name: tekton-go-trigger
    template:
      name: tekton-go-template-trigger
    bindings:
    - name: tekton-go-trigger-binding
```{{execute}}

## Test it out

```
URL="https://github.com/${IMG_NS}/go-sample-app"
```{{execute}}
```
ROUTE_HOST=$(kubectl svc go-sample-app --template='http://{{.spec.host}}')
```{{execute}}
```
curl -v \
    -H 'X-GitHub-Event: pull_request' \
    -H 'Content-Type: application/json' \
    -d '{
      "repository": {"clone_url": "'"${URL}"'"},
      "pull_request": {"head": {"sha": "master"}}
    }' \
${ROUTE_HOST}
```{{execute}}
