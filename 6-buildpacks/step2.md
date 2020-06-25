# Dockerfile vs Buildpacks

Objective:
Understand some of the challenges in using Dockerfiles and how a higher-level abstraction, such as Cloud Native Buildpacks, can help.

Note:
For the rest of the scenario, we will use the terms _CNB_ or _buildpacks_ to refer to Cloud Native Buildpacks.

In this step, you will:
- Review the Dockerfile in the sample app
- Build our sample app locally using the `pack` CLI and Paketo Buildpacks
- Explore some of the characteristics and features of buildpacks

## Examine the Dockerfile

Take a look at the Dockerfile included in the repo

```
cd go-sample-app
cat Dockerfile
```{{execute}}

This is a relatively simple Dockerfile, but every line represents a decision - good or bad - made by the Dockerfile author (use a multi-stage approach, use golang and scratch base images, handle modules and source separately, build the app as a statically-linked binary, tightly couple COPY/RUN/ENTRYPOINT to app-specific filenames, etc).
Ommissions also represent Dockerfile author decisions (e.g. no .dockerfile, no LABELs, no base image version, etc).

Some of these decisions are specific to Golang.
If the author wanted to build a Java app, for example, they would need to make and support a new set of decisions.
Moreover, the full burden of responsibility for ensuring this Dockerfile implements best practices for efficiency, security, etc, falls on the Dockerfile author.

In addition, short of copying and pasting Dockerfiles into other app repos, there is no formalized mechanism for re-using or sharing Dockerfiles.
There is also no formalized mechanism for managing Dockerfiles at enterprise-scale, where challenges of support, security, governance and transparency become critically important.

## Build with pack and Paketo

Recall the command to build and publish the app with Dockerfile:

> ```
> docker build . -t go-sample-app
> ```

In this case, we could say that the docker CLI is the tool we interact with in order to use Dockerfiles to create and publish images.
The Docker daemon is also involved in the process, as the build is actually carried out by - and on - the daemon, rather than by the CLI itself.

With Cloud Native Buildpacks, we have a choice of tools, or "platforms" to interact with (any tool that implements the CNB Platform API is a _platform_).
The project itself provides a reference implementation in the form of a CLI called `pack`.
Other examples include the Spring Boot 2.3.0+ Maven and Gradle plugins, Tekton, and a Kubernetes-native hostable service called kpack.
In this scenario we will explore pack, Tekton, and kpack.

To replace the role that Dockerfile plays, we need an implementation of the CNB Buildpack API, such as Paketo Buildpacks (the CNB variant of Cloud Foundry Buildpacks) or Heroku Buildpacks.
These Buildpacks include the base images used for build and runtime (akin to the golang and scratch images in our sample Dockerfile), as well as the language-specific logic (aka, all of the logic you would otherwise script in your Dockerfiles).


## Build with `pack` and Paketo

In this section, you will build the image using Paketo Buildpacks and publish the image to the registry in a single command. 
You have already authenticated with Docker Hub, so you can simply run the following command in order to build and publish  the sample app using the `pack` CLI and Paketo Buildpacks.

```
pack set-default-builder gcr.io/paketo-buildpacks/builder:base-platform-api-0.3

pack build $IMG_NS/go-sample-app:pack-0.0.1 --publish
```{{execute}}

You'll notice `pack` downloading a builder image.
The `builder` image provides a build environment, analogous to the golang image in the first stage of our Dockerfile. 
The `builder` also contains all necessary buildpacks to build images for a variety of applications, including Go, Java, Nodejs, and more. 
This is analogous to all of the instructions in our Dockerfile, with implemented best practices on building a variety of applications. 

The build log also shows downloading a `lifecycle`. 
The `lifecycle` is the engine that powers the build. This is analogous to the role that the docker daemon plays with a `docker build`.

The build log shows which buildpacks are applied to the application, and the layers that arre copied to the run image.

The `EXPORTING` phase of the build log copies layers generated during the build to a slimmer `run` image, which is analogous to the base image in the second stage of our Dockerfile. It also populates a cache to speed up subsequent builds.

The `lifecycle` provides optimizations that enhance image inspection and transparency through metadata, as well as build performance through sophisticated caching and layer reuse.
In future builds you would see the `ANALYZING` and `RESTORING` phases leveraging the cache and image layer metadata created in the first build.

Take note of the digest (sha256 uuid) reported at the end of the build log.

You can also check your [Docker Hub](https://hub.docker.com/) account to see the image published by pack.
You should see the same digest there.

You can also see the Paketo builder image that `pack` downloaded locally in order to carry out the build:

```
docker images | grep paketo
```{{execute}}

## Rebase

Imagine that a vulnerability has been detected in the base OS, and that an OS patch is made availabel.
With Dockerfile, it would be very challenging to patch images, especially at scale.
You would need to have insight into the images that different Dockerfiles use, determine which need patching, make or obtain patched versions of the base images, and rebuild all images.
This means you would likely need substantial re-testing as well.

Cloud Native Buildpacks improves this challenge in several ways:
- The same run image is used across across all applications
- The run image is managed centrally through the builder, so the update can be easily provided for all future builds
- The update run image is guaranteed to be compatible, via an Application Binary Interface
- The patching operation updates existing app images to point to updated base image layers in the new run image. This operation is fast and does not involve rebuilding the application or the image.

Let's simulate this using the `pack rebase` command.

First, download the "patched" OS (we will simply use a run image of a different version than the one used to build the image).
```
docker pull gcr.io/paketo-buildpacks/run:0.0.19-base-cnb
docker images | grep paketo
```{{execute}}

The builder is pointing to a run image with tag `gcr.io/paketo-buildpacks/run:base-cnb`. 
Add this tag to the run image.
```
docker tag gcr.io/paketo-buildpacks/run:0.0.19-base-cnb gcr.io/paketo-buildpacks/run:base-cnb
docker images | grep paketo
```{{execute}}

Now, rebase the image.
Use the `--no-pull` flag ensure pack uses the local run image you just tagged.
```
pack rebase $IMG_NS/go-sample-app:pack-0.0.1 --publish --no-pull
```{{execute}}

Notice that the image digest is different.
You can validate that a new image with the new digest has been pushed to Docker Hub as well.

## Additional features

The `pack` CLI provides additional commands you can explore that expose the capabilities of Cloud native Buildpacks.
You can learn more through the project homepage, [buildpacks.io](buildpacks.io), or through the Katacoda course [Getting Started with Cloud Native Buildpacks](https://www.katacoda.com/ciberkleid/courses/cloud-native-buildpacks), or other online resources.
For the purposes of this scenario, however, it is sufficient to know that:
- The simple `pack build` command above would work for applications written in a variety of languages (e.g. Go, Java, Node.js, .NET Core, etc), and they implement best practices particular to each language
- Builders make it trivial to manage and share buildpacks and base images
- Any platform (pack, Tekton, Spring Boot, etc) that builds an image from the same inputs (including source code and buildpack versions) would produce an identical image
- ~~Rebasing~~ images, wherein the base image layers of an existing image can be updated within seconds or milliseconds without rebuilding the image, is a powerful and efficient security feature not possible with Dockerfile
