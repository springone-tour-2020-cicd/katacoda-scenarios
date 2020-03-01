# First build, take two

Let's re-visit our `pack build` command.

### The builder

Our `pack build` command explicitly declared a _builder_ to use: `--builder cloudfoundry/cnb:0.0.53-bionic`

##### What's a builder, anyway?

A builder is an image that bundles all the bits and information on how to build your apps. It includes the buildpacks that will be used as well as the environment for building and running your app. The builder we specified is publicly available on Docker Hub [cloudfoundry/cnb](https://hub.docker.com/r/cloudfoundry/cnb) (click on the `Tags` tab to see available builder images).

We can use `pack` to get more information about the builder:
```
pack inspect-builder cloudfoundry/cnb:0.0.53-bionic
```{{execute}}

From the output, you can see that this builder supports several programming frameworks through ordered sets of modular buildpacks, and it specifies the order of detection that will be applied to applications. You can also see the stack and the run image that the builder will use for the app image it produces.

Now, check your local Docker repository for any images downloaded from the cloudfoundry org on Docker Hub.
```
docker images | grep cloudfoundry
```{{execute}}

You should see both the builder image as well as the run image. `pack` downloaded both of these during the first build. We can expect future builds with the same builder to be faster as they can use the local copies.

##### What other builders could I have used?

If you're curious about other builders you can use, run:
```
pack suggest-builders
```{{execute}}

##### Default builder
 
Let's stick with the builder we'd chosen. In fact, to simplify our pack command, let's set it as our default:
```
pack set-default-builder cloudfoundry/cnb:0.0.53-bionic
```{{execute}}
