# First build with pack

The first platform we'll use is `pack`. Run `pack --help`{{execute}} to see the kinds of commands you can execute.

We'll use `pack build` to build our first image.

Let's start with our sample app, aptly named `spring-sample-app`. There's nothing special about this app, we're just saving time by using an existing sample.

Run the following command:
```
pack build spring-sample-app \
     --path spring-sample-app \
     --builder cloudfoundry/cnb:0.0.53-bionic
```{{execute}}


As the image is building, look through the log. Notice that pack is first downloading two images based on the builder we specified:
```
0.0.53-bionic: Pulling from cloudfoundry/cnb
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

In the **build** phase, it applies the participating buildpacks that it detected earlier, in order. Notice that each contributes to the app image in _layers_, including the JDK (to compile from source), the JRE (for the runtime image), the Build System (for the Maven build), etc...:
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

It takes some time to download the JDK, JRE, and all of the Spring and Java dependencies. Please be patient :-)

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

Don't worry, subsequent builds will be faster, and we'll take a closer look at this in a minute, but first...