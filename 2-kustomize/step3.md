# Customize production deployment

Objective:
Explore additional customizations that can be done using `kustomize edit`.

In this step, you will:
1. Add prefix 'prod-' to all production resource names

## Customize resource names

Arrange for the resources to begin with prefix _prod-_ (so we never alter or delete resources in the _production_ environment by mistake):

```
kustomize edit set nameprefix 'prod-'
```{{execute}}

`kustomization.yaml` should have updated value of namePrefix field:

> ```
> namePrefix: prod-
> ```

This `namePrefix` directive adds _prod-_ to all resource names, as can be seen by building the resources:

```
kustomize build --load_restrictor none . | grep prod-
```{{execute}}

Let's apply and verify.
Confirm that the resources now all have names prefixed by `prod-`

```
kustomize build --load_restrictor none . | kubectl apply -f -

kubectl rollout status deployment/prod-go-sample-app -n prod
kubectl get all -n prod
```{{execute}}

We can now get rid of the old service and deployment on production.

```
kubectl delete deployment go-sample-app -n prod
kubectl delete service go-sample-app -n prod
```{{execute}}
