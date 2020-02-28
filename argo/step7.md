# Driving change through GitOps

Any change to the ops repo on GitHub will cause Argo CD to update the deployment.

As an example, let's try changing the image tag to simulate an application upgrade deployment. We have made the new app image available on Docker Hub already, so you just need to change the tag value in the ops repo.

spring-sample-app-ops/overlays/dev/kustomization.yaml

Run the following command:
```
sed -i 's/newTag: 1.0.0/newTag: 1.0.1/g' spring-sample-app-ops/overlays/dev/kustomization.yaml
```{{execute}}

Validate the code change:
```
cat spring-sample-app-ops/overlays/dev/kustomization.yaml
```{{execute}}

Push the change to GitHub so Argo CD can detect it:
```
git add .
git commit -m "new tag"
git push
```

Now sit back and watch Argo CD update the deployment of spring-sample-app-dev.