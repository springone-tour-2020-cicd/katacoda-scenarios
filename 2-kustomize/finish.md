At the end of the prerequisites scenario, you introduced a production environment and began seeing duplication and divergence in your YAML ops files.

This duplication and divergence can potentilly become complex to manage, and in this scenario you learned how to use Kustomize to better manage and modify the environment-specific configuration of your Kubernetes deployments.

In this scenario, you :
 - created a shared set of base ops files
 - created overlays to specify environment-specific configuration
 - used Kustomize to compose the base and overlay files into an environment-specific YAML file for deployment to Kubernetes
