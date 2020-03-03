# Additional digging and debugging

You can also use regular kubectl commands to describe kpack resources or check the kpack-controller log:

Get kpack resources:
```
kubectl get builders,builds,clusterbuilders,images,sourceresolvers
```{{execute}}

Get more detail about the builder:
```
kubectl describe clusterbuilder default
```{{execute}}

Get more detail about the image:
```
kubectl describe image spring-sample-app
```{{execute}}

Watch the kpack-controller logs:
```
kubectl logs -n kpack \
   $(kubectl get pod -n kpack | grep Running | head -n1 | awk '{print $1}') \
   -f
```{{execute}}

Read more about viewing kpack logs in this [blog post](https://starkandwayne.com/blog/kpack-viewing-build-logs).