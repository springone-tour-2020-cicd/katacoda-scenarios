The [Tekton Pipeliens](https://github.com/tektoncd/pipeline/tree/v0.10.1/docs#tekton-pipelines) project provides Kubernetes-style resources for declaring CI/CD-style pipelines.

In this tutorial, you will learn how to use Tekton to create a simple pipeline that builds a container image of a Spring Boot application and publish it to Docker Hub.

**Prerequisite:** Follow the tutorial [_Intro Workflow and Prerequisites_](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/1-intro-workflow)

After this tutorial you will have:

* Installed Tekon and use the CLI tool `tkn` to execute a simple 'echo' task.
* Created and execute a Tekton Task to build a container image and publish it.
* Created and execute a Tekton Pipeline to build a container image and publish it.

Let's begin!

