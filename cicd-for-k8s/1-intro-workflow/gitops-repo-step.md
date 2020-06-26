# ROUND 3 - Put it into Git!

Now that you have seen the process of an initial deployment as well as a subsequent updates, let's prepare to automate. You are already using a network-accessible image registry (Docker Hub). Next, you need to make your source code changes and ops files network-accessible as well.

In this step, you will:
1. Fork the sample app repo into your GitHub account
2. Create a new repo for the ops files in your GitHub account


## Create GitHub repo for ops files
Use the `hub` CLI to create a new repo for the ops files and push the files to GitHub:

```
cd /workspace/go-sample-app-ops
git init; git add .; git commit -m 'initial commit'
hub create go-sample-app-ops
git push -u origin HEAD
```{{execute}}

That's it! You are now ready to begin automating the build & deployment process. Continue to the remaining scenarios in this course to explore a selection of tools for CI/CD automation.
