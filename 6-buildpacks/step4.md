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
Use the following commands to wait until the deployment "rollouts" succeed:

```
kubectl rollout status deployment/kpack-controller -n kpack
kubectl rollout status deployment/kpack-webhook -n kpack
```{{execute}}

The installation also includes several Custom Resource Definitions (CRDs) that provide the Kubernetes primitives to configure kpack. 
Notice the "KIND" column. In this step, we will configure a Builder and an Image.

```
kubectl api-resources --api-group build.pivotal.io
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

Configure an Image resource. The Image resource will create a Build every time it needs to produce an image. As with `pack` and Tekton, you need to provide three inputs:
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
  tag: $IMG_NS/go-sample-app:kpack-0.0.1
EOF
```{{execute}}

Note: We are leaving cacheSize commented out above because the katacoda scenario environment would require some additional configuration to provide the underlying storage-provisioning to support caching.

To provide write access to Docker Hub, notice that a new service account, `kpack-bot`, is specified in the Image above. 
It is better practice to set up a new service account, rather thn re-use the Tekton service account. 
The new service account can leverage the same `regcred` secret with Docker Hub credentials. 
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

Within a short time, you should see a new image in your [Docker Hub](https://hub.docker.com) account. 
In the meantime, continue reading to learn how kpack works behind the scenes and how you can trace progress and results.

## Behind the scenes

To understand some of the mechanics of how the image is created, notice that the Image resource creates a Build resource for each build that it does. At the moment you should see one Build resoure:

```
kubectl get builds
```{{execute}}


You can use `kubectl describe` to get more information about the build, including, for example, the git commit id of the source code (see the `Revision` node).

```
kubectl describe build go-sample-app-build-1-
```{{copy}}

The Build creates a Pod in order to execute the build and produce the image.

```
kubectl get pods | grep go-sample-app-build-1
```{{execute}}

The Pod comprises a separate _init_ container for each phase of the lifecycle, and a simple `kubectl logs` command will not expose the logs of each init container. Therefor, kpack provides a `logs` CLI to make it easy to extract the logs for a build.

```
logs -image go-sample-app -build 1
```{{execute}}

You should see logging similar to the logging you saw with `pack` and Tekton, since the underlying process using the Paketo Builder is the same.

When the log shows that the build is done, check your [Docker Hub](https://hub.docker.com) to validate that an image has been published. The image will have a tag as specified in your Image configuration, as well as an auto-generated tag. Both tags are aliasing the same image digest.

If necessary, `Send Ctrl+C`{{execute interrupt T1}} to stop tailing the log.

## Trigger a new build

By default, kpack will poll the source code repo, the builder image, and the run image every 5 minutes, and will automatically rebuild - or rebase, as apporpriate - if it detects a new commit.

Notice that the Image resource is configured to poll the master branch on the app repo. That means any commit to the master branch will trigger a build.

Make a code change and push to GitHub. Provide your access token at the prompt.

```
cd /workspace/go-sample-app

sed -i 's/sunshine/friends/g' hello-server.go

git add -A
git commit -m "Hello, friends!"
git push origin master
```{{execute}}

Use the commands above or go to Docker Hub to validate that kpack builds a new image. Keep in mind it may take up to 5 minutes for kpack to detect the change. 
