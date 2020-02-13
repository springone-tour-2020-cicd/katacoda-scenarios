View the echo Task that will simply print 'hello world' to the console.

```
cat echo-task.yaml
```{{execute}}
<br>

Now install this task definition into the cluster.

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

To execute this task directly, we can use the `tkn` CLI or create a `TaskRun` resource in a YAML file.  We will create the `TaskRun` resource using a YAML file

```
kubectl apply -f echo-taskrun.yaml
```{{execute}}
<br>

Now let's get a description of the `TaskRun` that was created.

```
tkn taskrun describe echo-hello-world-task-run
```{{execute}}
<br>

You should see that the Status is `COMPLETED`.
Look at the output of `TaskRun`

```
tkn taskrun logs echo-hello-world-task-run
```{{execute}}
