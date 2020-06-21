# Save your changes

You will need the new files you've created for the labs ahead. In this step you will push your changes to your GitHub repo.
Note that `git push` will need a [Personal Access Token](https://github.com/settings/tokens) as password to authenticate.

```
git add -A
git commit -m 'Changes from the ArgoCD scenario'
git push origin master
```{{execute}}

You are now ready to proceed with the other scenarios in this course.



Finally, as we mentioned earlier, you can query for Argo CD Applications and ApplicationProjects:
```
kubectl get applications,appprojects -n argocd
```{{execute}}