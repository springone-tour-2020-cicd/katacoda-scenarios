# Extra credit

Objective:
...

In this step, you will:
- ...

## Additional digging and debugging

You can also use regular kubectl commands to describe kpack resources or check the kpack-controller log:

Get kpack resources:
```
kubectl get builders,builds,clusterbuilders,images,sourceresolvers --all-namespaces
```{{execute}}

Get more detail about the builder, including the run image, the list of frameworks supported (Java, Nodejs, Go, .NET Core) and the buildpacks that contribute to the builds:
```
kubectl describe builder default
```{{execute}}

Get more detail about the image:
```
kubectl describe image go-sample-app
```{{execute}}

Watch the kpack-controller logs:
```
kubectl -n kpack logs -l app=kpack-controller -f
```{{execute}}

`Send Ctrl+C`{{execute interrupt T1}} to stop tailing the log.

Read more about viewing kpack logs in this [blog post](https://starkandwayne.com/blog/kpack-viewing-build-logs).

# Extra credit

If you want to see kpack automatically creating new builds when a code change occurs, you can:

1. Fork the [spring-sample-app repo](https://github.com/springone-tour-2020-cicd/spring-sample-app.git)
2. Update spec.source in in the yaml config file to point to your fork. You will need to use `spec.source.git.url` and `spec.source.git.revision` instead of `spec.source.blob.url` to point to source code. You can set revision to master
3. Use `kubectl apply` as we did previously to update the Image
4. Make changes to any files in your repo fork
5. Check kpack logs for `build 2`, `build-3`, etc
6. Check DockerHub to confirm a new images are published

## Enable caching

kpack requires the default persistent volume (PV) to be configured in the Kuberrnetes cluster in order to cache layers between builds. Our scenario environment does not have a PV. To see caching and re-use in action in kpack:

1. Try this exercise, including the extra credit above, on a cluster with a default PV
2. Before creating the image, uncomment the "cacheSize" setting in the image yaml configuration file. This will enable caching between builds