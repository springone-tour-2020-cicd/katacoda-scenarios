**Course Overview**

This scenario is part of a course on [CI/CD tooling for Kubernetes deployments](https://www.katacoda.com/springone-tour-2020-cicd).

**Prerequisites** 

Please complete the [_Intro Workflow and Prerequisites_](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/1-intro-workflow) scenario first.

**Scenario Overview: Getting Started with Kustomize**

[Kustomize](https://kustomize.io) provides a template-free way to customize application configuration.  It is available as a standalone executable called `kustomize`, and it is also integrated with `kubectl apply` using the `-k` flag.

In this scenario, you will learn how to use several features of Kustomize to better manage the dev and ops YAML files you created in the prerequisite scenario.

By the end of this scenario, you will have:

* Used a simple "kustomization" to understand the basic feature set of Kustomize
* Deployed the sample Go application to prod using different resource customizations

Let's begin!
