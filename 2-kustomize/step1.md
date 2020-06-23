# Prepare environment

Objective:
Prepare your local environment.

In this step, you will:
- Validate that the environment is initialized
- Set env vars with your GitHub and Docker Hub namespaces
- Create `dev` and `prod` namespaces in the Kubernetes cluster to represent deployment environments
- Clone your GitHub repo (or the reference sample repo if you skipped the previous scenario)

## Validate environment initialization

Please wait until `Environment ready!` appears in the terminal window.

## Set environment variables

Your GitHub and Docker Hub namespaces (user or org names) will be needed in this scenario.
Copy and paste the following environment variables to the terminal window, then append the appropriate namespace:

```
# Provide your GitHub user or org name
GITHUB_NS=
```{{copy}}

```
# Provide your Docker Hub user or org name
IMG_NS=
```{{copy}}

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

List the available branches
```
git ls-remote --heads | grep scenario
```{{execute}}

Choose the branch that corresponds to the end of the last scenario. Copy and paste the following environment variable to the terminal window, then append the appropriate branch name. Use only the portion after `refs/heads/` (e.g. BRANCH=scenario-1-finished).
```
# Fill this in with the branch name (e.g. BRANCH=scenario-1-finished)
BRANCH=
```{{copy}}

Check out the selected branch.
```
git checkout --track origin/$BRANCH
```{{execute}}

Replace the `springone-tour-2020-cicd` namespace with your namespaces:

```
find . -type f -name "*.yaml" -print0 | xargs -0 sed -i '' -e "s/\/springone-tour-2020-cicd/\/$GITHUB_NS/g"
find . -type f -name "*.yaml" -print0 | xargs -0 sed -i '' -e "s/ springone-tour-2020-cicd/ $IMG_NS/g"
```{{execute}}

```
git add -A
git commit -m "Reset from branch $BRANCH, updated namespaces"
git rebase master
git checkout master
git merge $BRANCH
git push -u origin master
```{{execute}}
