# Log in to Argo CD

There are two ways to interact with Argo CD: the CLI and the UI. Let's log in through both.

### Log in using argocd CLI

First, we need to obtain login credentials. The default admin username is `admin`. In order to get the default admin password, run:
```
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```{{execute}}

Copy the password displayed on the screen, and use it to log into the CLI. Assuming you set the value of the environment variable ARGOCD_SERVER in the previous step, you can run the following command:
```
argocd login $ARGOCD_SERVER
```{{copy}}

Enter `y` when prompted. Then enter `admin` as the username and copy the password from above to log in.

OPTIONAL:
You can use ```argocd account update-password```{{copy}} to update the password to something that's easier to remember.

### Log in using Argo CD UI

Next, let's log into UI.

Click on the tab titled `Dashboard`. This tab is defaulting to localhost:80 in the tutorial environment, so it will automatically open the Argo CD dashboard UI.

You can also use the following link if you prefer to open the UI in a separate browser tab:

https://[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com

Enter the same credentials you used for the CLI.



Next, let's deploy an application!