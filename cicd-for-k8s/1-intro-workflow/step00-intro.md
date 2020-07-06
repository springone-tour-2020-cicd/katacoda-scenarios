**Course Overview**

This scenario is part of a course on [CI/CD tooling for Kubernetes deployments](https://www.katacoda.com/springone-tour-2020-cicd/courses/cicd-for-k8s). 
In this course, we explore some options for Kubernetes-centric tooling for Continuous Integration (CI) and Continuous Delivery (CD), including Kustomize, Tekton, Argo CD, Cloud Native Buildpacks, and kpack. 
Through these excercises, we will also see how GitOps can be leveraged for CI/CD.

With Kubernetes, everything from deployment to monitoring to scaling is more standardized and inherently easier to automate. 
This presents the possibility to achieve a more effective and comprehensive CI/CD experience. 
We can incorporate the practice of infrastructure-as-code and take advantage of a flourishing ecosystem of tools to improve and fully automate our application deployment strategies.

The scenarios in this course are designed to be completed in order as they appear on the course home page. 
You will begin with a manual build-deploy-promote workflow and automate it as you explore the tools and techniques included in this course. 
"Short-cut" reference repos are also provided in case you want to skip ahead.

**Scenario Overview**

By the end of this scenario, you will have a new GitHub repo with sample app source code and "ops" deployment files. 
You will also understand the basic flow that needs to be automated: _**change code --> build image --> update ops files --> deploy to dev --> promote to prod**_.

**Prerequisites**

To complete this course, you will need:
- A [GitHub](https://github.com) account
- A [GitHub access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) with "repo" access rights
- A [Docker Hub](https://hub.docker.com) account
- A [Docker Hub access token](https://docs.docker.com/docker-hub/access-tokens)

Once you have your access tokens ready, you can get started.

Let's begin!
