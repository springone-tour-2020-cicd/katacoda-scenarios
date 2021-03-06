# Install prerequisites for the tasks

We will now install some supporting Kubernetes resources in order to run a Task that will build a container containing the Go sample application and push it to Docker Hub.

Tekton has a [catalog of pre-built tasks](https://github.com/tektoncd/catalog) that cover common cases in a CI system.

From that catalog, we will use the `git`, `golang` and `kaniko` tasks as the means to build the app, create the image and push it to Docker Hub.

To use these tasks there are a few things we need to set up in the Kubernetes cluster.

1. Create a [Persistent Volume Claim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) so that the contents of the build cache will be available when new Pods are created to execute the build.
1. Create a secret that contains your Docker Hub credentials.
1. Create a service account that will execute the pipeline and be able to access the Docker Hub credentials.

## Create a Persistent Volume

Create a new directory to store Tekton configuration manifests.

```
mkdir -p /workspace/go-sample-app/cicd/tekton
cd /workspace/go-sample-app/cicd/tekton
```{{execute}}

First we need to create a Persistent Volume.

```
cat <<EOF >pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: workspace-pv
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

**NOTE:** This `PersistentVolume` is of type `HostPath`, which implies it does not support `ReadWriteMany` policies.
Therefore, containers who wish to write to this volume will have to wait turns, resulting in sequential execution.
Look into file system storage to make parallel execution possible.

Create the Persistent Volume Claim:

```
cat <<EOF >pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: workspace-pvc
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
EOF
```{{execute}}

**NOTE:** This `PersistentVolumeClaim` is going to be reused for each run, meaning the Git repository inside of it will be cleaned out between `PipelineRun`s.
This is a problem if you're having multiple builds at the same time.
Instead of creating a dedicated `PersistentVolumeClaim`, the `PipelineRun` or `TriggerTemplate` you're going to create later on, has the ability to create `PersistentVolumeClaim`s on demand.

_As you're not having simultaneous builds, you'll simply use the `PersistentVolumeClaim` mentioned above._
```
    workspaces:
      - name: shared-workspace
        volumeClaimTemplate:
          spec:
            accessModes:
            - ReadWriteOnce
            storageClassName: local-storage
            resources:
              requests:
                storage: 500Mi
```

Apply both and verify whether the Persistent Volume Claim is bound.

```
kubectl apply -f .
kubectl get pvc
```{{execute}}

## Create a ServiceAccount

After a successful login to Docker Hub when setting up your credentials a `config.json` file that caches your Docker Hub credentials was created.
We'll use these credentials to push the newly built image to Docker Hub from our Tekton task.

```
cat /root/.docker/config.json
```{{execute}}

You can [create a secret from existing credentials](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#registry-secret-existing-credentials) with the following command.

```
kubectl create secret generic regcred  --from-file=.dockerconfigjson=/root/.docker/config.json --type=kubernetes.io/dockerconfigjson
```{{execute}}

Now create the service account.
The name of the service account is `build-bot` and will be referenced in Tekton's TaskRun resource that will run the task.

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
