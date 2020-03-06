# Why Cloud Native Buildpacks over Dockerfile or Jib?

Let's highlight some advantages of Cloud Native Buildpacks over two popular alternatives, Dockerfile and Jib.

**Dockerfile**

Dockerfile boils down to manually declaring how to build an image from an app. It requires more work to create and maintain, placing a burden on developers and introducing variability and inconsistency across apps and teams. Image updates are inefficient (read more [here](https://spring.io/blog/2020/01/27/creating-docker-images-with-spring-boot-2-3-0-m1)) and any best practices on creating, sharing, managing, and maintaining Dockerfiles are left to each developer or team to discover, implement, and enforce.

- Cloud Native Buildpacks provide the bility to make changes in a centralized place (the builder) - all applications using the builder will pick up the change
- Cloud Native Buildpacks provide consistent, reproducible builds for a variety of frameworks (Java, NodeJS, Python, Golang, .NET Core, PHP, HTTPD, NGINX, Scala, and Ruby)

**Jib**

The user experience with Jib is most comparable to the built-in support of Spring Boot for Cloud Native Buildpacks. It is a great option for apps not using versions of Spring Boot 2.3.0.M1 or later. Otherwise, consider the following advantages of Cloud Native Buildpacks:

- Integration directly with the Spring Boot Maven and Gradle plugins
- Ability to guarantee the same image can be produced if you choose to migrate platforms or take advantage of a service like kpack in a mature CI/CD workflow
- Cloud Native Buildpack [cloudfoundry/openjdk-cnb](https://github.com/cloudfoundry/openjdk-cnb) includes a memory calculator, which calculates suitable memory settings for Java apps. For additional detail on the memory calculator, you can also refer to the [older Java Buildpack documentation](https://github.com/cloudfoundry/java-buildpack-memory-calculator), from which the code was ported to the Cloud Native Buildpack code base.