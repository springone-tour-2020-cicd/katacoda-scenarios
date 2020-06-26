# Prepare environment

Objective:


Prepare your local environment.

In this step, you will:
- Validate that the environment is initialized
- Configure setup for using GitHub and Docker Hub in the scenario

## Validate environment initialization

Please wait until `Environment ready!` appears in the terminal window.

## Set up access to GitHub and Docker Hub

You will use your GitHub account to create/update repos, and you will use your Docker Hub account to push images.

Run the following script and provide your account details at the prompts. It is better practice to use an access token than a password. For more information, see [GitHub access tokens](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) (select "repo" access rights) and [Docker Hub access tokens](https://docs.docker.com/docker-hub/access-tokens).

```
source set-credentials.sh
```{{execute}}
