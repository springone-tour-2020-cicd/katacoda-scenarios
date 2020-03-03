# Spring Boot buildpack support

Spring Boot 2.3.0.M1 introduced buildpack support directly for both Maven and Gradle. Using either `mvn spring-boot:build-image` or `gradle bootBuildImage`, you can build an image from your Spring Boot source code with a single command.

We'll see this in action in the next step, but first, let's take stock of the tools and assets that are pre-installed into the scenario environment...