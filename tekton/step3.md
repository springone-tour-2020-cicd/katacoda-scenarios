# Install prerequisites the jib-maven task

We will now install some supporting Kubernetes resources in order to run a Task that will build a container containing the Go sample applications and push it to Docker Hub.

Tekton has a [catalog of pre-built tasks](https://github.com/tektoncd/catalog) that cover common cases in a CI system.

From that catalog, we will use the `goland` and `kaniko` tasks as the means to build the app, create the image and push it to Docker Hub.
The [golang tasks](https://github.com/tektoncd/catalog/blob/v1beta1/golang/README.md) provide an easy and quick way to lint, build and test Go apps.
The [kaniko task](https://github.com/tektoncd/catalog/blob/v1beta1/kaniko/README.md) builds source into a container image using Google's [kaniko](https://github.com/GoogleCloudPlatform/kaniko) tool.


To use the `golang` and `kaniko` tasks there are a few things we need to setup in the Kubernetes cluster.

1. Create a [Persistent Volume Claim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) so that the contents of the build cache will available when new Pods are created to execute the build.
1. Create a secret that contains your Docker Hub credentials.
1. Create a service account that will execute the pipeline and be able to access the Docker Hub credentials.

## Install prerequisites

Let's change to the `lab-2` directory and execute a few `kubectl` commands to install the task prerequisites.

First we need to create a Persistent Volume.

```
mkdir prereqs
cd prereqs
cat <<EOF >pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: tekton-tasks-pv
spec:
  capacity:
    storage: 3Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  hostPath:
    path: "/mnt/data"
EOF
```{{execute}}

Create the Persistent Volume Claim:

```
cat <<EOF >pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: tekton-tasks-pvc
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
EOF
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

Now create the service account.
The name of the service account is `build-bot` and will be references in Tekton's TaskRun resource that will run the task.

```
kubectl apply -f service-account.yaml
```{{execute}}

## Install golang task

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

