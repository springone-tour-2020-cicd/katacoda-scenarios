# First build with pack

Run `pack --help`{{execute}} to see the kinds of commands `pack` can execute.

We'll use the command `pack build` to build an image from our sample app. In our command, we will specify:
 - a name for the image to be created
 - the path to the app source code
 - the builder we want to use (more on this later)
 
It's worth noting that there's nothing special about our app, we're just saving time by using an existing sample.

Run the following command:
```
pack build spring-sample-app \
     --path spring-sample-app \
     --builder cloudfoundry/cnb:bionic
```{{execute}}

The first build may take a few minutes as it has to download all of the bits and bytes needes for building the image, including the builder, JDK, JRE, all of the Spring and Java dependencies... Please be patient - subsequent builds will be faster. As the build is progressing, take the time to look through the log and keep reading below for an explanation of what is happening.

Notice that pack is first downloading two images based on the builder we specified:
```
bionic: Pulling from cloudfoundry/cnb
...
base-cnb: Pulling from cloudfoundry/run
...
```

It then begins executing the buildpack [lifecycle](https://buildpacks.io/docs/concepts/components/lifecycle).

In the **detection** phase, we see that the builder automatically detects which buildpacks to use:
```
===> DETECTING
[detector] 7 of 13 buildpacks participating
[detector] org.cloudfoundry.openjdk                   v1.2.11
...
```

In the **analysis & restore** phases, it finds opportunities for optimization and for restoring from cache. Since this is the first time we are using the specified builder and building this image, there are none:
```
===> ANALYZING
[analyzer] Warning: Image "index.docker.io/library/spring-sample-app:latest" not found
===> RESTORING
```

In the **build** phase, it applies the participating buildpacks that it detected earlier, in order. Notice that each contributes to the app image in _layers_, including the JDK (to compile from source), the JRE (for the runtime image), the Build System (for the Maven build), etc...
```
===> BUILDING
[builder]
[builder] Cloud Foundry OpenJDK Buildpack v1.2.11
[builder]   OpenJDK JDK 11.0.6: Contributing to layer
...
[builder]   OpenJDK JRE 11.0.6: Contributing to layer
...
[builder] Cloud Foundry Build System Buildpack v1.2.9
[builder]     Using wrapper
[builder]     Linking Cache to /home/cnb/.m2
[builder]   Compiled Application (133 files): Contributing to layer
...
[builder] [INFO] Replacing main artifact with repackaged archive
[builder] [INFO] ------------------------------------------------------------------------
[builder] [INFO] BUILD SUCCESS
[builder] [INFO] ------------------------------------------------------------------------
...
[builder] Cloud Foundry JVM Application Buildpack v1.1.9
[builder]   Executable JAR: Contributing to layer
```

In the **export** phase, it produces the layered OCI image for our application. Layering will make it more efficient to update in the future. The image name is the name we specified in our `pack build` command; the tag is `latest` since we didn't specify a tag.
```
===> EXPORTING
[exporter] Adding layer 'launcher'
...
[exporter] Adding layer 'org.cloudfoundry.openjdk:openjdk-jre'
[exporter] Adding layer 'org.cloudfoundry.openjdk:security-provider-configurer'
...
[exporter] *** Images (c38380737b91):
[exporter]       index.docker.io/library/spring-sample-app:latest
```

The export phase also caches layers, enabling more efficient re-builds in the future. 
```
[exporter] Adding cache layer 'org.cloudfoundry.openjdk:openjdk-jdk'
[exporter] Adding cache layer 'org.cloudfoundry.buildsystem:build-system-application'
...
```

Wait until the command completes. You should see `Successfully built image spring-sample-app` as the last line in the log.