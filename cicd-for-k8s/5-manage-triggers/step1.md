# Prepare environment

Objective:


Prepare your local environment.

In this step, you will:
- Validate that the environment is initialized
- Configure setup for using GitHub and Docker Hub in the scenario
- Create `dev` and `prod` namespaces in the Kubernetes cluster to represent deployment environments
- Clone your GitHub repo (or the reference sample repo if you skipped the previous scenario)

## Validate environment initialization

Please wait until `Environment ready!` appears in the terminal window.

## Set up access to GitHub and Docker Hub

You will use your GitHub account to create/update repos, and you will use your Docker Hub account to push images.

Run the following script and provide your account details at the prompts. It is better practice to use an access token than a password. For more information, see [GitHub access tokens](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) (select "repo" access rights) and [Docker Hub access tokens](https://docs.docker.com/docker-hub/access-tokens).

```
source set-credentials.sh
```{{execute}}

## Create namespaces

To simulate the dev an prod environments into which we will be deploying the sample app, create dev and prod namepsaces.

```
kubectl create ns dev
kubectl create ns prod
```{{execute}}

## Clone repo

If you completed the previous scenario, clone your sample repo:

```
git clone https://github.com/$GITHUB_NS/go-sample-app.git
```{{execute}}

## ALTERNATIVE: Clone the "short-cut" reference sample repo

If you have not completed the previous scenario and want to skip ahead to this one, you can create a fork from the reference sample corresponding to this scenario.

If you have an existing fork of the [sample app repo](https://github.com/springone-tour-2020-cicd/go-sample-app.git), you can skip this next command block. Otherwise, clone and fork the sample repo. Enter your GitHub user name and access token at the prompt.

```
hub clone https://github.com/springone-tour-2020-cicd/go-sample-app.git && cd go-sample-app
```{{execute}}

```
hub fork --remote-name origin
```{{execute}}

Check out the "short-cut" branch.
```
BRANCH=scenario-4-finished
git checkout --track origin/$BRANCH
```{{execute}}

Replace the `springone-tour-2020-cicd` namespace with your namespaces:

```
find . -name *.yaml -exec sed -i "s/\/springone-tour-2020-cicd/\/${GITHUB_NS}/g" {} +
find . -name *.yaml -exec sed -i "s/ springone-tour-2020-cicd/ ${IMG_NS}/g" {} +
```{{execute}}

Commit your changes:
```
git add -A
git commit -m "Reset from branch $BRANCH, updated namespaces"
```{{execute}}

Rename branches so that the scenario branch becomes the master branch:

```
git branch -m master scenario-1-start
git branch -m $BRANCH master
```{{execute}}

Push the new master branch to GitHub. Authenticate at the prompt.
```
git push -f -u origin master
```{{execute}}

Optionally, save the old master to GitHub as well and delete the local copy (ignore the warning):
```
git push -f origin scenario-1-start
git branch -d scenario-1-start
```{{execute}}
