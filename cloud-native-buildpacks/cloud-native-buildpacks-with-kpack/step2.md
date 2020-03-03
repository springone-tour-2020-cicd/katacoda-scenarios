# Scenario environment

Your scenario environment comes with some pre-installed tools/assets. Let's review them.

Wait until `Environment ready!` appears in the terminal window.

We'll be installing kpack into a Kubernetes cluster.
- To verify that **kubectl** and **Kubernetes** are installed, run `kubectl cluster-info`{{execute}}.
You should see information about the running cluster.

kpack provides a CLI tool called `logs` specifically for accessing logs produced during image builds.
- To verify that **logs** CLI for kpack is running, run `logs --help`{{execute}}.
You should see the usage guide for logs displayed.

We'll also need an app to build and a Docker registry to which to publish the image. Since kpack runs in a Kubernetes cluster, it does not have access to the local host in the same way `pack` and the Spring Boot plugins for Maven and Gradle do. Hence, we will be using GitHub and Docker Hub as the source and destination for our build.



Now on to the real stuff!