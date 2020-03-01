# Configure kpack

Let's configure kpack to build an image from our spring-sample-app.

As with the previous platforms we looked at, we need to specify the builder, the source code, and the image repository.

In the case of pack and Spring Boot, we used our local clone of the source code and the local Docker daemon as the image source and destination. 

Since kpack runs as a service on a kubernetes cluster, it does not have access to the source code or Docker daemon on the local host. Hence, we'll use GitHub as the location of the source code, and Docker Hub as the destination for the image.

In short, we need to configure:
- the builder to use
- the source code on GitHub, with proper read access
- the repository on Docker Hub, with proper write access
