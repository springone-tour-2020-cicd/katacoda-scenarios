# Run the jib-maven task

In this step we will create a `TaskRun` that creates a container image of a Spring Boot application and publish it to Docker Hub.

Open the file `/root/tekton-labs/lab-2/jib-maven-taskrun.yaml`{{open}} and take a look around.

**NOTE:  ** You may need to select the filename in the editor tree window to have the contents appear in the editor.

There are two values in the YAML document that need to be changed.

The task run defines the `git` resource and `image` resource as embedded resources to the `TaskRun`.

The git resource is defined in the input section

```
inputs:
  resources:
    - name: source
      resourceSpec:
        type: git
        params:
          - name: url
            value: # REPLACE https://github.com/markpollack/spring-sample-app
          - name: revision
            value: master
```
**The `url` parameter value should be set to the URL of your forked repository of the sample application**

The image resource is defined in the output section

```
outputs:
  resources:
    - name: image
      resourceSpec:
        type: image
        params:
          - name: url
            value: # REPLACE markpollack/spring-sample-app:1.0.0
```

**The `url` parameter value should be set to the Docker Hub repository name.  The version `1.0.0` should match what you have in the `pom.xml` file in your github repository of the sample application.**

After changing the two `url` values, execute the taskrun

```
kubectl apply -f jib-maven-taskrun.yaml
```{{execute}}


Now let's get a description of the `TaskRun` that was created.

```
tkn taskrun describe jib-maven-taskrun
```{{execute}}


To view the logs

```
tkn taskrun logs --follow jib-maven-taskrun
```{{execute}}


After a bit of time to download the images that the task will use has completed, you will see many log entries for the downloading of maven artifacts.

At the end of the log, you will see a successful push of the image to Docker Hub as shown below.


```
[build-and-push] [INFO] Built and pushed image as markpollack/spring-sample-app:1.0.0
[build-and-push] [INFO] 
[build-and-push] [INFO] ------------------------------------------------------------------------
[build-and-push] [INFO] BUILD SUCCESS
[build-and-push] [INFO] ------------------------------------------------------------------------
[build-and-push] [INFO] Total time:  5.269 s
[build-and-push] [INFO] Finished at: 2020-02-15T23:05:09Z
[build-and-push] [INFO] ------------------------------------------------------------------------
```

If you navigate to your account on [Docker Hub](https://hub.docker.com/), you will see your published image.

Now, instead of running a once off task, let's create a pipeline that is more typical in a CI scenario of multiple steps.  On to the next step!




