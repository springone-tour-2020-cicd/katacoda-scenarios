# Prepare environment

Objective:
Prepare your local environment.

In this step, you will:
- Prepare your local environment

## Local environment setup
Please wait until `Environment ready!` appears in the terminal window.

Your Docker Hub namespace (user or org name) will be needed in this scenario. For convenience, copy and paste the following environment variable to the terminal window, then append your Docker Hub namespace:

```
# Fill this in with your Docker Hub username or org
IMG_NS=
```{{copy}}

Your GitHub namespace (user or org name) will be needed in this scenario. For convenience, copy and paste the following environment variable to the terminal window, then append your GitHub namespace:

```
# Fill this in with your GitHub username or org
GITHUB_NS=
```{{copy}}

## Clone repo

Start by cloning the GitHub repo you created in the [intro](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/1-intro-workflow) scenario.

```
git clone https://github.com/$GITHUB_NS/go-sample-app.git && cd go-sample-app
```{{execute}}

## Create namespaces

To simulate the dev an prod environments into which we will be deploying the app, create dev and prod namepsaces.

```
kubectl create ns dev
kubectl create ns prod
```{{execute}}

