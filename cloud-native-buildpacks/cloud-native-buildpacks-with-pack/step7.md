# Inspect & customize the image

`pack` provides a way to inspect our app image:
```
pack inspect-image spring-sample-app
```{{execute}}

You can see the run image and the buildpacks used to create the app image. What if you want to influence the build by adding a few instructions? One option is to add a custom buildpack.

### Add a custom buildpack

Since buildpacks are modular and pluggable, we can contribute our own custom buildpacks to the build. You can read more about creating custom buildpacks [here](https://github.com/buildpacks/samples/tree/master/buildpacks) later, but for now, let's use a simple example custom buildpack. This buildpack just prints some lines to the log during the build, but you could create a custom buildpack that does anything that makes sense for your organization or your application.

To run the sample buildpack, you could list each buildpack that you see in the output of the `inspect-image` command in your `pack build` command, in order, and include your custom buildpack in the list. Alternatively, you can use the shorthand `from=builder`, as shown below, to cause the custom buildpack to run before or after the buildpacks from the builder. 

Re-run the `pack build` command as shown below to run the custom buildpack after the builder buildpacks have run:
```
pack build spring-sample-app \
     --buildpack from=builder \
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