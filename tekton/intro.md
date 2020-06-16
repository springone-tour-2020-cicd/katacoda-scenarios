**Course Overview**

This scenario is part of a course on [CI/CD tooling for Kubernetes deployments](https://www.katacoda.com/springone-tour-2020-cicd).

**Prerequisite:** 

Please complete the [_Intro Workflow and Prerequisites_](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/1-intro-workflow) scenario first.

**Scenario Overview: Getting Started with Tekton**

[Tekton](https://tekton.dev) is a Kubernetes-native framework for creating CI/CD systems. It includes [Pipeline and Task](https://github.com/tektoncd/pipeline) resources for declaring CI/CD workflows, as well as a [catalog](https://github.com/tektoncd/catalog) of shared resources that you can re-use.

In this scenario, you will learn how to use Tekton to create a simple pipeline that builds a container image and publishes it to Docker Hub.

By the end of this scenario, you will have:

* Installed Tekton
* Used the `tkn` CLI to execute a simple 'echo' task
* Created and executed a Tekton Task to build a container image and publish it
* Created and executed a Tekton Pipeline to build a container image and publish it

Let's begin!
