# First deployment

Let's deploy our sample application (the one you forked earlier).

We only have one Kubernetes cluster, so we will be deploying our app to the same cluster in which we installed Argo CD. You can also easily attach other clusters to Argo CD and use it to deploy apps to to those.

In the UI, click on `+ NEW APP`.

Fill in the form as follows, using details pertaining to your fork of the sample app. Make sure to replace the placeholder `YOUR-GITHUB-ORG` with the proper value. Leave any fields not mentioned below at their default value.
```
GENERAL
Application Name: spring-sample-app
Project: default
SYNC POLICY: Automatic

SOURCE
Repository URL: https://github.com/<YOUR-GITHUB-ORG>>/spring-sample-app.git
Revision: HEAD

DESTINATION
Cluster:
Namespace: default
```



Wait till you see the new app appear. CLick on the box / tile

Green hearts meena running, healthy

open app:

new dash, change port to 80, remove applications (or put link here)

Let's make a change and watch argo propagate it.
Any change to gitops will trigger argo.

Let's change replicas.

Back to Argo, refresh, see two more pods.


###### DELETE ME

other sample app:
Sample app:
https://github.com/argoproj/argocd-example-apps.git




