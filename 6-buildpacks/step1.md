# Dockerfile vs Buildpacks

Objective:
Understand some of the challenges in using Dockerfiles and how a higher-level abstraction, such as Cloud Native Buildpacks, can help.

Note:
For the rest of the scenario, we will use the terms _CNB_ or _buildpacks_ to refer to Cloud Native Buildpacks.

In this step, you will:
- Prepare your local environment
- Review the Dockerfile in the sample app
- Build our sample app locally using the `pack` CLI and Paketo Buildpacks
- Explore some of the characteristics and features of buildpacks

## Local environment setup
Please wait until `Environment ready!` appears in the terminal window.

Your Docker Hub namespace (user or org name) will be needed in this scenario. For convenience, copy and paste the following environment variable to the terminal window, then append your Docker Hub namespace:

```
# Fill this in with your Docker Hub username or org
IMG_NS=
```{{copy}}

Your GitHub namespace (user or org name) will be needed in this scenario. For convenience, copy and paste the following environment variable to the terminal window, then append your GitHub namespace:

```
# Fill this in with your GitHub username or org
GITHUB_NS=
```{{copy}}

## Clone repo

Start by cloning the GitHub repo you created in the [intro](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/1-intro-workflow) scenario.

```
git clone https://github.com/$GITHUB_NS/go-sample-app.git && cd go-sample-app
```{{execute}}

## Examine the Dockerfile

Take a look at the Dockerfile included in the repo

```
cat Dockerfile
```{{execute}}

This is a relatively simple Dockerfile, but every line represents a decision - good or bad - made by the Dockerfile author (use a multi-stage approach, use golang and scratch base images, handle modules and source separately, build the app as a statically-linked binary, tightly couple COPY/RUN/ENTRYPOINT to app-specific filenames, etc). Ommissions also represent Dockerfile author decisions (e.g. no .dockerfile, no LABELs, no base image version, etc). 

Some of these decisions are specific to Golang. If the author wanted to build a Java app, for example, they would need to make and support a new set of decisions. Moreover, the full burden of responsibility for ensuring this Dockerfile implements best practices for efficiency, security, etc, falls on the Dockerfile author.

In addition, short of copying and pasting Dockerfiles into other app repos, there is no formalized mechanism for re-using or sharing Dockerfiles. There is also no formalized mechanism for managing Dockerfiles at enterprise-scale, where challenges of support, security, governance and transparency become critically important.

## Build with pack and Paketo

Recall the command to build and publish the app with Dockerfile:

> ```
> docker build . -t go-sample-app
> ```

In this case, we could say that the docker CLI is the tool we interact with in order to use Dockerfiles to create and publish images. The Docker daemon is also involved in the process, as the build is actually carried out by - and on - the daemon, rather than by the CLI itself.

With Cloud Native Buildpacks, we have a choice of tools, or "platforms" to interact with (any tool that implements the CNB Platform API is a _platform_). The project itself provides a reference implementation in the form of a CLI called `pack`. Other examples include the Spring Boot 2.3.0+ Maven and Gradle plugins, Tekton, and a Kubernetes-native hostable service called kpack. In this scenario we will explore pack, Tekton, and kpack.

To replace the role that Dockerfile plays, we need an implementation of the CNB Buildpack API, such as Paketo Buildpacks (the CNB variant of Cloud Foundry Buildpacks) or Heroku Buildpacks. These Buildpacks include the base images used for build and runtime (akin to the golang and scratch images in our sample Dockerfile), as well as the language-specific logic (aka, all of the logic you would otherwise script in your Dockerfiles). 


## Build with `pack` and Paketo

Run the following command in order to build the sample app using the `pack` CLI and Paketo Buildpacks:

```
pack build go-sample-app --builder gcr.io/paketo-buildpacks/builder:base-platform-api-0.3
```{{execute}}

You'll notice pack downloading the build and run base images. The build image includes all necessary buildpacks to build images for a variety of applications, including Go, Java, Nodejs, and more.

The build log shows which buildpacks are detected as applicable to this app, applies them in the proper order, and exports the layers necessary for runtime to the run image.

The built-in `lifecycle` component that is powering the build process is packaged into the builder image, and it provides optimizations that enhance image inspection and transparency through metadata, as well as build performance through sophisticated caching and layer reuse. For example, in subsequent builds, you would see the 'ANALYZING` an `RESTORING` phases reflected in the build log leveraging the cache and image layer metadata created in the first build.

You can see the resulting image on the Docker daemon:

```
docker images | grep go-sample-app
```{{execute}}

## Re-build the app, and publish to Docker Hub

`pack` can also publish the image to a registry.  In order to build and publish the image, you must first authenticate against Docker Hub. Enter your access token at the prompt:

```
docker login -u ${IMG_NS}
```{{execute}}

To simplify the `pack` command, you can also set the builder as a default:

```
pack set-default-builder gcr.io/paketo-buildpacks/builder:base-platform-api-0.3
```{{execute}}

Now, you can rebuild the app and publish to Docker Hub with the following command. You should notice the build is faster this time, partially because the base images are now accessible locally, and partially because of efficient caching and image-layer re-use:

```
pack build $IMG_NS/go-sample-app --publish
```{{execute}}

## Additional features

The `pack` CLI provides additional commands you can explore that expose the capabilities of Cloud native Buildpacks. You can leanr more through the project homepage, [buildpacks.io](buildpacks.io), or through the Katacoda course [Getting Started with Cloud Native Buildpacks](https://www.katacoda.com/ciberkleid/courses/cloud-native-buildpacks), or other online resources. For the purposes of this scenario, however, it is sufficient to know that:
- The simple `pack build` command above would work for applications written in a variety of languages (e.g. Go, Java, Node.js, .NET Core, etc), and they implement best practices particular to each language
- Builders make it trivial to manage and share buildpacks and base images
- Any platform (pack, Tekton, etc) that builds an image from the same inputs (including source code and buildpack versions) would produce an identical image
- In addition to building images, CNB enables "rebasing" images, wherein the base image layers of an existing image can be updated within seconds or milliseconds without rebuilding the image. This is a efficient and powerful security feature not possible with Dockerfile
