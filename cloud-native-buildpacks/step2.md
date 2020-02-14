Some sample apps are provided in the `samples` directory. Let's begin building an image from one of the sample Java apps.

Go to the directory for the sample Java maven app
```
cd samples/apps/java-maven
```{{execute}}

Build the app using the `pack` CLI
```
pack build myapp
```{{execute}}

Validate that your image was built
```
docker images
```{{execute}}

Note that your app was built without needing to install a JDK, run Maven, or otherwise configure a build environment. pack and buildpacks took care of that for you.

Test out your app
```
docker run --rm -p 8080:8080 myapp
```{{execute}}

In a new terminal window, run
```
curl localhost:8080
```{{execute}}

Try building the image again
```
pack build myapp
```{{execute}}

Notice that the second time, the build was faster since it took advantage of various forms of caching.

In the next step, we will use pack for a non-Java app.
We will aslo use the --publish flag to publish the image to Docker Hub.

