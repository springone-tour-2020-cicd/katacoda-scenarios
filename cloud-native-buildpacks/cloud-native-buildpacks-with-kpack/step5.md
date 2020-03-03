# Configure kpack

We've provided a yaml file containing the necessary configuration. Let's review the contents:
```
cat ~/kpack-config/kpack-config.yaml
```{{execute}}

Notice that it contains four resources. Two are standard Kubernetes resources (Secret and ServiceAccount) and two use CRDs created by kpack (ClusterBuilder and Image).

The key resource is the last one, the **Image** resource. Take a look at this one closely. Notice that it defines:
- The builder to use: default
- The source code:  https://github.com/springone-tour-2020-cicd/spring-sample-app.git
- The destination registry: DOCKERHUB_ORG_PLACEHOLDER/spring-sample-app:latest

The other three resources in the file support the above Image configuration. The ClusterBuilder resource contans the precise details of what we are calling the default builder (cloudfoundry/cnb:bionic). The Secret and ServiceAccount provide credentials to publish to Docker Hub.

# Provide your Docker Hub credentials

Notice three placeholder values in our yaml file:
- DOCKERHUB_USERNAME_PLACEHOLDER
- DOCKERHUB_PASSWORD_PLACEHOLDER
- DOCKERHUB_ORG_PLACEHOLDER

You'll need to replace these with your Docker Hub account details. To do so, run the following script and respond to the prompts:
```
~/kpack-config/kpack-config.sh
```{{execute}}

Take a look at the yaml file again and validate that the three placeholders were correctly updated (your password will show up on the screen so make sure no one is looking over your shoulder!)
```
cat ~/kpack-config/kpack-config.yaml
```{{execute}}

Clear your password from the screen:
```
clear
```{{execute}}

