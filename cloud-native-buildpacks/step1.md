Let's begin by creating a simple Spring Boot application using (Spring Initializr)[https://start.spring.io/]. 

Create the project using start.spring.io
```
curl https://start.spring.io/starter.zip -d bootVersion=2.3.0.M2 -d dependencies=web -o demo.zip
unzip demo.zip demo
cd demo
```{{execute}}

Build the project using the Maven `spring-boot:build-image` plug-in
```
./mvnw spring-boot:build-image
```{{execute}}

You should see something like this in the log:
```
[INFO] Building image 'docker.io/library/demo:0.0.1-SNAPSHOT'
[INFO]
[INFO]  > Pulling builder image 'docker.io/cloudfoundry/cnb:0.0.53-bionic' 100%
[INFO]  > Pulled builder image 'cloudfoundry/cnb@sha256:83270cf59e8944be0c544e45fd45a5a1f4526d7936d488d2de8937730341618d'
[INFO]  > Pulling run image 'docker.io/cloudfoundry/run:base-cnb' 100%
[INFO]  > Pulled run image 'cloudfoundry/run@sha256:9e366d007db857d7bcde2edb0439cf8159cb9ddb9655bee21ba479c06ae8f42d'
[INFO]  > Executing lifecycle version v0.6.1
[INFO]  > Using build cache volume 'pack-cache-5cbe5692dbc4.build'
[INFO]
[INFO]  > Running detector
[INFO]     [detector]    6 of 13 buildpacks participating
[INFO]     [detector]    org.cloudfoundry.openjdk                   v1.2.11
[INFO]     [detector]    org.cloudfoundry.jvmapplication            v1.1.9
[INFO]     [detector]    org.cloudfoundry.tomcat                    v1.3.9
[INFO]     [detector]    org.cloudfoundry.springboot                v1.2.9
[INFO]     [detector]    org.cloudfoundry.distzip                   v1.1.9
[INFO]     [detector]    org.cloudfoundry.springautoreconfiguration v1.1.8
[INFO]
[INFO]  > Running analyzer
[INFO]     [analyzer]    Warning: Image "docker.io/library/demo:0.0.1-SNAPSHOT" not found
[INFO]
[INFO]  > Running restorer
[INFO]
[INFO]  > Running builder
...
[INFO]  > Running exporter
...
[INFO]     [exporter]    Adding 6/6 app layer(s)
...
[INFO] Successfully built image 'docker.io/library/demo:0.0.1-SNAPSHOT'
```
<br>

Check to see that an image has been created
```
docker images | grep demo
```{{execute}}

Test your application using:
```
docker run -it -p8080:8080 demo:0.0.1-SNAPSHOT
```{{execute}}

In the next step, we will use the `pack` CLI to build an image from cource code.

