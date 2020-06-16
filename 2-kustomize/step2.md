# Use overlays to transform resources

Let's say that in the production environment, you want to customize the following:

- Namespace of 'prod'
- Add prefix 'prod-' to all resource names
- Add label 'env: prod' to all resources
- Set memory properly
- Configure health and readiness checks
- Set an environment variable that is used by the app

Kustomize enables you to specify this configuration declaratively without duplicated the common elements of our ops files. It does this in a Kubernetes-native way, allowing you to use Custom Resource Definitions (CRDs) to configure the differences, rather than variable-replacement.

In this step, you will:
1. Introduce Kustomize
2. Customize resources using overlays
3. Deploy everything to Kubernetes

## Eliminate duplication

First, get rid of the production yamls, which contain mostly duplicated configuration.

```
rm *-prod.yaml
```{{execute}}

You can use the dev yaml files as a shared "base" template that can be re-used for different environments. To that end, move them to a new subdirectory called `base`:

```
mkdir base
mv *.yaml base
ls base
```{{execute}}

You can leave the namespace configuration of `dev` as a default, or you can remove the metadata.namespace node altogether. For clarity in this exercise, go ahead and remove the node:

```
yq d base/*.yaml "metadata.namespace" 
```{{execute}}

Kustomize provides a declarative approach to re-using and customizing configuration. It gets its instructions about which Kubernetes API resource files to re-use and what customizations to "overlay" from a file called `kustomization.yaml`.

Create an overlay subdirectory for each environment and create a `kustomization.yaml` file in each. Use the `kustomize` CLI to easily edit the `kustomization.yaml` to specify which base files to re-use, and which environment-specific namespace to overlay.

Start with the dev environment:

```
mkdir -p overlays/dev
cd overlays/dev
touch kustomization.yaml
kustomize edit add base ../../base/deployment.yaml
kustomize edit add base ../../base/service.yaml
kustomize edit set namespace dev
```{{execute}}

Review the dev `kustomization.yaml` file:

```
ls kustomize.yaml
```{{execute}}

You should see a resources section listing the base resource files: [TO DO UPDATE THIS WITH REAL FILE CONTENTS]
               
> ```
> resources:
> - ../../base/service.yaml
> - ../../base/deployment.yaml
> ```

Kustomize reads this `kustomization.yaml` file, as well as the Kubernetes API resource files in the `resources` list, applies the specified configuration overlays (in this case, it would add a namespace to each resource file), and emits the complete yaml to standard output. This yaml can be saved to a file or passed to another tool or command, such as `kubectl apply`.

To see the yaml generated for the dev environment, run:

```
kustomize build --load_restrictor none overlays/dev
```{{execute}}

To apply this yaml to your cluster, create the dev namespace, and then either pipe the output of the kustomize command to kubectl, or use the built-in support for kustomize. We'll use the first approach for dev, and the second approach for prod, so you can see the syntax of each. Both have the same effect, which is to apply the resource configurations to Kubernetes (aka deploy the app).

```
kubectl create ns dev
kustomize build --load_restrictor none overlays/dev | kubectl apply -f -
```{{execute}}

Check the deployment in Kubernetes:

```
kubectl get all -n dev
```{{execute}}

Create the kustomize overlay for prod and apply the generated resources to Kubernetes. Notice the syntax of the last line in the following block, which uses the built-in support for kustomize in the kubectl CLI:

```
cd ..
mkdir pro
cd prod
touch kustomization.yaml
kustomize edit add base ../../base/deployment.yaml
kustomize edit add base ../../base/service.yaml
kustomize edit set namespace prod
kubectl create ns dev
kubectl apply -k .
```{{execute}}

Check the deployment in Kubernetes:

```
kubectl get all -n prod
```{{execute}}

Go back to the ops subdirectory and view the entire ops directory structure:

```
cd ../..
tree .
```{{execute}}

The directory structure should look like this:

```
.
├── base
│   ├── deployment.yaml
│   └── service.yaml
└── overlays
    ├── dev
    │   └── kustomization.yaml
    └── prod
        └── kustomization.yaml
```

In the next step, you will further customize your production configuration.