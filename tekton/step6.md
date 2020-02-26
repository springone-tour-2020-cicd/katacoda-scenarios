** work in progress **

In this step we will create a `Pipeline` that creates a container image of a Spring Boot application and publish it to Docker Hub.

Unlike the previous step where we used a `TaskRun` and embedded resources for `git` and `image`, we will create a `Pipeline` resource and also `git` and `image` resources in the cluster.

Let's change to the `lab-3` directory and execute a few `kubectl` commands to install the task prerequisites.

```
cd /root/tekton-labs/lab-3
```{{execute}}
<br>

The file `pipeline-resources.yaml` contains the Tekton resource for a `git` repository and a container `image`.  We will reference these resources in the pipeline spec using a `resourceRef` field in the pipeline's YAML.

Take a look at the `pipeline-resources.yaml` file. 

** You will need to replace the same two fields in this file as you did in the previous step's `jib-maven-taskrun.yaml` file.

```
cat pipeline-resources.yaml
```{{execute}}

Or open the file in the editor
Open the file `/root/tekton-labs/lab-3/pipeline-resources.yaml`{{open}}


After changing the two `url` values, apply the resource definitions to the cluster

```
kubectl apply -f pipeline-resources.yaml
```{{execute}}
<br>

You can view the Tekton resources using the `tkn` command line

```
tkn resource list
```{{execute}}

Now create the Pipeline

```
kubectl apply -f pipeline.yaml
```{{execute}}
<br>


And run the pipeline by creating a `PipelineRun` resource.

```
kubectl apply -f pipeline-run.yaml
```{{execute}}
<br>

To view the logs

```
tkn pipelinerun logs --follow mark-pr
```{{execute}}
<br>








 



