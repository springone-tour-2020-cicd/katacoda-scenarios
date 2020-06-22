**Course Overview**

This scenario is part of a course on [CI/CD tooling for Kubernetes deployments](https://www.katacoda.com/springone-tour-2020-cicd).

**Scenario Overview**

[Tekton](https://tekton.dev) is a Kubernetes-native framework for creating CI/CD systems. It includes [Pipeline and Task](https://github.com/tektoncd/pipeline) resources for declaring CI/CD workflows, as well as a [catalog](https://github.com/tektoncd/catalog) of shared resources that you can re-use.

In this scenario, you will learn how to use Tekton to create a simple pipeline that builds a container image and publishes it to Docker Hub.

By the end of this scenario, you will have:

* Installed Tekton
* Used the `tkn` CLI to execute a simple 'echo' task
* Created and executed a Tekton Task to build a container image and publish it
* Created and executed a Tekton Pipeline to build a container image and publish it

**Prerequisites** 

Throughout this course, you will need a [GitHub account](https://github.com) and [access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) (with "repo" access rights), as well as a [Docker Hub account](https://hub.docker.com) and [access token](https://docs.docker.com/docker-hub/access-tokens).

The scenarios are intended to be completed sequentially, starting with [_Intro Workflow and Prerequisites_](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/1-intro-workflow).

Each scenario builds on the repo(s) you create in earlier scenarios. However, a sample repo representing the starting state of each scenario is also provided, in case you want to skip ahead. Please see step 1 of this scenario for instructions on using the reference starting repo.
