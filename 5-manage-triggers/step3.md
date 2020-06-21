# Automating promotion

Assuming the `PipelineRun` finished successfully, you now have a new image in your Docker Hub account.

In order for you to deploy this image to the dev environment, you need to manually update the Kustomization file with the new image's tag.
As seen in the [previous scenario](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/4-argocd), Argo CD will then go on to automatically deploy the resources.

Instead of doing this manually, it'd be better to have another pipeline update the Kustomization file automatically, based on a trigger listening to Docker Hub webook events.

## Endless commit loop

Let's say you'd implement the promotion pipeline with the Docker Hub trigger.
The flow would be as follows:

1. A developer makes a change to the Go source code and pushes it to Git
1. The Git change to the repo triggers our build pipeline
1. The build pipeline pushes a new image to Docker Hub
1. The new image in Docker Hub triggers the promotion pipeline
1. The promotion pipeline changes the Kustomization file which Argo CD will deploy
1. The promotion pipeline pushes the code change to Git
1. The Git change to the repo triggers our build pipeline
1. And on and on we go...

This flow would trigger an endless loop, creating Docker images and Git commits until storage runs out.

You could alter the trigger to look for changes based on regular expressions or file paths, but there might be a better and cleaner alternative.

## GitOps repositories

Until now, we've put our Kubernetes and Kustomize resource files inside the `ops` directory of our application source code repository.

However, keeping the config separate from your application source code inside a separate Git repository is highly recommended for the following reasons:

- It provides a clean separation of application code vs. application config.
There will be times when you wish to modify just the manifests without triggering an entire CI build.
For example, you likely do not want to trigger a build if you simply wish to bump the number of replicas in a Deployment spec.

- Cleaner audit log. For auditing purposes, a repo which only holds configuration will have a much cleaner Git history of what changes were made, without the noise coming from check-ins due to normal development activity.

- Your application may be comprised of services built from multiple Git repositories, but is deployed as a single unit.
It may not make sense to store the manifests in one of the source code repositories of a single component.

- Separation of access.
The developers who are developing the application, may not necessarily be the same people who can/should push to production environments, either intentionally or unintentionally.
By having separate repos, commit access can be given to the source code repo, and not the application config repo.

If you are automating your CI pipeline, pushing manifest changes to the same Git repository can trigger an infinite loop of build jobs and Git commit triggers. Having a separate repo to push config changes to, prevents this from happening.

Most of these concerns can still be solved by configuring conditional triggers, using specific Git commit messages, or build conditions based on files changed.
Nevertheless, using Git as the elbow joints of different pipeline parts makes a remarkably good fit.
It allows pipelines to be modular and can easily be expanded and retracted when required.

Let's adopt separate GitOps repositories for the development and production environment.

## Moving the ops files

Go ahead and move the ops files to another repository.

```
cd ../..
mkdir go-sample-app-ops
mv go-sample-app/ops go-sample-app-ops
```{{execute}}

You can also move the Tekton files, so that Argo CD will also automatically deploy them to Kubernetes.

```
mv go-sample-app/tekton go-sample-app-ops/tekton
tree .
```{{execute}}

Let's commit the changes to the source code repository first.
Note that `git push` will need a [Personal Access Token](https://github.com/settings/tokens) as password to authenticate.

```
cd go-sample-app
git add -A
git commit -m "Moved ops and tekton directories to their own repo"
git push origin master
```{{execute}}

You can create the new ops repository on GitHub using `hub`.
Enter your GitHub username and access token at the prompt to authenticate against GitHub.

```
cd ../go-sample-app-ops
git init
hub create
```{{execute}}

And finally commit all the moved files into it.

```
git add -A
git commit -m "Files moved from go-sample-app repo"
git push origin master
```{{execute}}

Now that you've avoided infinite loops by adopting a specialized ops repo, you can now safely add the promotion pipeline.
