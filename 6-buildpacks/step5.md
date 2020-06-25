# Save your changes

In the next step, you will configure kpack to use a custom builder and also rebase an image. 
However, take a moment to save the current kpack configuration manifests to GitHub so that you can use them in the next scenario. 
You won't need to save the manifests created in the next step.

In this step you will push your changes to your GitHub repo.

## Push changes to GitHub

If prompted, enter your GitHub username and access token to authenticate.

```
cd /workspace/go-sample-app
git add -A
git commit -m 'Changes from the Buildpacks scenario'
git push origin master
```{{execute}}

```
cd /workspace/go-sample-app-ops
git add -A
git commit -m 'Changes from the Buildpacks scenario'
git push origin master
```{{execute}}
