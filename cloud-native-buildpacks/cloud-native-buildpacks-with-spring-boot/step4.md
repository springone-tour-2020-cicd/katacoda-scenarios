# Extra credit

Try changing the version of the app in the pom.xml file and updating the code to return a different message. Rebuild the image to observe re-use of layering and caching.

You can change the source code using:
```
sed -i 's/hello/greetings/g' src/main/java/com/example/springsampleapp/HelloController.java
```{{execute}}

Verify the code change using `cat src/main/java/com/example/springsampleapp/HelloController.java`{{execute}}

You can change the app version using:
```
sed -i 's/<version>1.0.0<\/version>/<version>2.0.0<\/version>/' pom.xml
```{{execute}}

Verify the version change using `head -n 13 pom.xml`{{execute}}.

Re-build and test using the commands we used in the previous step. Be sure to run `docker images | grep spring-sample-app`{{execute}} to see the new image with the tag derived from the new version.

# Further reading

You can read the announcement of Spring Boot support for Cloud Native Buildpacks in this [blog post](https://spring.io/blog/2020/01/27/creating-docker-images-with-spring-boot-2-3-0-m1), and look through the docs for the [Maven](https://docs.spring.io/spring-boot/docs/2.3.0.M2/maven-plugin/html/#build-image) and [Gradle](https://docs.spring.io/spring-boot/docs/2.3.0.M2/gradle-plugin/reference/html/#build-image) plugins.