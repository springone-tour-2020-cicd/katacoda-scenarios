In this scenario, you used a sample Go application to build images using Dockerfile, push them to Docker Hub, and deploy them to dev and prod environments in Kubernetes.

You manually ran through the process of an initial build & deploy, the deployment of a code update, and the promotion to a second environment.

In all cases you used a declarative approach for deploying the images, creating the necessary ops files and saving them to a git repository as a blue print and source of truth of the desired deployment. This is the foundation of GitOps.

In the following scenarios, you will learn how to improve these workflows by:
- replacing Dockerfile with higher level abstractions for building images
- eliminating duplication in your ops files
- automating the workflows
- leverage GitOps to ensure your deployment always reflects your declared state

These improvements will show how the process can work at scale and over time.
