# Further reading

You can read the announcement of Spring Boot support for Cloud Native Buildpacks in this [blog post](https://spring.io/blog/2020/01/27/creating-docker-images-with-spring-boot-2-3-0-m1), and look through the docs for the [Maven](https://docs.spring.io/spring-boot/docs/2.3.0.M2/maven-plugin/html/#build-image) and [Gradle](https://docs.spring.io/spring-boot/docs/2.3.0.M2/gradle-plugin/reference/html/#build-image) plugins.

# Second build

Let's re-build the image to see the efficiencies we observed with `pack` in play again here.

Before we re-build, let's make a small code change.

### App source code change

Recall that the app displayed the message _"hello, world"_. Let's change that for our next build.

Run the following commands to cd into the app directory and update the source code:
```
cd ~/spring-sample-app
sed -i 's/hello/greetings/g' src/main/java/com/example/springsampleapp/HelloController.java
```{{execute}}

You can verify that the file contains the updated string using `cat src/main/java/com/example/springsampleapp/HelloController.java`{{execute}}

### App version change

Let's also change the app version. This will result in a different tag for our app image.
```
sed -i 's/<version>1.0.0<\/version>/<version>2.0.0<\/version>/' pom.xml
```{{execute}}

You can verify that the file contains the updated string using `head -n 13 pom.xml`{{execute}}
