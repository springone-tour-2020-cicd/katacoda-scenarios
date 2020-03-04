# Configure kpack

We're now ready to apply the yaml file to the kubernetes cluster:
```
kubectl apply -f ~/kpack-config/kpack-config.yaml
```{{execute}}

kpack will automatically detect the latest git commit in the source code repo defined in image.yaml. It will create an image for our app using the builder declared in build.yaml, and finally it will publish the image to Docker Hub using the service account we created.

# Is it working?

Each build creates a new pod. Check to see if a pod has been created:
```
kubectl get pods
```{{execute}}

The pod executes the buildpack lifecycle using an _init container_ for each lifecycle phase. The pod itself doesn't do anything additional. Hence, you cannot simply look at the logs of the pod directly. Instead, kpack provides a `logs` CLI to make it easy to get the logs from the various init containers in order: 
```
logs -image spring-sample-app -build 1
```{{execute}}

You should recognize the same buildpack lifecycle we observed with pack and Spring Boot in the kpack logs. 

When the log shows that the build is done, check your Docker Hub organization to make sure a new image has been published.

`Send Ctrl+C`{{execute interrupt T1}} to stop tailing the log.





