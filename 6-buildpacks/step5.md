# From polling to pushing

Objective:
As mentioned before, kpack will by default, poll the source code repo for commits every 5 minutes, and automatically re-build the image if it detects a new commit.

This means kpack is not a sequential part of the build pipeline like Kaniko or the Tekton Buildpack Task.
This is fine, as long as you always wish to build an image regardless of linting and testing feedback.

In this step, you will:
- Make kpack builds conditional on linting and testing feedback, using a push instead of a poll model

## Update the build pipeline to trigger kpack

We can trigger kpack at the end of the build pipeline by updating the `Image` resource.
The kpack controller tracks all `Image` resources in the cluster.
If the Git revision of an `Image` were to change, the controller will automatically kick off a build and push.

First of all we need to get remove the two existing image related tasks from the build pipeline.
```
cd ../tekton
yq d notyetfinished


```{{execute}}

You can now turn off the automatic polling, by changing the `updatePolicy` to `external`.

```
yq m -i builder.yaml - <<EOF
spec:
  updatePolicy: external
EOF
```{{execute}}
