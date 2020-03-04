# Where's my image?

By default, pack publishes images to the local Docker repository. Check your Docker daemon for the image that was just created:
```
docker images | grep spring-sample-app
```{{execute}}

Don't worry if the creation date says "40 years ago". `pack` zeroes out all the timestamps in the built images in order to achieve reproducible builds (if you run the same version of the buildpacks against the same source code, you will get images with identical shas). Instead, take note of the image id. We'll re-build the image shortly, and you can validate that the image id changes with each build.

Note that by using pack and buildpacks, there was no need to install a JDK, run Maven, or otherwise configure a build environment in order to build the OCI image for the app!

For kicks, let's make sure the app works. Start the app using `docker run`:
```
docker run -it -p 8080:8080 spring-sample-app
```{{execute}}

When the app log indicates the app has started, send a request to the app. Clicking on the following command will send the request in a new terminal window:
```
curl localhost:8080; echo
```{{execute T2}}

You should see a _"hello, world"_ response from the app, with some additional app details.

`Send Ctrl+C`{{execute interrupt T1}} to stop the app before proceeding to the next step.