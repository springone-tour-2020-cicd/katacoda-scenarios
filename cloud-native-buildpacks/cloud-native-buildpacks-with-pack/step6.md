# pack deep-dive

`pack` also allows us to inspect our app image:
```
pack inspect-image spring-sample-app
```{{execute}}

You can see the run image and the buildpacks used to create the app image. What if you want to influence the build by adding a few instructions? One option is to add a custom buildpack.

### Add a custom buildpack

Since buildpacks are modular and pluggable, we can contribute our own custom buildpacks to the build. You can read more about creating custom buildpacks [here](https://github.com/buildpacks/samples/tree/master/buildpacks) later, but for now, re-run the command as shown below. Note that we are declaring all of the buildpacks that were used by default (as listed in the `inspect-image` command output), and adding our custom buildpack to the sequence:
```
pack build spring-sample-app \
     --buildpack org.cloudfoundry.openjdk \
     --buildpack org.cloudfoundry.buildsystem \
     --buildpack org.cloudfoundry.jvmapplication \
     --buildpack org.cloudfoundry.tomcat \
     --buildpack org.cloudfoundry.springboot \
     --buildpack org.cloudfoundry.distzip \
     --buildpack org.cloudfoundry.springautoreconfiguration \
     --buildpack ~/samples/buildpacks/hello-world
```{{execute}}

Find the log entries showing the custom buildpack was executed, starting with:
```
[builder] ---> Hello World buildpack
```

Look through the rest of the log and notice that the existing layers and cache, which were not altered by the addition of the custom buildpack, were re-used.

You can also inspect the image again to validate the additional buildpack was used.
```
pack inspect-image spring-sample-app
```{{execute}}