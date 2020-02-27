# Tutorial environment

Your tutorial environment comes with some pre-installed tools. Let's review them.

Wait until `Environment ready!` appears in the terminal window.

- To verify that **kubectl** and **Kubernetes** are installed, run `kubectl cluster-info`{{execute}}.
You should see information about the running cluster.

- To verify that **argocd** CLI is installed, run `argocd --help`{{execute}}.
You should see the usage guide for argocd CLI displayed.

# Additional assets

You'll also need to clone the GitHub sample-ops repository you forked in the [pre-requisites scenario](https://www.katacoda.com/markpollack/scenarios/github-dockerhub).

For simplicity, set the following environment variable to your GitHub org name:
```export MY_GITHUB_ORG=```{{copy}}

Run the following command to clone your fork of the [sample ops](https://github.com/springone-tour-2020-cicd/spring-sample-app-ops.git) repo:
```
git clone https://github.com/${MY_GITHUB_ORG}/spring-sample-app-ops.git
```{{execute}}


Now on to the real stuff!