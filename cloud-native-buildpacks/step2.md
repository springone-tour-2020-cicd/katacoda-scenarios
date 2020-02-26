# Tutorial environment

Your tutorial environment comes with some pre-installed tools and assets. Let's review them.

Wait until `Environment ready!` appears in the terminal window.

We're going to be generating OCI images from source code. A sample app is provided, and Docker daemon is installed.

- To verify that the **sample app** was downloaded, run `ls spring-sample-app`{{execute}}.
You should see the the usual Maven app contents.

- To verify that **Docker** is installed, run `docker --version`{{execute}}.
You should see the version of Docker displayed.

The various platforms we will be exploring to build images require some tools to be installed.

- To verify that **pack** CLI is installed, run `pack --version`{{execute}}.
You should see the version of pack displayed.

- To verify that **kubectl** and **Kubernetes** are installed, run `kubectl cluster-info`{{execute}}.
You should see information about the running cluster.

- To verify that **logs** CLI for kpack is running, run `logs --help`{{execute}}.
You should see the usage guide for logs displayed..

We'll also experiment with a custom buildpack.

- To verify that the **sample custom buildpack** was downloaded, run `ls samples/buildpacks/hello-world`{{execute}}.
You should see some files listed.



Now on to the real stuff!