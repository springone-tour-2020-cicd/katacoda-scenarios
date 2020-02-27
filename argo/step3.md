# Log in to Argo CD

Let's log through both the CLI and the UI.

##### Log in using argocd CLI

First, we need to obtain login credentials. The default admin username is `admin`. In order to get the default admin password, run:
```
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```{{execute}}

Copy the password displayed on the screen, and use it to log into the CLI. Replace ARGOCD_SERVER with the EXTERNAL-IP from the previous step.
```
argocd login <ARGOCD_SERVER>
```{{copy}}

Enter `y` when prompted, then enter `admin` as the username and copy the password from above to log in.

OPTIONAL:
You can use ```argocd account update-password```{{copy}} to update the password to something that's easier to remember.

Next, let's log into UI. Click on the window where you have the Dashboard UI open and log in using the admin user credential.
