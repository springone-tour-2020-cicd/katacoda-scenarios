# Add a Trigger

Objective:
Up until this point you’ve probably had this question pop up into your head: I can **manually** run my Tekton Pipeline, but how do I **automatically** run my pipeline?
Maybe you want to automatically run your pipeline every time you create a pull request, push code to a repo, or merge a pull request into the master branch.
Thankfully, the Tekton Triggers project solves this problem by automatically connecting events to your Tekton Pipelines.

In this step, you will:
- Learn about the components of Tekton Triggers and how they work
- Set up Tekton Triggers to automatically trigger the pipeline when a GitHub pull request is created

## Local environment setup
Please wait until `Environment ready!` appears in the terminal window.

### Configure Tekton

Install the pipeline and trigger CRDs, and all the tasks we rely on.

```
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.13.2/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/git/git-clone.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/golang/lint.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/golang/build.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/golang/tests.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/kaniko/kaniko.yaml
```{{execute}}

### Clone repo

Start by cloning the GitHub repo you created in the [previous](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/1-intro-workflow) scenario.

For convenience, set the following environment variable to your GitHub namespace (your user or org name).
You can copy and paste the following command into the terminal window, then append your GitHub username or org:

```
# Fill this in with your GitHub username or org
GITHUB_NS=
```{{copy}}

Next, clone your fork of the sample app repo:
```
git clone https://github.com/$GITHUB_NS/go-sample-app.git && cd go-sample-app
```{{execute}}

### Log into Docker Hub

Copy and paste the following command into the terminal window, then append your Docker Hub username or org:

```
# Fill this in with your Docker Hub username or org
IMG_NS=
```{{copy}}

Login to your Docker Hub account using the `docker` CLI (your username has to be lowercase):

```
docker login -u ${IMG_NS}
```{{execute}}

We can now create the registry `Secret`.

```
kubectl create secret generic regcred  --from-file=.dockerconfigjson=/root/.docker/config.json --type=kubernetes.io/dockerconfigjson
```{{execute}}

## Trigger workflow
Tekton Triggers adds mainly three new resource types to Kubernetes: the `EventListener`, the `TriggerBinding` and the `TriggerTemplate`.

An `EventListener` creates a Deployment and Service that listen for events.
When the `EventListener` receives an event, it executes a specified `TriggerBinding` and `TriggerTemplate`.
A `TriggerBinding` then describes what information you want to extract from an event to pass to your `TriggerTemplate`.
And finally, a `TriggerTemplate` declares a specification for each Kubernetes resource you want to create when an event is received.

![TriggerFlow](https://github.com/tektoncd/triggers/blob/master/images/TriggerFlow.png?raw=true)

Let's go through each of these resources and apply them to our existing Tekton `PipelineRun`.

## Trigger Templates
As mentioned before, the `TriggerTemplate` resource defines a specification of a `PipelineRun`.
Hence, we should take our existing `PipelineRun` resource, and wrap it in a new `TriggerTemplate` so it can be created dynamically.

Let's start with renaming the file and nesting the `PipelineRun` inside a specification.

```
cd tekton
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

In order to generate new `PipelineRun` resources upon each trigger, we need to make sure the name is unique every time we create a `PipelineRun`.

```
yq w -i trigger-template.yaml "spec.resourcetemplates[0].metadata.generateName" "tekton-go-pipeline-run-"
yq d -i trigger-template.yaml "spec.resourcetemplates[0].metadata.name"
```{{execute}}

Let's take a look at our eventual `TriggerTemplate`.

```
yq r -C trigger-template.yaml
```{{execute}}

## Trigger Bindings

The `TriggerBinding` specifies the values to use for your `TriggerTemplate`’s parameters.
The REPO_URL and REVISION parameters are especially important because they are extracted from the pull request event body.
Looking at the [GitHub pull request event documentation](https://developer.github.com/v3/activity/events/types/#pullrequestevent), you can find the JSON path for values of the REPO_URL and REVISION in the event body.

Go ahead and create the new `TriggerBinding` resource.

For the version we can use the current date and time as a quick solution.

```
BUILD_DATE=`date +%Y.%m.%d-%H.%M.%S`
cat <<EOF >trigger-binding.yaml
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
EOF
```{{execute}}


## Event Listeners

The `EventListener` defines a list of triggers.
Trigger will pair the `TriggerTemplate` with the `TriggerBindings`.

```
cat <<EOF >event-listener.yaml
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
EOF
```{{execute}}

## Apply the trigger

```
kubectl apply -f sa.yaml -f pv.yaml -f pvc.yaml
tkn pipeline create -f pipeline.yaml
kubectl apply -f trigger-template.yaml -f trigger-binding.yaml -f event-listener.yaml
```{{execute}}

## Test it out

Wait for the deployment to finish.

```
kubectl rollout status deployment/el-tekton-go-event-listener
```{{execute}}

Let's port-forward our service.

```
kubectl port-forward --address 0.0.0.0 svc/el-tekton-go-event-listener 8080:8080 2>&1 > /dev/null &
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
