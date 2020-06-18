# Logging in...

There are two ways to interact with Argo CD: the CLI and the UI. Lets' begin by logging into each of them.

## The CLI

First, we need to obtain login credentials. The default admin username is `admin`. In order to get the default admin password, run:
```
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```{{execute}}

Copy the password displayed on the screen, and use it to log into the CLI. Assuming you set the value of the environment variable ARGOCD_SERVER in the previous step, you can run the following command:
```
argocd login localhost:8080 --insecure --username admin
```{{execute}}

Copy the password displayed on the screen, and use it to log into the CLI.
Log into ArgoCD.

When prompted, copy and paste the password from the previous command.

OPTIONAL:
You can use ```argocd account update-password```{{execute}} to update the password to something that's easier to remember.

## The UI

Next, let's log into UI.

Click on the tab titled `ArgoCD UI`. This tab is pointing to localhost:8080, so it should open the Argo CD dashboard UI.

You can also use the following link to open the Argo CD UI in a new tab if you prefer:

https://[[HOST_SUBDOMAIN]]-8080-[[KATACODA_HOST]].environments.katacoda.com

Enter the same credentials you used for the CLI.



Next, let's deploy an application!