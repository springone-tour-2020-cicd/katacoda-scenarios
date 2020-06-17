# Save your changes

You will need your repo and the new files you've created for the labs ahead. In this step you will fork the sample repo into your own GitHub account and save your changes.

## Fork the GitHub repo and push your changes

Use the `hub` CLI to fork the sample repo and push your changes to GitHub. Enter your GitHub username and access token at the prompt to authenticate against GitHub.

```
hub fork --remote-name origin
```{{execute}}

`hub` automatically updates your `origin` remote to point to your fork of the repo, so you can simply commit and push the changes you made throughout this scenario. Note that `git push` will need a [Personal Access Token](https://github.com/settings/tokens) as password to authenticate.

```
git add -A
git commit -m 'Changes from the Intro Scenario'
git push origin master
```{{execute}}

You are now ready to proceed with the other scenarios in this course.
