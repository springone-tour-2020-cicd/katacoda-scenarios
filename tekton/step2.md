# Executing a simple Task

View the echo Task that will simply print 'hello world' to the console.

```
cat echo-task.yaml
```{{execute}}

Or open the file in the editor
Open the file `/root/tekton-labs/lab-1/echo-task.yaml`{{open}}

**NOTE:  ** You may need to select the filename in the editor tree window to have the contents appear in the editor.



The echo task uses the image `ubuntu` and then simply executes the command `echo hello world`.

## Install the task definition

Use `kubectl` to install the task definition into the cluster.

```
kubectl apply -f echo-task.yaml
```{{execute}}


You can list the installed tasks in the cluster using the `tkn` CLI.
```
tkn task list
```{{execute}}


More information about the task can be obtained using the `describe` command.
```
tkn tasks describe echo-hello-world
```{{execute}}


## Execute the task

To execute this task directly, we can use the `tkn` CLI or create a `TaskRun` resource in a YAML file.
We will create the `TaskRun` resource using a YAML file.
Look at the `echo-taskrun.yaml` file.

```
cat echo-taskrun.yaml
```{{execute}}
You can also navigate to this file in the editor that is above the terminal.



There isn't anything that is customizing the task, so it is just referencing the `echo-hello-world` task.
You can view the other configuration options for a `TaskRun` in the [reference documentation.](https://github.com/tektoncd/pipeline/blob/v0.13.2/docs/taskruns.md)

```
kubectl apply -f echo-taskrun.yaml
```{{execute}}


Now let's get a description of the `TaskRun` that was created.

```
tkn taskrun describe echo-hello-world-task-run
```{{execute}}


You should see in the last part of the output of this command the status of the pod that is running the echo command


```
🦶 Steps

 NAME     STATUS
 ∙ echo   PodInitializing
 ```

Keep executing the `tkn taskrun describe` command and you will eventually see that the pod status is `COMPLETED`.


Now look at the output of `TaskRun`

```
tkn taskrun logs echo-hello-world-task-run
```{{execute}}

You will see the log from the `echo` step

```
[echo] hello world
```

Hello Tekton! 


