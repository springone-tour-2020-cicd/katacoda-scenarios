**Course Overview**

This scenario is part of a course on [CI/CD tooling for Kubernetes deployments](https://www.katacoda.com/springone-tour-2020-cicd).

**Scenario Overview**

[Kustomize](https://kustomize.io) provides a template-free way to customize application configuration.  It is available as a standalone executable called `kustomize`, and it is also integrated with `kubectl apply` using the `-k` flag.

In this scenario, you will learn how to use several features of Kustomize to better manage the dev and ops YAML files you created in the prerequisite scenario.

By the end of this scenario, you will have:

* Used a simple "kustomization" to understand the basic feature set of Kustomize
* Deployed the sample Go application to prod using different resource customizations

**Prerequisites** 

Throughout this course, you will need a [GitHub account](https://github.com) and [access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) (with "repo" access rights), as well as a [Docker Hub account](https://hub.docker.com) and [access token](https://docs.docker.com/docker-hub/access-tokens).

The scenarios are intended to be completed sequentially, starting with [_Intro Workflow and Prerequisites_](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/1-intro-workflow).

Each scenario builds on the repo(s) you create in earlier scenarios. However, a sample repo representing the starting state of each scenario is also provided, in case you want to skip ahead. Please see step 1 of this scenario for instructions on using the reference starting repo.
