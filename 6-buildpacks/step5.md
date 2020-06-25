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
  serviceAccount: build-bot
  stack: paketo-bionic-stack
  store: paketo-store
  order:
  - group:
    - id:  paketo-buildpacks/go
  - group:
    - id:  paketo-buildpacks/java
  - group:
    -id: paketo-buildpacks/nodejs
  - group:
    -id: paketo-buildpacks/dotnet-core
  - group:
    -id: paketo-buildpacks/nginx
  - group:
    -id: paketo-buildpacks/procfile
EOF
```{{execute}}

Note that, for convenience, we are reusing the build-bot service account and Docker Hub credentials that were configured for Tekton. If you skipped the Tekton step, make sure you log in using `docker` and create the registry secret (see Step 1) and create the ServiceAccount (`kubectl apply -f ../tekton/sa.yaml`{{execute}}).

Apply the CustomBuilder to the cluster.

```
kubectl apply -f custom-builder.yaml
```{{execute}}

Briefly, you should see a builder image called paketo-custom-builder published to your Docker Hub account. With the above configuration, you have effectively created your own builder.

Update the image you created in the last step to use the custom builder:

```
yq w -i image.yaml "spec.builder.kind" CustomBuilder 
yq w -i image.yaml "spec.builder.name" paketo-custom-builder
```{{execute}}

Now, apply the updated Image manifest. The image will use the builder you just created.

```
kubectl apply -f image.yaml
```{{execute}}

To track the progress of the build, you cna use the commands below.

```
kubectl get builds
```{{execute}}

```
kubectl describe build go-sample-app-build-<num>-<uuid>
```{{copy}}

Notice that the `kubectl describe build` output includes an Annotation stating that the reason for build was "CONFIG".

```
logs -image go-sample-app -build <num>
```{{copy}}

## Update the run image to trigger a rebase

To trigger a rebase, update the Stack resource with an updated run image, and apply the change to the cluster.

```
sed -i 's/run:0.0.19-base-cnb/run:0.0.20-base-cnb/g' custom-builder.yaml

kubectl apply -f custom-builder.yaml
```{{execute}}


