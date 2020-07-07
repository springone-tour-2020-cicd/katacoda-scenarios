In this step we will show how to use kustomize to setup support for multiple Kubernetes environments, e.g dev, staging and production.  We will create use the default namespace as the `dev` environment and create a new namespace `production` for the production environment.

*Prerequisite:** Complete the tutorial [_Intro Workflow and Prerequisites_](https://www.katacoda.com/springone-tour-2020-cicd/courses/cicd-for-k8s/1-intro-workflow)


Let's begin by changing into the home directory.

```
cd ~
```{{execute}}
<br>

Now clone your fork of the (https://github.com/springone-tour-2020-cicd/spring-sample-app-ops) repository.


```
git clone https://github.com/<GITHUB_NS>/spring-sample-app-ops
```{{execute}}
<br>

And cd into the directory

```
cd spring-sample-apps-ops
```{{execute}}

The directory now contains a `base` subdirectory and two `overlay` subdirectories, one for development and one for production.

```
$ tree
.
├── base
│   └── kustomization.yaml
└── overlays
    ├── dev
    │   ├── env.properties
    │   └── kustomization.yaml
    └── production
        ├── env.properties
        └── kustomization.yaml
```

## Look at the directory structure 

Open the file `/workspace/spring-sample-app-ops/overlay/dev/kustomization.yaml`

In that file refer to your container image and its version.

<br>
```
images:
  - name: markpollack/spring-sample-app  # used for Kustomize matching
    newName: <YOUR-DOCKERHUB-USERNAME>/spring-sample-app
    newTag: 1.0.0
```

Looking at this file there is a reference to the base kustomization directory to pull in the kustomization resource defined there.

```
resources:
  - ../../base
```
 
The file `/workspace/spring-sample-app-ops/base/kustomization.yaml`{{open}} contains a reference to the off-the-shelf customization hosted on GitHub.

```
resources:
  - github.com/kustomizations/spring-boot-web?ref=1.0.0
```


## Deploy to the development environment

Execute

```
kustomize build ./overlays/dev | kubectl apply -f -
```

You can see the resources created by executing

```
watch kubectl get all
```{{execute}}

Once the `STATUS` of the pod is `Running` state, Press `# Ctrl+C`{{execute interrupt T1}} to exit out of the watch.

Then look at the output from hitting the endpoint by using `curl` to access the `http` URL for your application's service that is returned from executing the command:

```
minikube service list
```{{execute}}

`curl`ing the endpoint, you will see the following profile in the response.

```
profile='dev'
```


## Deploy to the production environment

Now let's create a new namespace `production`

```
kubectl create ns production
```{{execute}}

Verify it has been created

```
kubectl get namespaces
```{{execute}}

Execute

```
kustomize build ./overlays/production | kubectl apply -n production -f -
```

You can see the resources created by executing

```
watch kubectl get all -n production
```{{execute}}

Once the `STATUS` of the pod is `Running` state, Press `# Ctrl+C`{{execute interrupt T1}} to exit out of the watch.

Then look at the output from hitting the endpoint by using `curl` to access the `http` URL for your application's service that is returned from executing the command:

```
minikube service list
```{{execute}}

`curl`ing the endpoint, you will see the following profile in the response.

```
profile='production'
```

