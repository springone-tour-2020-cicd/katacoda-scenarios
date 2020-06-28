# Use kpack to build images

Objective:

Use kpack, together with Paketo Buildpacks, to configure builds and rebases of images.

In this step, you will:
- Install kpack
- Configure kpack to build images when there is a new commit on the app repo
- Explore the automated build
- Trigger a new build

## About kpack

In the previous step, you built images using the `pack` platform and the Paketo Buildpacks builder.

In this step, you will explore another platform, `kpack`, which operates as a service and builds or rebases images automatically when it detects a change. 
If the change is detected in the application or the buildpacks, `kpack` will automatically rebuild images. 
If the change is detected only in the runtime base image, `kpack` will automaticelly rebase images.
 
`kpack` is "Kubernetes-native" and provides resources that extend the Kubernetes API. 
The `kpack` resources are purpose-built for Buildpacks, so they are simpler to use and offer additional functionality, including:
- Default pull model: kpack polls for changes in source code/artifact, builder image and run image
- Push model can be configured (trigger kpack by applying a change to one of its Kubernetes resources)
- Supports both build and rebase, and automatically determines which is appropriate

## Install kpack

Install kpack to the kubernetes cluster.

```
kubectl apply -f https://github.com/pivotal/kpack/releases/download/v0.0.9/release-0.0.9.yaml
```{{execute}}

The installation includes several Custom Resource Definitions (CRDs) that provide the Kubernetes primitives to configure kpack. 
Notice the "KIND" column. In this step, we will configure a Builder and an Image.

```
kubectl api-resources --api-group build.pivotal.io
```{{execute}}

The installation also includes two deployments (`kpack-controller` and `kpack-webhook`) in a namespace called `kpack`.
Use the following commands to wait until the deployment "rollouts" succeed:

```
kubectl rollout status deployment/kpack-controller -n kpack
kubectl rollout status deployment/kpack-webhook -n kpack
```{{execute}}

## Configure kpack

Create a new directory to store the kpack yaml manifests.

```
mkdir -p /workspace/go-sample-app-ops/cicd/kpack
cd /workspace/go-sample-app-ops/cicd/kpack
```{{execute}}

Create a Builder resource that specifies the same Paketo Buildpacks builder you used in previous steps.

```
cat <<EOF >builder.yaml
apiVersion: build.pivotal.io/v1alpha1
kind: Builder
metadata:
  name: paketo-builder
spec:
  image: gcr.io/paketo-buildpacks/builder:base-platform-api-0.3
EOF
```{{execute}}

Configure an Image resource. 
The Image resource will set up monitoring of the source, builder and run images, and it will kick off a new build when changes are detected.
As with `pack`, you need to provide three inputs:
- the builder to use
- the source code on GitHub
- the Docker Hub repository and credentials

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
  serviceAccount: kpack-bot
  #cacheSize: "1.5Gi"
  source:
    git:
      url: https://github.com/$GITHUB_NS/go-sample-app
      revision: master
  tag: $IMG_NS/go-sample-app
EOF
```{{execute}}

Note: We are leaving cacheSize commented out above because the katacoda scenario environment would require some additional configuration to provide the underlying storage-provisioning to support caching.

To provide write access to Docker Hub, notice that a new service account, `kpack-bot`, is specified in the Image above. 
The new service account can leverage the `regcred` secret with Docker Hub credentials that you created in step 1. 
Create the service account:

```
cat <<EOF >sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kpack-bot
secrets:
  - name: regcred
EOF
```{{execute}}

## Apply the kpack resources

Apply the kpack resources to the kubernetes cluster:

```
kubectl apply -f builder.yaml \
              -f sa.yaml \
              -f image.yaml
```{{execute}}

## Validate that an image was built

The Image resource detects that there is a code revision to build and creates a corresponding Build resource. You should immediately see a Build resource:

```
kubectl get builds
```{{execute}}

When the build completes, you will see a new image on your [Docker Hub](https://hub.docker.com) account.
In the meantime, continue reading to learn how you can track the build progress and results.

## Behind the scenes

For convenience, store the build name and number of the latest build in env vars.
```
LATEST_BUILD=$(kubectl get builds -o yaml | yq r - "items[-1].metadata.name") \
             && echo "Latest build: ${LATEST_BUILD}"
BUILD_NR=$(kubectl get builds -o yaml | yq r - "items[-1].metadata.labels.[image.build.pivotal.io/buildNumber]")
echo "LATEST_BUILD=${LATEST_BUILD}"
echo "BUILD_NR=${BUILD_NR}"
```{{execute}}

You can use `kubectl describe` to get more information about the build.

```
kubectl describe build ${LATEST_BUILD}
```{{execute}}

Notice that the build description includes such details as the source commit id and the reson for the build:
```
kubectl describe build ${LATEST_BUILD} | grep Revision
kubectl describe build ${LATEST_BUILD} | grep reason | head -1
```{{execute}}

The Build creates a Pod in order to execute the build and produce the image.

```
kubectl get pods | grep ${LATEST_BUILD}
```{{execute}}

You should see evidence of _init_ containers in the results (something like: "Init:1/6"). kpack orchestrates the CNB lifecycle using _init_ containers - a prepare container, plus containers for each lifecycle step: detect, analyze, restore, build, export. (These should sound familiar based on the logs that `pack` generated in the last step). A simple `kubectl logs` command will not stream the init container logs, so kpack provides a `logs` CLI to make it easy to extract the logs from all init containers:

```
logs -image go-sample-app -build ${BUILD_NR}
```{{execute}}

You should see logging similar to the logging you saw with `pack`, since the underlying process using the Paketo Builder is the same.

When the log shows that the build is done, check your [Docker Hub](https://hub.docker.com) to validate that an image has been published. The image will have a tag as specified in your Image configuration, as well as an auto-generated tag. Both tags are aliasing the same image digest.

## Trigger a new build

By default, kpack will poll the source code repo, the builder image, and the run image every 5 minutes, and will automatically rebuild - or rebase, as approrpriate - if it detects a new commit.

Notice that the Image resource is configured to poll the master branch on the app repo. That means any commit to the master branch will trigger a build.

Make a code change and push to GitHub. Provide your access token at the prompt.

```
cd /workspace/go-sample-app

sed -i 's/sunshine/friends/g' hello-server.go

git add -A
git commit -m "Hello, friends!"
git push origin master
```{{execute}}

Use the commands above (make sure to update the LATEST_BUILD and BUILD_NR vars) or go to Docker Hub to validate that kpack builds a new image. Keep in mind it may take up to 5 minutes for kpack to detect the change on GitHub. 

## Save changes

Save the new kpack files to the ops repo in GitHub

```
cd /workspace/go-sample-app-ops
git add -A
git commit -m 'Changes from the Buildpacks scenario'
git push origin master
```{{execute}}