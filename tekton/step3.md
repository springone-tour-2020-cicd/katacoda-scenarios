View the echo Task that will simply print 'hello world' to the console.

```
cat echo-task.yaml
```{{execute}}
<br>

Or open the file in the editor
Open the file `/root/tekton-labs/lab-1/echo-task.yaml`{{open}}

**NOTE:  ** You may need to select the filename in the editor tree window to have the contents appear in the editor.

<br>

## Install the task definition

Use `kubectl` to install the task definition into the cluster.

```
kubectl apply -f echo-task.yaml
```{{execute}}
<br>

You can list the installed tasks in the cluster using the `tkn` CLI.
```
tkn task list
```{{execute}}
<br>

More information about the task can be obtained using the `describe` command.
```
tkn tasks describe echo-hello-world
```{{execute}}
<br>

To execute this task directly, we can use the `tkn` CLI or create a `TaskRun` resource in a YAML file.
We will create the `TaskRun` resource using a YAML file.
Look at the `echo-taskrun.yaml` file.

```
cat echo-taskrun.yaml
```{{execute}}
You can also navigate to this file in the editor that is above the terminal.
<br>


There isn't anything that is customizing the task, so it is just referencing the `echo-hello-world` task.
You can view the other configuration options for a `TaskRun` in the [reference documentation.](https://github.com/tektoncd/pipeline/blob/v0.10.1/docs/taskruns.md)

```
kubectl apply -f echo-taskrun.yaml
```{{execute}}
<br>

Now let's get a description of the `TaskRun` that was created.

```
tkn taskrun describe echo-hello-world-task-run
```{{execute}}
<br>

After a few moments, you should see that the Status is `COMPLETED`.
Keep executing the previous command until you see the final status.

Now look at the output of `TaskRun`

```
tkn taskrun logs echo-hello-world-task-run
```{{execute}}
<br>

Hello Tekton!


