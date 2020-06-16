# Installing Tekton

## Local environment setup
Please wait until `Environment ready!` appears in the terminal window.

## Install Tekton
Let's begin by installing Tekton's Custom Resource Definitions (CRDs). 

```
cd tekton-labs/lab-1
```{{execute}}

Install the CRDs using the `kubectl` command line
```
kubectl apply -f release-0.13.2.yaml
```{{execute}}

View the custom resources that were installed
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

