# Configure kpack

Apply the yaml file to the kubernetes cluster:
```
kubectl apply -f ~/kpack-config/kpack-config.yaml
```{{execute}}

Ensure kpack has processed the builder and image:
```
kubectl get builders,builds,clusterbuilders,images,sourceresolvers
```{{execute}}

You can also use `kubectl describe` to get more detail:
```
kubectl describe clusterbuilder default
```{{execute}}

and

```
kubectl describe image spring-sample-app
```{{execute}}