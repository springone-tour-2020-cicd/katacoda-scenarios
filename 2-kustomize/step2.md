# Use overlays to transform resources

Objective:
Eliminate the duplication of configuration information.

In this step, you will:
1. Introduce Kustomize
2. Create a common base set of resources (deployment and service)
2. Customize dev and prod resources using overlays
3. Deploy dev and prod resources to Kubernetes

## Eliminate duplication

Kustomize enables you to specify this configuration declaratively without duplicated the common elements of our ops files. It does this in a Kubernetes-native way, allowing you to use Custom Resource Definitions (CRDs) to configure the differences, rather than variable-replacement.

First, get rid of the production yamls, which contain mostly duplicated configuration.

```
rm *-prod.yaml
```{{execute}}

You can use the dev yaml files as a shared "base" template that can be re-used for different environments. To that end, move them to a new `base` subdirectory:

```
mkdir base
mv *.yaml base
ls base
```{{execute}}

You can leave the namespace configuration of `dev` as a default, or you can remove the namespace configuration altogether. For clarity in this exercise, go ahead and remove the configuration:

```
sed -i '/namespace: dev/d' base/*.yaml 
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
cat kustomization.yaml
```{{execute}}

The kustomization.yaml file is in itself a Kubernetes resource file, with a declaration of the `apiVersion` and `kind`. You should also see a `resources` section listing the base Kubernetes API resource files, and a namespace node specifying the customization to apply to this overlay:
               
> ```
> apiVersion: kustomize.config.k8s.io/v1beta1
> kind: Kustomization
> resources:
> - ../../base/deployment.yaml
> - ../../base/service.yaml
> namespace: dev
> ```

Kustomize reads this `kustomization.yaml` file, as well as the Kubernetes API resource files in the `resources` list, applies the specified configuration overlays (in this case, it would add a namespace to each resource file), and emits the complete yaml to standard output. This yaml can be saved to a file or passed to another tool or command, such as `kubectl apply`.

To see the yaml generated for the dev environment, run:

```
kustomize build --load_restrictor none .
```{{execute}}

To apply this generated yaml to your cluster, create the dev namespace and pipe the output of the kustomize command to `kubectl apply`:

```
kubectl create ns dev
kustomize build --load_restrictor none . | kubectl apply -f -
```{{execute}}

Check the deployment in Kubernetes:

```
kubectl get all -n dev
```{{execute}}

Create the overlay for prod and apply the generated resources to Kubernetes:

```
cd ..
mkdir prod
cd prod
touch kustomization.yaml
kustomize edit add base ../../base/deployment.yaml
kustomize edit add base ../../base/service.yaml
kustomize edit set namespace prod
kubectl create ns prod
kustomize build --load_restrictor none . | kubectl apply -f -
```{{execute}}

Check the deployment in Kubernetes:

```
kubectl get all -n prod
```{{execute}}

Go back to the ops directory and view the entire ops directory structure:

```
cd ../..
tree
```{{execute}}

The directory structure should look like this:

> ```
> .
> ├── base
> │   ├── deployment.yaml
> │   └── service.yaml
> └── overlays
>     ├── dev
>     │   └── kustomization.yaml
>     └── prod
>         └── kustomization.yaml
> ```

In the next step, you will further customize your production configuration.