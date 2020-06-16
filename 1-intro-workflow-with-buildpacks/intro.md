With Kubernetes, everything from deployment to monitoring to scaling is more standardized and inherently easier to automate. This presents the possibility to achieve a more effective and comprehensive Continuous Integration (CI) and Continuous Delivery (CD) experience. We can incorporate the practice of infrastructure-as-code and take advantage of a flourishing ecosystem of tools to improve and fully automate our application deployment strategies. 

In this course, we'll explore some options for Kubernetes-centric tooling, including Tekton, Kustomize, and ArgoCD, and see how GitOps can be leveraged for CI/CD.

**Prerequisites**

To complete this course, you will need:
- A [GitHub](https://github.com) account
- A [GitHub access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) with "repo" access rights
- A [Docker Hub](https://hub.docker.com) account
- A [Docker Hub access token](https://docs.docker.com/docker-hub/access-tokens)

Once you have your access tokens ready, you can get started.

**Intro Worflow**

By the end of this scenario, you will have two new GitHub repos: sample app source code, and sample app deployment "ops" files. You will also understand the basic flow that needs to be automated: _**change code --> build image --> update ops files --> deploy**_.

Let's begin!
