**Course Overview**

This scenario is part of a course on [CI/CD tooling for Kubernetes deployments](https://www.katacoda.com/springone-tour-2020-cicd).

**Prerequisites** 

Please complete the [_Intro Workflow and Prerequisites_](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/1-intro-workflow) scenario first.

**Scenario Overview: Improve Image Lifecycle with Buildpacks**

As compared to Dockerfile, Cloud Native Buildpacks provide a higher level of abstraction and make it significantly easier for developers and operators to build images and manage them at scale.

The Cloud Native Buildpacks project was initiated by Pivotal and Heroku in January 2018 and joined the Cloud Native Sandbox in October 2018. The project brings the benefits of buildpacks to the Kubernetes ecosystem, including mature builpacks for building and packaging apps written in a variety of programming languages, and a model for centrally managing and governing buildpacks so that they can be easily shared and maintained. This project also improves upon the previous generation of Cloud Foundry and Heroku buildpacks by:

1. Making buildpacks accessible to the broader Kubernetes community - run them anywhere & deploy the resulting OCI image anywhere
2. Making it easy to modularize buildpacks - decoupled generic build process from app-specific build concerns
3. Providing a well-defined API between platforms and buildpacks, thereby fostering an ecosystem of platforms and buildpacks
4. Embracing modern container standards (e.g. OCI, Docker V2) to provide advanced features (e.g. rebasing OS layer in milliseconds) 

In this scenario, you will:
* Review the benefits of using a higher-level abstraction over Dockerfile
* Learn about Cloud Native Buildpacks through some introductory examples
* Explore two ways to use buildpacks in our CI/CD workflow

Let's begin!
