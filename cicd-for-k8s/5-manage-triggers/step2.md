# Add a Trigger

Objective:

Up until this point you’ve probably had this question pop up into your head: I can **manually** run my Tekton Pipeline, but how do I **automatically** run my pipeline?
Maybe you want to automatically run your pipeline every time you create a pull request, push code to a repo, or merge a pull request into the master branch.
Thankfully, the Tekton Triggers project solves this problem by automatically connecting events to your Tekton Pipelines.

In this step, you will:
- Learn about the components of Tekton Triggers and how they work

### Configure Tekton

Install the pipeline and trigger CRDs, and all the tasks we rely on.

```
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.13.2/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/git/git-clone.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/golang/lint.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/golang/tests.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/kaniko/kaniko.yaml
```{{execute}}

### Provide Tekton with access to push to GitHub

Your GitHub token is stored in environment variable GITHUB_TOKEN from step 1, so you can simply run the following command to create a Secret for Tekton:

```
kubectl create secret generic github-token --from-literal=GITHUB_TOKEN=${GITHUB_TOKEN}
```{{execute}}

## Trigger workflow
Tekton Triggers adds mainly three new resource types to Kubernetes: the `EventListener`, the `TriggerBinding` and the `TriggerTemplate`.

An `EventListener` creates a Deployment and Service that listen for events.
When the `EventListener` receives an event, it executes a specified `TriggerBinding` and `TriggerTemplate`.
A `TriggerBinding` then describes what information you want to extract from an event to pass to your `TriggerTemplate`.
And finally, a `TriggerTemplate` declares a specification for each Kubernetes resource you want to create when an event is received.

![TriggerFlow](https://github.com/tektoncd/triggers/blob/master/images/TriggerFlow.png?raw=true)

Let's go through each of these resources and apply them to our existing Tekton `PipelineRun`.
