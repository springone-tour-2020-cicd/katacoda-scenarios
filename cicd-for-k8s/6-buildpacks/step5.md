# Deliberate image builds

Objective:

In the current workflow, both Tekton and kpack will be triggered by every git commit to the app repo. 
Review the conflicts with this flow and options to resolve the issue.

In this step, you will...
- Review the problem statement
- Review options to resolve

## Same trigger, two flows...

Given the flow we have configured thus far in this course, when a commit occurs on the master branch of the sample app repo, Tekton and kpack will both independently detect the change.
- Tekton will test the app and, if tests pass, it will build an image using the Dockerfile
- kpack will build the image using Paketo Buildpacks

There are several issues with this setup:
- two images will be published to Docker Hub for every git commit
- the images are built differently (Dockerfile vs Paketo), and will have different digests
- each image will trigger the rest of the workflow to deploy to Kubernetes
- kpack may build images from code that will not pass testing

## Possible solutions

There are a few approaches we can take to resolve the problem, and each approach will have trade-offs.

**Option 1**
For example, we could simply uninstall kpack and leave the Tekton flow as is, using Dockerfile to build images.

However, let's assume we want this flow to handle different kinds of applications and be beneficial to multiple teams.

Given the challenges we discussed with Dockerfiles and the benefits of using Cloud Native Buildpacks instead, we will choose to use Cloud Native Buildpacks to build the image.

**Option 2**
We mentioned earlier that Tekton itself is also a CNB platform. 
Take a look at the [Buildpacks task](https://github.com/tektoncd/catalog/blob/v1beta1/buildpacks/README.md) that is available in the Tekton catalog.
If you look at the [buildpacks-v3.yaml file](https://github.com/tektoncd/catalog/blob/v1beta1/buildpacks/buildpacks-v3.yaml), you'll see that the steps reflect the same lifeycle you observed with pack and kpack.

This means that we could configure Tekton directly to build images using the Paketo builder.
That would enable us to eliminate the dependency on the Dockerfile and take advantage of many of the benefits of Cloud Native Buildpacks and Paketo Buildpacks right in our Tekton pipeline.

While this option is prefereble to the first, it means we lose the added-value of kpack.
- Tekton does not provide a workflow for rebasing images
- kpack is purpose-built for Cloud Native Buildpacks and makes it much easier to configure and manage builds

Given the benefits of kpack, we will choose to use it in our workflow.

**Option 3**
Use a different git branch for untested commits. Configure Tekton to monitor this branch. If a commit passes testing, Tekton can promote the changes to the master branch, which would trigger kpack.

This solution works well for a team or organization using a branching strategy (e.g. feature branch development).

However, our sample app is very simple with a development team size of one (you!), so mainline (also known as trunk-based) development works well. This may be true for many microservice-style applications that are owned by small teams. Employing a branching strategy would add unnecessary complexity to the developer experience.

**Option 4**
Currently, kpack is building an image for every commit to the master branch because the `revision` node in the Image configuration is set to master. Review the configuration of `image.yaml`:

```
cat /workspace/go-sample-app-ops/cicd/kpack/image.yaml
```{{execute}}

If the `revision` is set to a specific git commit id instead, kpack would only build an image for that commit id.

This means we can leave Tekton configured to test every commit to the master branch, and then update the `revision` node in the kpack `image.yaml` file with git commit ids that pass testing. Tekton will therefore be delegating all image builds to kpack, and kpack will only build images for tested commits.

kpack will continue to poll for changes to the builder and run images, and rebuild or rebase images, as appropriate, when these change, so we can resolve the conflict between Tekton and kpack without sacrificing the additional benefits of kpack.

In the next step, you will implement Option 4.
