# GitOps repositories

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

```
Magic!
```{{execute}}
