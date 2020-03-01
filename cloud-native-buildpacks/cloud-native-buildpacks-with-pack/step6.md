# First build, take two

Let's continue our deep-dive into the `pack build` command.

### Local path

We can also omit the `--path` parameter if we execute `pack build` from the directory that contains the source code. Let's mosey on over there:
```
cd ~/spring-sample-app
```{{execute}}

### Re-build the image

Before we continue, let's make a minor change to the code. Recall that the app displayed the message _"hello world"_. Let's change that for our next build.
```
sed -i 's/hello world/Greetings Earth/g' src/main/java/com/example/springsampleapp/HelloController.java
```{{execute}}

You can verify that the file contains the updated string using `tail src/main/java/com/example/springsampleapp/HelloController.java`{{execute}}

Now, let's re-build the image using our simplified `pack build` command:
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
curl localhost:8080
```{{execute T2}}

`Send Ctrl+C`{{execute interrupt T1}} to stop the app before proceeding to the next step.
