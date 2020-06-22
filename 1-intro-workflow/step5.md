# Save your changes

Objective:
Save the sample repo, including the new ops directory with the deployment manifests, to your GitHub account. You will need the repo to build on this flow throughout the remaining scenarios.

In this step, you will:
1. Fork the sample repo to your GitHub account
2. Push your changes to GitHub

## Fork the sample repo

Use the `hub` CLI to fork the sample repo to your GitHub account. You will need to provide your GitHub username and access token at the prompt to authenticate `hub` against GitHub.

```
hub fork --remote-name origin
```{{execute}}

## Push your changes to GitHub

Commit and push the changes you made throughout this scenario to your new fork. You will need to provide your GitHub username and access token at the prompt to authenticate `git` against GitHub.

```
git add -A
git commit -m 'Changes from the Intro Scenario'
git push origin master
```{{execute}}

You are now ready to proceed with the other scenarios in this course.
