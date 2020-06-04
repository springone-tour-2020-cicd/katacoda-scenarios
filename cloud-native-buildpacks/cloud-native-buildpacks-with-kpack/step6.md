# Configure kpack

We're now ready to apply the yaml file to the kubernetes cluster:
```
kubectl apply -f ~/kpack-config/kpack-config.yaml
```{{execute}}

# Is it working?

kpack will create a Build resource for every commit it detects. For now, you should see a Build resource for the latest commit:
```
kubectl get builds
```

Edit the name of the build in the following command to see the details:
```
kubectl describe build spring-sample-app-1-<uuid>
```{{copy}}

The `Revision` field will contain the corresponding git commit id.

The build is executed in a pod. Each build creates a new pod.
```
kubectl get pods
```{{execute}}

Each phase of the buildpack lifecycle is executed in a separate _init container_, so getting the logs directly from the pod involves appending the pods from each init container in the right order. To facilitate this, kpack includes a special `logs` CLI that makes it easy to get the build log:
```
logs -image spring-sample-app -build 1
```{{execute}}

The logs should look very similar to those we saw in the previous scenario scenarios on pack and Spring Boot. 

When the log shows that the build is done, check your Docker Hub organization to make sure a new image has been published.

`Send Ctrl+C`{{execute interrupt T1}} to stop tailing the log.