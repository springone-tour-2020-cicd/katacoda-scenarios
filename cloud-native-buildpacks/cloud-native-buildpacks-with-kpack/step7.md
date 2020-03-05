# Additional digging and debugging

You can also use regular kubectl commands to describe kpack resources or check the kpack-controller log:

Get kpack resources:
```
kubectl get builders,builds,clusterbuilders,images,sourceresolvers --all-namespaces
```{{execute}}

Get more detail about the builder, including the run image, the list of frameworks supported (Java, Nodejs, Go, DotNet Core) and the buildpacks that contribute to the builds:
```
kubectl describe clusterbuilder default
```{{execute}}

Get more detail about the image:
```
kubectl describe image spring-sample-app
```{{execute}}

Watch the kpack-controller logs:
```
kubectl -n kpack logs -l app=kpack-controller -f
```{{execute}}

`Send Ctrl+C`{{execute interrupt T1}} to stop tailing the log.

Read more about viewing kpack logs in this [blog post](https://starkandwayne.com/blog/kpack-viewing-build-logs).