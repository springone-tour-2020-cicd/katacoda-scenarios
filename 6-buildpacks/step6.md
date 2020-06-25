# Rebasing with kpack

Objective:

Demonstrate a rebase using `kpack`.

In this step, you will:
- Reconfigure the `kpack` Builder resource so that you can demonstrate a rebase
- Trigger a rebase and observe `kpack` update the image

## Reconfigure the Builder resource

In the last step, you configured a Builder that points to the Paketo Buildpacks at `gcr.io/paketo-buildpacks/builder:base-platform-api-0.3`. 
If that builder is updated, or if the run image that it references is updated, `kpack` will rebuild (or rebase) the go-sample-app image.

Since these builder and run images are controlled by the Paketo Buildpacks project, we cannot influence the release of an update in order to catalyze a rebase. 
However, we can reconfigure our Builder in such a way that we can trigger a rebase.

Create a new CustomBuilder in which you can separately define the building blocks of a builder:
- [Store](https://github.com/pivotal/kpack/blob/master/docs/custombuilders.md#store): a list of images that contain **buildpacks**. As we explained earlier, builders include buildpacks, so we can use a builder as a source of buildpacks.
- [Stack](https://github.com/pivotal/kpack/blob/master/docs/custombuilders.md#stack): the OS stack, used for both the build-time and run-time images. You will use `io.buildpacks.stacks.bionic` in the configuration below (Ubuntu 18.04), but you can use `pack suggest-stacks`{{execute}} to see some additional OSS options.
- [CustomBuilder](https://github.com/pivotal/kpack/blob/master/docs/custombuilders.md#custom-builders): the builder, which comprises the _Store_ (buildpacks) and _Stack_ (base OS), and specifies the order in which to process buildpack groups. For reference of how to configure this, you can check `pack inspect-builder gcr.io/paketo-buildpacks/builder:base-platform-api-0.3`{{execute}}

Review the configuration below, and execute the command to save it to a file.

```
cd /workspace/go-sample-app-ops/cicd/kpack

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

## Build images

To show kpack building and rebasing images "at scale", create three new Image manifests using the new CustomBuilder you just created. Give each image a different name, to simulate different applications you might be building.

```
yq w image.yaml "metadata.name" go-sample-app-1 | \
    yq w - "spec.builder.kind" CustomBuilder | \
    yq w - "spec.builder.name" paketo-custom-builder > image-1.yaml

yq w image-1.yaml "metadata.name" go-sample-app-2 > image-2.yaml

yq w image-1.yaml "metadata.name" go-sample-app-3 > image-3.yaml
```{{execute}}

Apply the new Image manifests.

```
kubectl apply -f image-1.yaml \
              -f image-2.yaml \
              -f image-3.yaml
```{{execute}}

After a short time, you should see three new images on your Docker Hub account.

You can also track the progress of the builds using the commands you used earlier:

```
kubectl get builds
```{{execute}}

```
kubectl describe build <BUILD_NAME>
```{{copy}}

Notice that the `kubectl describe build` output includes an Annotation stating that the reason for build was "CONFIG".

```
logs -image go-sample-app-1 -build 1
```{{copy}}

## Rebase images

To trigger a rebase, update the Stack resource with an updated run image, and apply the change to the cluster.

```
sed -i 's/run:0.0.19-base-cnb/run:0.0.20-base-cnb/g' custom-builder.yaml

kubectl apply -f custom-builder.yaml
```{{execute}}

Monitor builds again, and notice that kpack automatically updates all images using the updated stack.

You can validate that `kpack` is rebasing rather than rebuilding in a couple of ways. The build log specifically reflects a rebase rather than a build:

```
logs -image go-sample-app-1 -build 2
```{{copy}}

In addition, the reason reported in the Build resource is "STACK". Run the command belwo and find the Annotation stating the build reason was "STACK".

```
kubectl describe build <BUILD_NAME>
```{{copy}}
