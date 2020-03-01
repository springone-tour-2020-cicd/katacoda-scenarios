# Configure kpack

To configure the builder, we will use the ClusterBuilder CRD installed with kpack. To configure the source and destination, we will use the kpack Image CRD. We will also need to grant write access to Docker Hub, so we'll configure a Secret and a Service Account using corresponding Kubernetes primitives. 

Take a look at the contents of the supplied yaml file and notice all of these resource definitions:
```
cat ~/kpack-config/kpack-config.yaml
```{{execute}}

Notice that the ClusterBuilder (a builder scoped to the cluster rather than a namespace), we are using the same builder we used with `pack` and Spring Boot (cloudfoundry/cnb:0.0.53-bionic), so we can be sure that the resulting image is the same, regardless of which of the three platforms we used to generate it.

Notice also three placeholder values:
- DOCKERHUB_USERNAME_PLACEHOLDER
- DOCKERHUB_PASSWORD_PLACEHOLDER
- DOCKERHUB_ORG_PLACEHOLDER

 To update these placeholders with your Docker Hub account details, run the following script and respond to the prompts:
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

