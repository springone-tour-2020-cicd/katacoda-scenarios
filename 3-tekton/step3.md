# Install prerequisites for the tasks

We will now install some supporting Kubernetes resources in order to run a Task that will build a container containing the Go sample applications and push it to Docker Hub.

Tekton has a [catalog of pre-built tasks](https://github.com/tektoncd/catalog) that cover common cases in a CI system.

From that catalog, we will use the `git`, `golang` and `kaniko` tasks as the means to build the app, create the image and push it to Docker Hub.

To use these tasks there are a few things we need to setup in the Kubernetes cluster.

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

Apply both and verify whether the Persistent Volume Claim is bound.

```
kubectl apply -f .
kubectl get pvc
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
cat <<EOF >sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: build-bot
secrets:
  - name: regcred
EOF
kubectl apply -f sa.yaml
```{{execute}}

With these prerequisites installed in the cluster, we can now start creating the required Tasks.