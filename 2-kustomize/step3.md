# Customize production deployment

Objective:
Explore additional customizations that can be done using Kustomize.

In this step, you will make further customizations to the production deployment:
1. Add prefix 'prod-' to all resource names
2. Add label 'env: prod' to all resources
3. Set memory properly
4. Configure health and readiness checks
5. Set an environment variable that is used by the app

##Add environment variable

We can now use an overlay to add an environment variable specifically in prod.
For this we need to create a Kustomize patch.

```
cd overlays/prod
cat <<EOF >patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-sample-app
spec:
  template:
    spec:
      containers:
        - name: go-sample-app
          env:
          - name: environment
            value: production
EOF
```{{execute}}

Let's register our patch in the `kustomization.yaml` file.

```
kustomize edit add patch patch.yaml

cat kustomization.yaml
```{{execute}}

We can now apply and test our new environment variable.

```
kustomize build --load_restrictor none . | kubectl apply -f -

kubectl rollout status deployment/go-sample-app -n prod
kubectl port-forward service/go-sample-app 8080:8080 -n prod 2>&1 > /dev/null &
```{{execute}}

Our endpoint should now respond with the environment variable.

```
curl localhost:8080
```{{execute}}

Stop the port-forwarding process:
```
pkill kubectl && wait $!
```{{execute}}

##Customize the name

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

##Label Customization

We want resources in production environment to have certain labels so that we can query them by label selector.

`kustomize` does not have `edit set label` command to add a label, but we can always edit `kustomization.yaml` directly:

```
cat <<EOF >>kustomization.yaml
commonLabels:
  env: prod
EOF
```{{execute}}

Verify whether all the resources now have the label tuple `env:prod`:

```
kustomize build --load_restrictor none . | grep -C 3 env
```{{execute}}

We can now apply the changes and verify the resources on the cluster.

```
kustomize build --load_restrictor none . | kubectl apply -f -

kubectl get all -n prod --show-labels
```{{execute}}

##Patch for memory limits

Create a new patch containing the memory limits setup.

```
cat <<EOF >memorylimit_patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-sample-app
spec:
  template:
    spec:
      containers:
        - name: go-sample-app
          resources:
            limits:
              memory: 256Mi
            requests:
              memory: 256Mi
EOF
```{{execute}}

##Patch for health check

We also want to add liveness check and readiness check in the production environment.
We can customize the Kubernetes deployment resource to talk to our endpoint.

Create a new patch containing the liveness probes and readiness probes.

```
cat <<EOF >healthcheck_patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-sample-app
spec:
  template:
    spec:
      containers:
        - name: go-sample-app
          livenessProbe:
            httpGet:
              path: /
              port: 8080
            initialDelaySeconds: 4
            periodSeconds: 3
          readinessProbe:
            initialDelaySeconds: 4
            periodSeconds: 10
            httpGet:
              path: /
              port: 8080
EOF
```{{execute}}

##Add patches

Add these patches to the kustomization:

```
kustomize edit add patch memorylimit_patch.yaml
kustomize edit add patch healthcheck_patch.yaml
```{{execute}}

`kustomization.yaml` should have patches field:

> ```
> patchesStrategicMerge:
> - patch.yaml
> - memorylimit_patch.yaml
> - healthcheck_patch.yaml
> ```

We can now apply all of these patches on our production environment.

```
kustomize build --load_restrictor none . | kubectl apply -f -

kubectl rollout status deployment/prod-go-sample-app -n prod
kubectl get all -n prod
```{{execute}}

Verify if our app still works.

```
kubectl port-forward service/prod-go-sample-app 8080:8080 -n prod 2>&1 > /dev/null &
```{{execute}}

Our endpoint should now respond with the environment variable.

```
curl localhost:8080
```{{execute}}

Stop the port-forwarding process:
```
pkill kubectl && wait $!
```{{execute}}
