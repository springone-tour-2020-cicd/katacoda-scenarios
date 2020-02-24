In this step we will create a container image of a Spring Boot application and publish it to Docker Hub.

Open the file `/root/tekton-labs/lab-2/jib-maven-taskrun.yaml`{{open}} and take a look around.

**NOTE:  ** You may need to select the filename in the editor tree window to have the contents appear in the editor.

There are two values in the YAML document that need to be changed.
The task run defines the git resource and image resource as embedded resources to the TaskRun.
The git resource is defined in the input section

```
inputs:
  resources:
    - name: source
      resourceSpec:
        type: git
        params:
          - name: url
            value: # REPLACE WITH YOUR FORKED REPO URL https://github.com/markpollack/spring-sample-app
          - name: revision
            value: master
```
**The `url` parameter value should be set to your forked repository of the sample application**

The image resource is defined in the output section

```
outputs:
  resources:
    - name: image
      resourceSpec:
        type: image
        params:
          - name: url
            value: # REPLACE WITH YOUR DOCKER HUB URL markpollack/spring-sample-app:1.0.0
```

**The `url` parameter value should be set to the Docker Hub repository name.  The version `1.0.0` should match what you have in the `pom.xml` file of the sample application.**

After changing the two `url` values, execute the taskrun

```
kubectl apply -f jib-maven-taskrun.yaml
```{{execute}}
<br>

Now let's get a description of the `TaskRun` that was created.

```
tkn taskrun describe jib-maven-taskrun
```{{execute}}
<br>

To view the logs

```
tkn taskrun logs jib-maven-taskrun
```{{execute}}
<br>

You should see many log entries for the downloading of maven artifacts and at the end, a successful push of the image to Docker Hub as shown below.


```
logs go here
```




