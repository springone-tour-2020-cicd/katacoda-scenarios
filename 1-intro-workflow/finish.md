In this scenario, you set up a repositories in GitHub, built images using Dockerfile, pushed images to Docker Hub, and deployed and tested the app in Kubernetes.

You manually ran through the process of an initial build & deploy as well as deployment of a code update.
Introducing environments meant your Kubernetes resources started to divert.
You needed to find ways to alter these resources in a Kubernetes-native way while keeping your base resource definitions untouched.
Using Kustomize you managed to adjust the namespace, add configuration and merge everything together.

As we automate the process in the subsequent scenarios, you will also see how the process can work at scale and over time.
