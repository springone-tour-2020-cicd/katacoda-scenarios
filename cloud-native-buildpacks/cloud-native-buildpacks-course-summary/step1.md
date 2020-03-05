# Course Recap

In this course. we learned fundamental concepts of Cloud Native Buildpacks and looked at three different platforms for building images using Cloud Native Buildpacks:

1. `pack` - local CLI tool
2. Spring Boot Maven/Gradle plug-ins
3. `kpack` - Kubernetes-native automated and hosted service

All three are implementations of the [Platform Interface Specification](https://github.com/buildpacks/spec/blob/master/platform.md), making it easy to migrate between them or other buildpack platforms with confidence that the same image will be produced.

**Cloud Native Buildpacks guarantees reproducible builds: if you run the same version of the buildpacks against the same source code, it will result in identical images (identical shas), no matter which platform you are using.**

# Which platform should I choose?

You can choose the platform that provides the best fit for the user or enterprise experience you need to address. The three platform choices we reviewed provide different features and advantages. For example:

- `pack` and `kpack` are compatible with the same wide variety of polyglot buildpacks and can hence be used to build images for apps written in a variety of frameworks, while the Spring Boot option is specific to, well, Spring Boot

- `pack` and Spring Boot are executed manually or via a script at a command line, while `kpack` runs as a service, providing a centralized and hosted option for an image building service

- Spring Boot leverages the familiar Maven and Gradle workflows by operating through a simple plug-in

# More choices!

These three options are very accessible and appealing to both developers and operators, but as we consider the challenges of enterprise operations at scale, the value of some additional features becomes evident, and indeed additional platforms are evolving to address these broader use cases. For example:

[Tanzu/Pivotal Build Service](https://pivotal.io/pivotal-build-service) builds on kpack, providing enterprise-level abstractions on top of it. Currently in Beta, it is scheduled for GA in the Spring.

[Tekton Pipelines](https://tekton.dev) provides a Kubernetes-native pipeline mechanism, and includes support for the buildpack lifecycle as well.

