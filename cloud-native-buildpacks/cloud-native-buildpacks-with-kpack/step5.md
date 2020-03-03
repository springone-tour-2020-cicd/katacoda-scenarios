# Configure kpack

We've provided a yaml file containing the necessary configuration. Let's review the contents:
```
cat ~/kpack-config/kpack-config.yaml
```{{execute}}

Notice that it contains four resources. Two are standard Kubernetes resources (Secret and ServiceAccount) and two use CRDs created by kpack (ClusterBuilder and Image).

The key resource is the last one, the **Image** resource. Take a look at this one closely. Notice that it defines:
- spec.builder specifies the builder
- spec.source specifies the app source
- spec.tag specifies the app image destination

The details of the builder that we have named as `default` are defined farther up the file, using the kpack CRD, ClusterBuilder. You can see this points to the cloudfoundry/cnb:bionic which we used previously in this course.

For the source we are choosing to point to a built jar file rather than the source code. With all of the platforms we have looked at in this course, we have the option to build from source or a built jar file. We'll use the latter option here to speed up the image build.

# Provide your Docker Hub credentials

To publish the image to Docker Hub, you need to provide your Docker account details. Notice that the yaml file contains placeholders:
- DOCKERHUB_USERNAME_PLACEHOLDER
- DOCKERHUB_PASSWORD_PLACEHOLDER
- DOCKERHUB_ORG_PLACEHOLDER

Replace these with your Docker Hub account details by running the following script and responding to the prompts:
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

