# Prepare environment

Objective:
In this step you will review the problem of duplicated ops files.

In this step, you will:
- Clone your app repo
- Validate the duplication in the ops files

## Local environment setup
Please wait until `Environment ready!` appears in the terminal window.

## Clone repo
Start by cloning the GitHub repo you created in the prerequisite scenario.  For convenience, set the following environment variable to your GitHub namespace (your user or org name). You can copy and paste the following command into the terminal window, then delete the placeholder and replace it with your namespace:
                                                                           
```
GH_NS=<YOUR_GH_NAMESPACE>
```{{copy}}

Next, clone your fork of the sample app repo:
```
git clone https://github.com/$GH_NS/go-sample-app.git
```{{execute}}

In the prerequisite scenario, you created two sets of ops files corresponding to two deployment environments, dev and prod, and you used `yq` to change the value of the metadata.namespace nodes for prod.

Use the following command to confirm that the files are identical save for the name of the namespace.

```
cd go-sample-app/ops
diff deployment.yaml deployment-prod.yaml
diff service.yaml service-prod.yaml
```{{execute}}

Using `yq` to change a single node for one set of yaml files is fairly straightforward. However, this approach can become complex and difficult to manage as you introduce more environments, and more differences between environments. In addition, using `yq` means you are making imperative changes, which breaks the declarative quality of the initial configuration.

This means we should look beyond search-and-replace tools like `sed` or `yq`. 

In the following steps, you will learn how to use Kustomize to better solve this challenge.