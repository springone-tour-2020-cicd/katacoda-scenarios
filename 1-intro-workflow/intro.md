**Course Overview**

With Kubernetes, everything from deployment to monitoring to scaling is more standardized and inherently easier to automate. This presents the possibility to achieve a more effective and comprehensive Continuous Integration (CI) and Continuous Delivery (CD) experience. We can incorporate the practice of infrastructure-as-code and take advantage of a flourishing ecosystem of tools to improve and fully automate our application deployment strategies. 

Throughout these scenarios, we'll explore some options for Kubernetes-centric tooling, including Kustomize, Tekton, and ArgoCD, and see how GitOps can be leveraged for CI/CD.

**Scenario Overview: Intro Workflow and Prerequisites Setup**

By the end of this scenario, you will have a new GitHub repo with sample app source code and "ops" deployment files. You will also understand the basic flow that needs to be automated: _**change code --> build image --> update ops files --> deploy to dev --> promote to prod**_.

**Prerequisites**

To complete this course, you will need:
- A [GitHub](https://github.com) account
- A [GitHub access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) with "repo" access rights
- A [Docker Hub](https://hub.docker.com) account
- A [Docker Hub access token](https://docs.docker.com/docker-hub/access-tokens)

Once you have your access tokens ready, you can get started.

Let's begin!
