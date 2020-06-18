# Tutorial environment

Your tutorial environment comes with some pre-installed tools. Let's review them.

## Local environment setup
Please wait until `Environment ready!` appears in the terminal window.

## Clone repo

Start by cloning the GitHub repo you created in the [previous](https://www.katacoda.com/springone-tour-2020-cicd/scenarios/1-intro-workflow) scenario.  For convenience, set the following environment variable to your GitHub namespace (your user or org name). You can copy and paste the following command into the terminal window, then append your GitHub username or org:

```
# Fill this in with your GitHub username or org
GITHUB_NS=
```{{copy}}

Next, clone your fork of the sample app repo:
```
git clone https://github.com/$GITHUB_NS/go-sample-app.git
```{{execute}}

Now on to the real stuff!