# Customize production deployment

Objective:
Explore additional customizations that can be done using Kustomize patches.

In this step, you will:
1. Set an environment variable that is used by the app
2. Set memory properly
3. Configure health and readiness checks

## Add environment variable

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

kubectl rollout status deployment/prod-go-sample-app -n prod
```{{execute}}

The container should now have printed the environment variable.

```
kubectl logs $(kubectl get pods -n prod -o jsonpath="{.items[0].metadata.name}") -n prod
```{{execute}}

## Patch for memory limits

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

## Patch for health check

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

## Add patches

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

Go ahead and port-forward the production `Service`.

```
kubectl port-forward service/prod-go-sample-app 8080:8080 -n prod 2>&1 > /dev/null &
```{{execute}}

Verify if our app still works.

```
curl localhost:8080
```{{execute}}

Stop the port-forwarding process:
```
pkill kubectl && wait $!
```{{execute}}
