# Step Title Here

Objective:
...

In this step, you will:
- ...

# Configure kpack Cluster and Image

Make a new directory for the kpack configuration
```
mkdir -p /workspace/go-sample-app/kpack
cd /workspace/go-sample-app/kpack
```{{execute}}

Configure a resource for the builder. This resource can be shared by many images:
```
cat <<EOF >builder.yaml
apiVersion: build.pivotal.io/v1alpha1
kind: Builder
metadata:
  name: paketo-builder
spec:
  image: gcr.io/paketo-buildpacks/builder:base
EOF
```{{execute}}

Create a resource for the image. The image includes references to the source code, builder, and service account with write access to Docker Hub. By default, kpack will poll the source code repo for commits every 5 minutes, and will automatically re-build the image if it detects a new commit.

```
cat <<EOF >image.yaml
apiVersion: build.pivotal.io/v1alpha1
kind: Image
metadata:
  name: go-sample-app
spec:
  builder:
    name: paketo-builder
    kind: Builder
  serviceAccount: build-bot
  #cacheSize: "1.5Gi"
  source:
    git:
      url: https://github.com/$GITHUB_NS/go-sample-app
      revision: master
  tag: $IMG_NS/go-sample-app:kpack-1.0.0
EOF
```{{execute}}

## Apply configuration to kpack

We're now ready to apply the yaml files to the kubernetes cluster:
```
kubectl apply -f builder.yaml \
              -f image.yaml
```{{execute}}

## Is it working?

kpack will create a Build resource for every commit it detects. For now, you should see a Build resource for the latest commit:
```
kubectl get builds
```{{execute}}

Edit the name of the build in the following command to see the details:
```
kubectl describe build go-sample-app-1-<uuid>
```{{copy}}

The `Revision` field will contain the corresponding git commit id.

The build is executed in a pod. Each build creates a new pod.
```
kubectl get pods
```{{execute}}

Each phase of the buildpack lifecycle is executed in a separate _init container_, so getting the logs directly from the pod involves appending the pods from each init container in the right order. To facilitate this, kpack includes a special `logs` CLI that makes it easy to get the build log:
```
logs -image go-sample-app -build 1
```{{execute}}

The logs should look very similar to those we saw in the previous scenario scenarios on pack and Spring Boot. 

When the log shows that the build is done, check your Docker Hub organization to make sure a new image has been published.

`Send Ctrl+C`{{execute interrupt T1}} to stop tailing the log.
