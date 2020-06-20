# Dockerfile vs Buildpacks

Objective:
Understand some of the challenges in using Dockerfiles and how a higher-level abstraction, such as Cloud Native Buildpacks, can help.

Note:
For the rest of the scenario, we will use the terms _CNB_ or _buildpacks_ to refer to Cloud Native Buildpacks.

In this step, you will:
- Review the Dockerfile in the sample app
- Build the app locally using buildpacks (specifically, pack CLI and Paketo Buildpacks)
- Explore some of the characteristics and features of buildpacks

## Local environment setup
Please wait until `Environment ready!` appears in the terminal window.

## Set your GitHub and Docker Hub namespaces

Your GitHub and Docker Hub namespaces will be needed in this scenario. For convenience, set the following environment variables to your GitHub and Docker Hub namespaces (your user or org names). You can copy and paste the following command into the terminal window, then append your username or org:

```
# Fill this in with your GitHub username or org
GITHUB_NS=
```{{copy}}

```
# Fill this in with your Docker Hub username or org
IMG_NS=
```{{copy}}

## Clone repo

Start by cloning the GitHub repo you created in the [previous](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/1-intro-workflow) scenario.

```
git clone https://github.com/$GITHUB_NS/go-sample-app.git && cd go-sample-app
```{{execute}}

## Examine the Dockerfile

Take a look at the Dockerfile included with the repo

```
cat Dockerfile
```{{execute}}

This is a relatively simple Dockerfile, but every line represents a decision - good or bad - made by the Dockerfile author (use a multi-stage approach, use golang and scratch bases, handle modules and source separately, build the app as a statically-linked binary, tightly couple COPY/RUN/ENTRYPOINT to app-specific filenames, etc). Ommissions also represent Dockerfile author decisions (e.g. no .dockerfile, no LABELs, no golang base image version, etc). 

Some of these decisions are specific to Golang. If the author wanted to build a Java app, for example, they would need to make and support a new set of decisions.

In addition, Dockerfiles are simply scripts. Short of copying and pasting Dockerfiles into other app repos, there is no formalized mechanism for re-using or sharing Dockerfiles. There is also no formalized mechanism for managing Dockerfiles at enterprise-scale, where challenges of support, security, governance and transparency become critically important.

## Build with pack and Paketo

Recall the command to build and publish the app with Dockerfile:

> ```
> docker build . -t go-sample-app
> ```

In this case, we could say that the docker CLI is the tool we interact with in order to use Dockerfiles to create and publish images. The Docker daemon is also involved in the process, as the build is actually carried out by/on the daemon, rather than by the CLI itself.

With Cloud Native Buildpacks, we have a choice of tools, or "platforms" to interact with (any tool that implements the Platform API provided by the CNB project). The project itself provides a reference implementation in the form of a CLI called `pack`. Other platforms examples are the Spring Boot 2.3.0+ Maven and Gradle plugins, Tekton, and a Kubernetes-native hostable service called kpack.

In this scenario we will use pack to explore pack, Tekton, and kpack.

To replace the role that Dockerfile plays, we need an implementation of the Buildpack API, such as Paketo Buildpacks (the CNB variant of Cloud Foundry Buildpacks) or Heroku Builpacks. A Buildpack API implementation generally includes the base images used for build and runtime (akin to the golang and scratch images in our sample Dockerfile), as well as the language-specific logic (aka, all of the logic you would otherwise script in your Dockerfiles). 

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

The `pack` CLI provides additional commands you can explore. There are many resources online, including the project homepage, [buildpacks.io](buildpacks.io), and the Katacoda course [Getting Started with Cloud Native Buildpacks](https://www.katacoda.com/ciberkleid/courses/cloud-native-buildpacks).

For the purposes of this scenario, it is sufficient to know that:
- The simple `pack build` command above would work for applications written in a variety of languages (e.g. Go, Java, Node.js, .NET Core, etc), and they implement best practices particular to each language
- Builders make it trivial to manage and share buildpacks and base images
- Any platform (pack, Tekton, etc) that builds an image from the same inputs (including source code and buildpack versions) would produce an identical image
- In addition to building images, CNB enables "rebasing" images, wherein the base image layers of an existing image can be updated within seconds or milliseconds without rebuilding the image. This is a efficient and powerful security feature not possible with Dockerfile
