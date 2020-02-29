# Driving change through GitOps

Any change to the ops repo on GitHub will cause Argo CD to update the deployment.

As an example, let's try changing the image tag to simulate an application upgrade deployment. We have made the new app image available on Docker Hub already, so you just need to change the tag value in the ops repo.

spring-sample-app-ops/overlays/dev/kustomization.yaml

Run the following command:
```
sed -i 's/newTag: 1.0.0/newTag: 1.0.1/g' spring-sample-app-ops/overlays/dev/kustomization.yaml
```{{execute}}

Validate the code change. You should see 'newTag: 1.0.1'.
```
cat spring-sample-app-ops/overlays/dev/kustomization.yaml
```{{execute}}

Push the change to GitHub so Argo CD can detect it:
```
cd spring-sample-app-ops
git add overlays/dev/kustomization.yaml
git commit -m "new tag"
git push
```

If you have two-factor authentication set up on your GitHub account, you can [create an access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) to use as a password. If it's easier, you can also make the change to the `newTag` value manually through the GitHub UI.

Now sit back and watch Argo CD update the deployment of spring-sample-app-dev.

You can veryfy the new deployment in the UI by clicking into the application `spring-sample-app-dev` and clicking on `History and Rollback`. You should see two entries.