# Second build

Let's dive further into the `pack build` command by re-building the image and examining the log again.

Before we re-build, let's make a small code change.

### App source code change

Recall that the app displayed the message _"hello, world"_. Let's change that for our next build.

Run the following commands to cd into the app directory and update the source code:
```
cd ~/spring-sample-app
sed -i 's/hello/greetings/g' src/main/java/com/example/springsampleapp/HelloController.java
```{{execute}}

You can verify that the file contains the updated string using `cat src/main/java/com/example/springsampleapp/HelloController.java`{{execute}}

### Re-build the image

Now, let's re-build the image. We no longer need to specify the builder since we have set a default builder. We also no longer need to specify the path since we are now in the directory containing the source code. Hence, we can run a simplified `pack build` command with only the image name:
```
pack build spring-sample-app
```{{execute}}

### Speedy re-build

Notice that the build is faster the second time. A few factors contribute to this:

1. The builder and run (stack) images are now available in the local Docker repository

2. Spring/Java dependencies are now available in a local Maven (.m2) repository

3. Even though we made a change to our app code, the build was able to re-use layers from the app image and from cache (pay special attention to the logs for the `restoring`, `analyzing`, and `exporting` phases). Building a layered image enables pack to efficiently recreate only the layers that have changed.

Validate that the image was updated (the image id has changed):
```
docker images | grep spring-sample-app
```{{execute}}

Re-run the app to see the updated message:
```
docker run -it -p 8080:8080 spring-sample-app
```{{execute}}

Send a request to the app:
```
curl localhost:8080; echo
```{{execute T2}}

`Send Ctrl+C`{{execute interrupt T1}} to stop the app before proceeding to the next step.
