# Scenario environment

Your scenario environment comes with some pre-installed tools/assets. Let's review them.

Wait until `Environment ready!` appears in the terminal window.

- We'll need an app to build.

To verify that the **sample app** was downloaded, run `ls spring-sample-app`{{execute}}.
You should see the the usual Maven app contents.

- We will be using the `pack` CLI to build the image.

To verify that **pack** is installed, run `pack --version`{{execute}}.
You should see the version of pack displayed.

- `pack` pushes images to a Docker registry. We'll use the local Docker daemon.

To verify that **Docker** is installed, run `docker --version`{{execute}}.
You should see the version of Docker displayed.

- We'll use off-the-shelf buildpacks to start, but then we'll experiment with a custom buildpack.

To verify that the **sample custom buildpack** was downloaded, run `ls samples/buildpacks/hello-world`{{execute}}.
You should see some files listed.



Now on to the real stuff!