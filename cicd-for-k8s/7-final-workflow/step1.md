# Prepare environment

Objective:

Prepare your local environment.

In this step, you will:
- Validate that the environment is initialized
- Set up access to GitHub and Docker Hub
- Clone sample repos
- Create Kubernetes namespaces
- Install Tekton
- Install kpack
- Provide access to Docker Hub from Kubernetes
- Install Argo CD

## Validate environment initialization

Please wait until `Environment ready!` appears in the terminal window.

## Set up access to GitHub and Docker Hub

You will use your GitHub account to create/update repos, and you will use your Docker Hub account to push images.

Run the following script and provide your account details at the prompts. It is better practice to use an access token than a password. For more information, see [GitHub access tokens](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) (select "repo" access rights) and [Docker Hub access tokens](https://docs.docker.com/docker-hub/access-tokens).

```
source set-credentials.sh
```{{execute}}

As a convenience, your GitHub and Docker Hub namespaces (org names) are now stored in env vars `$GITHUB_NS` and `$IMG_NS`, respectively. These variables will be used througout the scenario.

## Clone repos

If you completed the previous scenario and have an existing fork of the [sample app repo](https://github.com/springone-tour-2020-cicd/go-sample-app.git) and an ops repo, clone your forks.

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

To simulate the dev and prod environments into which you will be deploying the sample app, create dev and prod namepsaces.

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
```{{execute}}

## Install kpack

Install kpack to the kubernetes cluster.

```
kubectl apply -f https://github.com/pivotal/kpack/releases/download/v0.0.9/release-0.0.9.yaml
```{{execute}}

## Provide access to Docker Hub from Kubernetes

Create a Secret in Kubernetes so that Tekton and kpack can publish images to Docker Hub.

```
kubectl create secret generic regcred  --from-file=.dockerconfigjson=/root/.docker/config.json --type=kubernetes.io/dockerconfigjson
```{{execute}}

## Provide GitHub write access from Kubernetes

Your GitHub token is stored in environment variable GITHUB_TOKEN, so you can simply run the following command to create a Secret for Tekton:

```
kubectl create secret generic github-token --from-literal=GITHUB_TOKEN=${GITHUB_TOKEN}
```{{execute}}

# Install Argo CD

Run the following commands to install ArgoCD, disable the kustomize load-restrictor, and wait for the Argo CD installation to complete.

```
kubectl create ns argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

yq m <(kubectl get cm argocd-cm -o yaml -n argocd) <(cat << EOF
data:
  kustomize.buildOptions: --load_restrictor none
EOF
) | kubectl apply -f -

kubectl rollout status deployment/argocd-server -n argocd
```{{execute}}

Run the following command to set up port-forwarding. The command will automatically run in separate terminal window.
```
kubectl port-forward --address 0.0.0.0 svc/argocd-server 8080:80 -n argocd 2>&1 > /dev/null &
```{{execute T2}}

The following commands will log you in through the `argocd` CLI.
```
ARGOCD_PASSWORD="$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)" && echo -e "Your ArgoCD password is:\n${ARGOCD_PASSWORD}"
argocd login localhost:8080 --insecure --username admin --password "${ARGOCD_PASSWORD}"
```{{execute T1}}

You will also need to use the UI in this scenario.
Click on the tab titled `Argo CD UI`.
This tab is pointing to localhost:8080, so it should open the Argo CD dashboard UI.
Click the refresh icon at the top of the tab if it does not load automatically.

Alternatively, you can click on the link below and open in a separate tab in your browser:

https://[[HOST_SUBDOMAIN]]-8080-[[KATACODA_HOST]].environments.katacoda.com

Log in using the username _admin_ and password that was echoed to the terminal.
