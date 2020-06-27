# Rebasing with kpack

Objective:

Demonstrate a rebase using `kpack`.

In this step, you will:
- Configure a new `kpack` CustomBuilder resource so that you can demonstrate a rebase
- Build an image using the CustomBuilder
- Update the run-image version and observe `kpack` update the image

## Create a temporary directory

This step is intended to demonstrate a rebase with kpack. You will not need the files created in this step moving forward.

Create a temporary directory for this step to keep these files outside of your git repos.

```
mkdir -p /workspace/kpack-rebase-demo
cd /workspace/kpack-rebase-demo
```{{execute}}

## Create a CustomBuilder resource

In the last step, you configured a Builder that points to the Paketo Buildpacks at `gcr.io/paketo-buildpacks/builder:base-platform-api-0.3`.
If that builder is updated with new or updated buildpacks, kpack will automatically _rebuild_ the go-sample-app image. If only the stack (base image) is updated, kpack will automatically _rebase_ the go-sample-app image.

Since these builder and run images are controlled by the Paketo Buildpacks project, we cannot influence the release of an update in order to catalyze a rebase.
However, we can create a CustomBuilder that will give us finer-grain control and enable us to trigger a rebase.

Create a new CustomBuilder in which you can separately define the building blocks of a builder:
- [Store](https://github.com/pivotal/kpack/blob/master/docs/custombuilders.md#store): a list of images that contain **buildpacks**. As we explained earlier, builders include buildpacks, so we can use a builder as a source of buildpacks.
- [Stack](https://github.com/pivotal/kpack/blob/master/docs/custombuilders.md#stack): the OS stack, used for both the build-time and run-time images. You will use `io.buildpacks.stacks.bionic` in the configuration below (Ubuntu 18.04), but you can use `pack suggest-stacks`{{execute}} to see some additional OSS options.
- [CustomBuilder](https://github.com/pivotal/kpack/blob/master/docs/custombuilders.md#custom-builders): the builder, which comprises the _Store_ (buildpacks) and _Stack_ (base OS), and specifies the order in which to process buildpack groups. For reference of how to configure this, you can check `pack inspect-builder gcr.io/paketo-buildpacks/builder:base-platform-api-0.3`{{execute}}

Review the configuration below, and execute the command to save it to a file.

```
cat <<EOF >custom-builder.yaml
apiVersion: experimental.kpack.pivotal.io/v1alpha1
kind: Store
metadata:
  name: paketo-store
spec:
  sources:
  - image: gcr.io/paketo-buildpacks/builder:base-platform-api-0.3
---
apiVersion: experimental.kpack.pivotal.io/v1alpha1
kind: Stack
metadata:
  name: paketo-bionic-stack
spec:
  id: "io.buildpacks.stacks.bionic"
  buildImage:
    image: "gcr.io/paketo-buildpacks/build:0.0.19-base-cnb"
  runImage:
    image: "gcr.io/paketo-buildpacks/run:0.0.19-base-cnb"
---
apiVersion: experimental.kpack.pivotal.io/v1alpha1
kind: CustomBuilder
metadata:
  name: paketo-custom-builder
spec:
  tag: $IMG_NS/paketo-custom-builder
  serviceAccount: kpack-bot
  stack: paketo-bionic-stack
  store: paketo-store
  order:
  - group:
    - id:  paketo-buildpacks/go
  - group:
    - id:  paketo-buildpacks/java
  - group:
    - id: paketo-buildpacks/nodejs
  - group:
    - id: paketo-buildpacks/dotnet-core
  - group:
    - id: paketo-buildpacks/nginx
  - group:
    - id: paketo-buildpacks/procfile
EOF
```{{execute}}

Apply the CustomBuilder to the cluster.

```
kubectl apply -f custom-builder.yaml
```{{execute}}

Briefly, you should see a builder image called paketo-custom-builder published to your Docker Hub account. With the above configuration, you have effectively created your own builder. Alternatively, you can confirm that the image was published using the following command. You should see the image reference under the `LATESTIMAGE` column.

```
kubectl get custombuilder
```{{execute}}

## Build image

To show kpack building and rebasing an image, create a new Image manifest using the new CustomBuilder you just created. 

Note the Image resource name and the image tag.

```
cat <<EOF >rebase-demo-image.yaml
apiVersion: build.pivotal.io/v1alpha1
kind: Image
metadata:
  name: rebase-demo-app
spec:
  builder:
    name: paketo-custom-builder
    kind: CustomBuilder
  serviceAccount: kpack-bot
  #cacheSize: "1.5Gi"
  source:
    git:
      url: https://github.com/$GITHUB_NS/go-sample-app
      revision: master
  tag: $IMG_NS/rebase-demo-img
EOF
```{{execute}}

Apply the new Image manifest.

```
kubectl apply -f rebase-demo-image.yaml
```{{execute}}

After a short time, you should see a image repository on your Docker Hub account. Notice the digest of the image.

You can also track the progress of the builds using the commands you used earlier:

```
kubectl get builds
```{{execute}}

```
kubectl describe build <BUILD_NAME> | grep rebase-demo
```{{copy}}

Notice that the `kubectl describe build` output includes an Annotation stating that the reason for build was "CONFIG".

```
logs -image rebase-demo-app-1 -build 1
```{{copy}}

## Rebase the image

To trigger a rebase, update the Stack resource with an updated run image, and apply the change to the cluster.

```
sed -i 's/run:0.0.19-base-cnb/run:0.0.20-base-cnb/g' custom-builder.yaml

kubectl apply -f custom-builder.yaml
```{{execute}}

Monitor builds again, and notice that kpack automatically updates the image using the updated stack.

You can validate that `kpack` is rebasing rather than rebuilding in a couple of ways. The build log specifically reflects a rebase rather than a build:

```
logs -image rebase-demo-app-1 -build 2
```{{copy}}

In addition, the reason reported in the Build resource is "STACK". Run the command below and find the Annotation stating the build reason was "STACK".

```
kubectl describe build <BUILD_NAME>
```{{copy}}

When a stack update occurs, kpack rebases all images that use the corresponding run image. In other words, with the simple single Stack resource update command you executed above, you could patch the operating system on any number of images on a registry in a matter of seconds.