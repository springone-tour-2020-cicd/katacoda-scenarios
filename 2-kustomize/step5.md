# Customize production deployment

Objective:
Explore additional customizations that can be done using Kustomize.

In this step, you will make further customizations to the production deployment:
1. Add prefix 'prod-' to all resource names
2. Add label 'env: prod' to all resources
3. Set memory properly
4. Configure health and readiness checks
5. Set an environment variable that is used by the app

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

