**Course Overview**

This scenario is part of a course on [CI/CD tooling for Kubernetes deployments](https://www.katacoda.com/springone-tour-2020-cicd).
Please visit the [intro scenario](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/1-intro-workflow) for more information about the course.

**Scenario Overview**

As compared to Dockerfile, Cloud Native Buildpacks provide a higher level of abstraction and make it significantly easier for developers and operators to build images and manage them at scale.

The Cloud Native Buildpacks project was initiated by Pivotal and Heroku in January 2018 and joined the Cloud Native Sandbox in October 2018.
The project brings the benefits of buildpacks to the Kubernetes ecosystem, including mature builpacks for building and packaging apps written in a variety of programming languages, and a model for centrally managing and governing buildpacks so that they can be easily shared and maintained.
This project also improves upon the previous generation of Cloud Foundry and Heroku buildpacks by:

1. Making buildpacks accessible to the broader Kubernetes community - run them anywhere & deploy the resulting OCI image anywhere
2. Making it easy to modularize buildpacks - decouple generic build process from app-specific build concerns
3. Providing a well-defined API between platforms and buildpacks - foster an ecosystem of platforms and buildpacks
4. Embracing modern container standards (e.g. OCI, Docker V2) - provide advanced features (e.g. rebasing OS layer in milliseconds) 

In this scenario, you will:
* Review the benefits of using a higher-level abstraction over Dockerfile
* Learn about Cloud Native Buildpacks through some introductory examples
* Explore two ways to use buildpacks in our CI/CD workflow

**Prerequisites** 

Throughout this course, you will need a [GitHub account](https://github.com) and [access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) (with "repo" access rights), as well as a [Docker Hub account](https://hub.docker.com) and [access token](https://docs.docker.com/docker-hub/access-tokens).

The scenarios are intended to be completed sequentially, starting with [_Intro Workflow and Prerequisites_](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/1-intro-workflow).

Each scenario builds on the repo(s) you create in earlier scenarios.
However, a sample repo representing the starting state of each scenario is also provided, in case you want to skip ahead.
Please see step 1 of this scenario for instructions on using the reference starting repo.
