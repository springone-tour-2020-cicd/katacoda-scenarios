# Where's my image?

By default, pack publishes images to the local Docker repository. Check your Docker daemon for the image that was just created:
```
docker images | grep spring-sample-app
```{{execute}}

Take note of the image id. We'll re-build the image shortly, and you can validate that the image id changes with each build.

You can start your app using `docker run`:
```
docker run -it -p 8080:8080 spring-sample-app
```{{execute}}

Send a request to the app:
```
curl localhost:8080; echo
```{{execute T2}}

Note that by using pack and buildpacks, there was no need to install a JDK, run Maven, or otherwise configure a build environment!

`Send Ctrl+C`{{execute interrupt T1}} to stop the app before proceeding to the next step.