# Prepare environment

Objective:

Prepare your local environment.

In this step, you will:
- Validate that the environment is initialized
- Configure setup for using GitHub and Docker Hub in the scenario
- Clone your GitHub repo (or the reference sample repo if you skipped the previous scenario)
- Create `dev` and `prod` namespaces in the Kubernetes cluster to represent deployment environments
- Install Tekton
- Install kpack
- Provide access to Docker Hub from Kubernetes for Tekton and kpack

## Validate environment initialization

Please wait until `Environment ready!` appears in the terminal window.

## Set up access to GitHub and Docker Hub

You will use your GitHub account to create/update repos, and you will use your Docker Hub account to push images.

Run the following script and provide your account details at the prompts. It is better practice to use an access token than a password. For more information, see [GitHub access tokens](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) (select "repo" access rights) and [Docker Hub access tokens](https://docs.docker.com/docker-hub/access-tokens).

```
source set-credentials.sh
```{{execute}}

As a convenience, your GitHub and Docker Hub namespaces (org names) are now stored in env vars `$GITHUB_NS` and `$IMG_NS`, respectively. These variables will be used througout the scenario.

## Clone repo

If you completed the previous scenario and have an existing fork of the [sample app repo](https://github.com/springone-tour-2020-cicd/go-sample-app.git), clone your fork.

```
git clone https://github.com/$GITHUB_NS/go-sample-app.git
git clone https://github.com/$GITHUB_NS/go-sample-app-ops.git
```{{execute}}

**ALTERNATIVELY:** you can fork "shortcut" repos that will allow you to start without completing the previous scenarios. To do this, run the following commands instead.

Fork the "shortcut" app repo:
```
source fork-repos.sh go-sample-app scenario-6-finished
```{{execute}}

Fork the "shortcut" ops repo:
```
source fork-repos.sh go-sample-app-ops scenario-6-finished
```{{execute}}

## Create namespaces

To simulate the dev an prod environments into which we will be deploying the sample app, create dev and prod namepsaces.

```
kubectl create ns dev
kubectl create ns prod
```{{execute}}

## Install Tekton

Install Tekton (pipelines and triggers) and Tekton catalog tasks

```
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.13.2/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/git/git-clone.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/golang/lint.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/golang/tests.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/kaniko/kaniko.yaml
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/v1beta1/buildpacks/buildpacks-v3.yaml
```{{execute}}

## Install kpack

Install kpack to the kubernetes cluster.

```
kubectl apply -f https://github.com/pivotal/kpack/releases/download/v0.0.9/release-0.0.9.yaml
```{{execute}}

## Configure access to Docker Hub from Kubernetes

Create a Secret in Kubernets so that Tekton and kpack can publish images to Docker Hub.

```
kubectl create secret generic regcred  --from-file=.dockerconfigjson=/root/.docker/config.json --type=kubernetes.io/dockerconfigjson
```{{execute}}
