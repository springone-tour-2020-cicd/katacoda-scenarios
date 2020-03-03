# What are buildpacks?

[Cloud Native Buildpacks](https://buildpacks.io), or simply `buildpacks`, are pluggable, modular components that turn source code into OCI images. These images can then be deployed to a Docker runtime system, such as Kubernetes, Docker Swarm, etc.

# Great! How can I use them?

Cloud Native Buildpack _Platforms_, or simply `platforms`, are tools that orchestrate the execution of buildpacks. 

**As end-users, whether developers or operators, we interact with a _platform_ in order to use _buildpacks_.**

In API-speak, buildpacks are tools that implement the [Buildpack Interface Specification](https://github.com/buildpacks/spec/blob/master/buildpack.md), and platforms are tools that implement the [Platform Interface Specification](https://github.com/buildpacks/spec/blob/master/platform.md).

Examples of platforms include the pack CLI, Spring Boot with Maven/Gradle plug-ins, kpack, Tekton, and Pivotal Build Service. We will cover a few of these throughout this course. This scenario focuses on the pack CLI.



Let's start by taking stock of the tools and assets that are pre-installed into the scenario environment...