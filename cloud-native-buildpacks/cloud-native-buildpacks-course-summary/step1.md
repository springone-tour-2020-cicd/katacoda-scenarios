# Course Recap

In this course. we learned fundamental concepts of Cloud Native Buildpacks and looked at three different platforms for building images using Cloud Native Buildpacks:

1. `pack` - local CLI tool
2. Spring Boot Maven/Gradle plug-ins
3. `kpack` - Kubernetes-native automated and hosted service

All three are implementations of the [Platform Interface Specification](https://github.com/buildpacks/spec/blob/master/platform.md), making it easy to migrate between them or other buildpack platforms with confidence that the same image will be produced.

**Cloud Native Buildpacks guarantees reproducible builds: if you run the same version of the buildpacks against the same source code, it will result in identical images (identical shas), no matter which platform you are using.**