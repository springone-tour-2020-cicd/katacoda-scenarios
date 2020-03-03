# Scenario environment

Your scenario environment comes with some pre-installed tools/assets. Let's review them.

Wait until `Environment ready!` appears in the terminal window.

We'll need an app to build. We're going to use a Maven app.

- To verify that the **sample app** was downloaded, run `ls spring-sample-app`{{execute}}.
You should see the the usual Maven app contents.

The app is a simple Spring Boot application that uses a version of Spring Boot that includes buildpack support (2.3.0.M1 or later). Validate the version of Spring Boot that is being used:
```
head ~/spring-sample-app/pom.xml
```{{execute}}

The image will be pushed to the local Docker registry.

- To verify that **Docker** is installed, run `docker --version`{{execute}}.
You should see the version of Docker displayed.



Now on to the real stuff!