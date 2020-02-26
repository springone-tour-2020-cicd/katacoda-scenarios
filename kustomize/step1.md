First validate that the Kubernetes cluster is up and running.
Wait for the progress bar to complete.  You will see a prompt such as


```
 ~
$
```

The tilde will show that `git status` of the directory you are in.

Then execute

```
minikube status
```{{execute}}
<br>

You should see no errors in the output.
```
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```
<br>

Now onto the real stuff!