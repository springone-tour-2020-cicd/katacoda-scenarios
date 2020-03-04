# Spring Boot buildpack support

The next platform we'll explore is Spring Boot.
 
Spring Boot 2.3.0.M1 introduced buildpack support directly for both Maven and Gradle. Using either `mvn spring-boot:build-image` or `gradle bootBuildImage`, you can build an image from your Spring Boot source code with a single command.

Let's see this in action. Notice that our sample Spring app uses a version of Spring Boot that includes buildpack support (2.3.0.M1 or later): 
```
cd ~/spring-sample-app
head pom.xml 
```{{execute}}

Before we build the image, just for kicks, let's make another minor code change:
```
sed -i 's/Greetings Earth/Howdy everyone/g' src/main/java/com/example/springsampleapp/HelloController.java
```{{execute}}

Validate the code change:
```
tail src/main/java/com/example/springsampleapp/HelloController.java
```{{execute}}

Now, build the project using the new `spring-boot:build-image` Maven plugin:
```
./mvnw spring-boot:build-image
```{{execute}}

You should see evidence of the image build in the log. A few observations:
- In this case, Maven builds the jar before invoking the buildpack lifecycle, so you will see Maven building the jar file as usual before the build-image plugin is invoked. 
- When the build-image plugin is invoked, you should recognize the lifecycle phases that we observed with `pack`. Notice that the build phase does not rebuild the jar from source. Rather, it builds the image using the jar file that Maven just created.
- Spring Boot's choice of default builder is the same one we chose for `pack` (this is [configurable](https://docs.spring.io/spring-boot/docs/2.3.0.M2/maven-plugin/html/#build-image-example-custom-image-builder)), so we can be confident that the image is being built in the same way by either platform.
```
[INFO] Building image 'docker.io/library/spring-sample-app:0.0.1-SNAPSHOT'
[INFO]
[INFO]  > Pulling builder image 'docker.io/cloudfoundry/cnb:0.0.53-bionic' 100%
...
[INFO]  > Pulling run image 'docker.io/cloudfoundry/run:base-cnb' 100%
...
[INFO]  > Executing lifecycle version v0.6.1
[INFO]  > Using build cache volume 'pack-cache-5cbe5692dbc4.build'
[INFO]
[INFO]  > Running detector
[INFO]     [detector]    6 of 13 buildpacks participating
...
[INFO]  > Running analyzer
...
[INFO]  > Running restorer
[INFO]
[INFO]  > Running builder
...
[INFO]  > Running exporter
...
[INFO]     [exporter]    Adding 6/6 app layer(s)
...
[INFO] Successfully built image 'docker.io/library/spring-sample-app:0.0.1-SNAPSHOT'
```

Check to see that an image has been created:
```
docker images | grep spring-sample-app
```{{execute}}

Notice that, in contrast with `pack`, the name of the published image is automatically inferred from the application name, and the tag is inferred from the version.

Start your application using `docker run`:
```
docker run -it -p8080:8080 spring-sample-app:0.0.1-SNAPSHOT
```{{execute}}

Send a request to the app:
```
curl localhost:8080; echo
```{{execute T2}}

`Send Ctrl+C`{{execute interrupt T1}} to stop the app before proceeding to the next step.
