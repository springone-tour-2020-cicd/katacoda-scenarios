# Scenario environment

Your scenario environment comes with some pre-installed tools/assets. Let's review them.

Wait until `Environment ready!` appears in the terminal window.

We'll need a Kubernetes cluster so that we can install and configure kpack.
- To verify that **kubectl** and **Kubernetes** are installed, run `kubectl cluster-info`{{execute}}.
You should see information about the running cluster.

kpack provides a CLI tool called `logs` specifically for accessing logs produced during image builds.
- To verify that **logs** CLI for kpack is installed, run `logs --help`{{execute}}.
You should see the usage guide for logs displayed.

We'll be using GitHub and Docker Hub as the source and destination for our build, so we don't need local resources for these. We'll use an existing public GitHub repo for the source, but you will need to use your own Docker Hub account to store images. If you don't already have a Docker Hub account, take a moment to create one now [here](https://hub.docker.com/signup). 


Now on to the real stuff!