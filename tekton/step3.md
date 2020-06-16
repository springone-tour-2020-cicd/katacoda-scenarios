# Install prerequisites the jib-maven task

We will now install some supporting Kubernetes resources in order to run a Task that will build a container containing the Spring Boot sample applications and push it to Docker Hub.

Tekton has a [catalog of pre-built tasks](https://github.com/tektoncd/catalog) that cover common cases in a CI system.  

From that catalog, we will use the `jib-maven` task as the means to create the image and push it to Docker Hub.
The [jib maven plugin](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin) provides an easy and quick way to create a container image that is ties into the maven build lifecycle.


To use the `jib-maven` task there are a few things we need to setup in the Kubernetes cluster.

1. Create a [Persistent Volume Claim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) so that the contents of the .m2 cache will available when new Pods are created to execute the build.
1. Create a secret that contains your Docker Hub credentials.
1. Create a service account that will execute the pipeline and be able to access the Docker Hub credentials.

## Install `jib-maven` task prerequisites

Let's change to the `lab-2` directory and execute a few `kubectl` commands to install the task prerequisites.

```
cd /root/tekton-labs/lab-2
```{{execute}}


Create the Persistent Volume Claim:

```
kubectl apply -f cache-pvc.yaml
```{{execute}}


Login to your Docker Hub account using the `docker` CLI:

```
docker login
```{{execute}}

This creates a `config.json` file that caches your Docker Hub credentials.

```
more /root/.docker/config.json
```{{execute}}



You can [create a secret from existing credentials](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#registry-secret-existing-credentials) with the following command.

```
kubectl create secret generic regcred  --from-file=.dockerconfigjson=/root/.docker/config.json --type=kubernetes.io/dockerconfigjson
```{{execute}}


Now create the service account.  The name of the service account is `build-bot` and will be references in Tekton's TaskRun resource that will run the task.

```
kubectl apply -f service-account.yaml
```{{execute}}


## Install jib-maven task

The `lab-2` directory contains a copy of the `jib-maven` task that is found in the Tekton catalog.

Open the file `/root/tekton-labs/lab-2/jib-maven-task.yaml`{{open}} and take a look around.

**NOTE:  ** You may need to select the filename in the editor tree window to have the contents appear in the editor.

Now, install the `jib-maven` task

```
kubectl apply -f jib-maven-task.yaml
```{{execute}}


Now if you list the tasks installed in the cluster you will see the `jib-maven` task along with the `echo-hello-world` task from the previous step.

```
$ tkn task list
NAME               AGE
echo-hello-world   10 minutes ago
jib-maven          6 seconds ago
```


Looking into the YAML for the task, it is using the container image

```
gcr.io/cloud-builders/mvn
``` 

that has `maven` installed on it.
The command that the task executes is shown below from the `jib-maven-task` YAML.

```
steps:
- name: build-and-push
  image: gcr.io/cloud-builders/mvn
  command:
  - mvn
  - -B
  - compile
  - com.google.cloud.tools:jib-maven-plugin:build
  - -Duser.home=/tekton/home
  - -Djib.to.image=$(outputs.resources.image.url)
```

The value of the property `jib.to.image` will be set when we create the TaskRun resource that references this Task.

With these prerequisites installed in the cluster, we can now run the Task by creating a TaskRun resource in the next step.

