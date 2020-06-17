# Customize production deployment

Objective:
Explore additional customizations that can be done by editing `kustomization.yaml` directly.

In this step, you will:
1. Add label 'env: prod' to all resources

## Label Customization

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