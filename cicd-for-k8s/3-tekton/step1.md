# Prepare environment

Objective:

Prepare your local environment.

In this step, you will:
- Validate that the environment is initialized
- Set up access to GitHub and Docker Hub
- Clone sample repo
- Create Kubernetes namespaces

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
```{{execute}}

**ALTERNATIVELY:** you can fork a "shortcut" repo that will allow you to start without completing the previous scenarios. To do this, run the following commands instead.

```
source fork-repos.sh go-sample-app scenario-2-finished
```{{execute}}

## Create namespaces

To simulate the dev and prod environments into which you will be deploying the sample app, create dev and prod namepsaces.

```
kubectl create ns dev
kubectl create ns prod
```{{execute}}
