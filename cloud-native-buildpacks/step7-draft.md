# DRAFT DRAFT DRAFT DRAFT: More pack goodies

# Environment variables -- build time env var examples ??

Run `pack build --help`{{execute}} to see some additional options we can add to the `pack build` command.

```
pack build spring-sample-app \
    --buildpack io.buildpacks.samples.java-maven \
    --buildpack ~/samples/buildpacks/hello-world \
    --env "HELLO=WORLD"
```{{execute}}

Note that if you don't set the value of the environment variable explicitly in the `pack build` command, the value will be inherited from the current environment. Note also the alternative option, `--env-file`, that enables loading environment variables from a file.

Re-run the app and notice that the banner is not displayed:
```
docker run --env "LOGGING_LEVEL_ORG_SPRINGFRAMEWORK=DEBUG" -it -p 8080:8080 spring-sample-app
```{{execute}}

```
docker run --env "SPRING_MAIN_BANNER-MODE=off" -it -p 8080:8080 spring-sample-app
```{{execute}}

```
docker run --env "SERVER_PORT=8081" -it -p 8080:8080 spring-sample-app
```{{execute}}

`Send Ctrl+C`{{execute interrupt}} to stop the app before proceeding to the next step.

---

In the next step, we will use pack for a non-Java app. from source for apps written in variety of frameworks.

# Publish the image

Run `pack build --help`{{execute}} to see some additional options we can add to the `pack build` command.

Let's use the `--publish` option to publish the image to Docker Hub rather than the local Docker repository.

https://buildpacks.io/docs/concepts/operations/rebase/

rebase publish ??



# DRAFT DRAFT DRAFT DRAFT: More pack goodies

# Environment variables -- build time env var examples ??

Run `pack build --help`{{execute}} to see some additional options we can add to the `pack build` command.

```
pack build spring-sample-app \
    --buildpack io.buildpacks.samples.java-maven \
    --buildpack ~/samples/buildpacks/hello-world \
    --env "HELLO=WORLD"
```{{execute}}

Note that if you don't set the value of the environment variable explicitly in the `pack build` command, the value will be inherited from the current environment. Note also the alternative option, `--env-file`, that enables loading environment variables from a file.

Re-run the app and notice that the banner is not displayed:
```
docker run --env "LOGGING_LEVEL_ORG_SPRINGFRAMEWORK=DEBUG" -it -p 8080:8080 spring-sample-app
```{{execute}}

```
docker run --env "SPRING_MAIN_BANNER-MODE=off" -it -p 8080:8080 spring-sample-app
```{{execute}}

```
docker run --env "SERVER_PORT=8081" -it -p 8080:8080 spring-sample-app
```{{execute}}

`Send Ctrl+C`{{execute interrupt}} to stop the app before proceeding to the next step.

# Publish the image

Let's use the `--publish` option to publish the image to Docker Hub rather than the local Docker repository.

# pack rebase and rebase publish

https://buildpacks.io/docs/concepts/operations/rebase/

rebase publish ??

# pack for non-Java apps




