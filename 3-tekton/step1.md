# Install Tekton

Objective:
Prepare your local environment and install Tekton.

In this step, you will:
- Prepare your local environment
- Install Tekton

## Local environment setup
Please wait until `Environment ready!` appears in the terminal window.

Your Docker Hub namespace (user or org name) will be needed in this scenario. For convenience, copy and paste the following environment variable to the terminal window, then append your Docker Hub namespace:

```
# Fill this in with your Docker Hub username or org
IMG_NS=
```{{copy}}

Your GitHub namespace (user or org name) will be needed in this scenario. For convenience, copy and paste the following environment variable to the terminal window, then append your GitHub namespace:

```
# Fill this in with your GitHub username or org
GITHUB_NS=
```{{copy}}

## Install Tekton
Let's begin by installing Tekton's Custom Resource Definitions (CRDs).

Install the CRDs using the `kubectl` command line
```
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.13.2/release.yaml
```{{execute}}

View the custom resources that were installed.
```
kubectl api-resources --api-group='tekton.dev'
```{{execute}}

The `tkn` CLI lets you interact more easily with Tekton's custom resources vs. using kubectl directly.
Now let's view the tasks installed in your cluster.
```
tkn task list
```{{execute}}

No tasks are found because we have not yet created them.
In the next step, we will create a 'hello world' task and run it.

