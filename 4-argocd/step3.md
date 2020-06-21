# Log in to Argo CD

Objective:
Log in to Argo CD using both the `argocd` CLI as well as the UI.

In the step, you will:
* Obtain the default password for the admin user
* Log in using the `argocd` CLI
* Log in using the Argo CD UI

## argocd CLI

First, we need to obtain login credentials. The default admin username is `admin`. In order to get the default admin password, run:
```
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```{{execute}}

Copy the password displayed on the screen, and use it to log into the CLI. Assuming you set the value of the environment variable ARGOCD_SERVER in the previous step, you can run the following command:
```
argocd login localhost:8080 --insecure --username admin
```{{execute}}

Copy the password displayed on the screen, and use it to log into the CLI.
Log into Argo CD.

When prompted, copy and paste the password from the previous command.

OPTIONAL:
You can use ```argocd account update-password```{{execute}} to update the password to something that's easier to remember.

## Argo CD UI

Click on the tab titled `Argo CD UI`. This tab is pointing to localhost:8080, so it should open the Argo CD dashboard UI. Click the refresh icon at the top of the tab if it does not load automatically.

Alternatively, you can click on the link below and open in a separate tab in your browser:

https://[[HOST_SUBDOMAIN]]-8080-[[KATACODA_HOST]].environments.katacoda.com

Enter the same credentials you used for the CLI.