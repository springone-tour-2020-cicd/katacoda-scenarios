# Logging in...

There are two ways to interact with Argo CD: the CLI and the UI. Lets' begin by logging into each of them.

## The CLI

First, we need to obtain login credentials. The default admin username is `admin`. In order to get the default admin password, run:
```
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```{{execute}}

Copy the password displayed on the screen, and use it to log into the CLI. Assuming you set the value of the environment variable ARGOCD_SERVER in the previous step, you can run the following command:
```
argocd login $ARGOCD_SERVER --insecure --username admin
```{{execute}}

Set up port-forwarding again and test the app:

```
kubectl port-forward --address 0.0.0.0 pod/argocd-server-6766455855-vm2vf 8080:8080 -n argocd 2>&1 > /dev/null &
```{{execute}}

Copy the password displayed on the screen, and use it to log into the CLI.
Log into ArgoCD.

```
argocd login localhost:8080 --insecure --username admin
```{{execute}}

## Cleanup
Stop the port-forwarding process and return to the app's root directory:

```
pkill kubectl && wait $!
cd ..
```{{execute}}

When prompted, copy and paste the password from the previous command.

OPTIONAL:
You can use ```argocd account update-password```{{execute}} to update the password to something that's easier to remember.

## The UI

Next, let's log into UI.

Click on the tab titled `Dashboard`. This tab is defaulting to localhost:80 in the tutorial environment, so it will automatically open the Argo CD dashboard UI when the service EXTERNAL IP becomes ready.

You can also use the following link to open the Argo CD UI in a new tab if you prefer:

https://[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com

Enter the same credentials you used for the CLI.



Next, let's deploy an application!