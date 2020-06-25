# Use kpack to build images

Objective:
Use kpack, together with Paketo Buildpacks, to configure builds and rebases of images.

In this step, you will:
- Install kpack
- Configure kpack to build images when there is a new commit on the app repo
- Explore the automated build
- Trigger a new build

## About kpack

At this point, you have built images using Cloud Native Buildpacks using two different platforms: `pack` and `Tekton`. In both cases, you used the same Paketo Buildpacks builder, hence producing the exact same image.

`pack` and `Tekton` fit different use cases. `pack` is optimized for a developer experience, and `Tekton` is optimized for automated pipelines.

In this step, you will explore a third platform called `kpack`, which operates as a service that can monitor source repos, as well as buildpack image repos (builder images and run images), and it can automatically build or rebase images, as appropriate, when it detects a change in any of the three inputs.
 
Like Tekton, `kpack` is "Kubernetes-native" and provides resources that extend the Kubernetes API. 
The `kpack` resources are purpose-built for Buildpacks, so they are simpler to use and offer additional functionality, including:
- Default polling of source code/artifact, builder image and run image automatically configured
- Supports pull and push model (you can disable polling and trigger `kpack` directly)
- Supports both build and rebase, and automatically determines which is appropriate

## Install kpack

Install kpack to the kubernetes cluster.

```
kubectl apply -f https://github.com/pivotal/kpack/releases/download/v0.0.9/release-0.0.9.yaml
```{{execute}}

The installation includes two deployments (`kpack-controller` and `kpack-webhook`) in a namespace called `kpack`.
These deployment resources comprise the kpack service itself:

```
kubectl get all -n kpack
```{{execute}}

Wait until the status of the two pods is `Running`.

The installation also includes several Custom Resource Definitions (CRDs) that provide the Kubernetes primitives to configure kpack:
```
kubectl api-resources --api-group build.pivotal.io
```{{execute}}

You can list kpack resources that you create by querying for these CRDs.
For the moment, the following command should return an empty result:
```
kubectl get builders,builds,clusterbuilders,images,sourceresolvers --all-namespaces
```{{execute}}

## Configure kpack

Create a new directory to store the kpack yaml manifests.

```
mkdir ../kpack
cd ../kpack
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

Finally, configure an Image resource, which will trigger Builds as necesssary. As with `pack` and Tekton, you need to provide three inputs:
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
  serviceAccount: build-bot
  #cacheSize: "1.5Gi"
  source:
    git:
      url: https://github.com/$GITHUB_NS/go-sample-app
      revision: master
  tag: $IMG_NS/go-sample-app:kpack-0.0.1
EOF
```{{execute}}

## Apply the kpack resources

Apply the kpack resources to the kubernetes cluster:

```
kubectl apply -f builder.yaml \
              -f image.yaml
```{{execute}}

## Explore the automated build

Within a short time, you should see a Build resource for the latest commit.

```
kubectl get builds
```{{execute}}

To see details of the build, copy and paste the following command to the terminal and edit it using the name of your build. The `Revision` field, for example, will contain the corresponding git commit id.

```
kubectl describe build go-sample-app-build-1-<uuid>
```{{copy}}

The build is executed in a pod (Eech build creates a new pod).

```
kubectl get pods
```{{execute}}

Each phase of the buildpack lifecycle is executed in a separate _init container_, so getting the logs directly from the pod involves appending the pods from each init container in the right order.
To facilitate this, kpack includes a special `logs` CLI that makes it easy to get the build log:

```
logs -image go-sample-app -build 1
```{{execute}}

You should see the same lifecycle phases as you observed earlier in this scenario.

When the log shows that the build is done, check your [Docker Hub](https://hub.docker.com) to validate that an image has been published.

`Send Ctrl+C`{{execute interrupt T1}} to stop tailing the log.

## Trigger a new build

By default, kpack will poll the source code repo, the builder image, and the run image every 5 minutes, and will automatically rebuild - or rebase, as apporpriate - if it detects a new commit.

Notice that the Image resource is configured to poll the master branch on the app repo. That means any commit to the master branch will trigger a build.

Make a code change and push to GitHub.

```
cd /workspace/go-sample-app

sed -i 's/sunshine/friends/g' hello-server.go

git add -A
git commit -m "Hello, friends!"
git push origin master
```{{execute}}

Use the commands above or go to Docker Hub to validate that kpack builds a new image. Keep in mind it may take up to 5 minutes for kpack to detect the change. 
