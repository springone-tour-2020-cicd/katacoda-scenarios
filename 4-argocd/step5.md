# Driving change through GitOps

Any change to the ops repo on GitHub will cause Argo CD to update the deployment.

As an example, let's try changing the image tag to simulate an application upgrade deployment. We have made the new app image available on Docker Hub already, so you just need to change the tag value in the Kustomization file. Let's switch back to `Hello World!`, which was part of the 1.0.0 release.

Run the following command:

```
cd go-sample-app/ops/overlays/dev
yq m -i -x kustomization.yaml - <<EOF
images:
  - name: ${GITHUB_NS}/go-sample-app  # used for Kustomize matching
    newTag: 1.0.0
EOF
```{{execute}}

Push the change to GitHub so Argo CD can detect it:

```
git commit -am "Switched back to 1.0.0"
git push
```{{execute}}

If you have two-factor authentication set up on your GitHub account, you can [create an access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) to use as a password. If it's easier, you can also make the change to the `newTag` value manually through the GitHub UI.

Now sit back and watch Argo CD update the deployment of go-sample-app-dev.

You can verify the new deployment in the UI by clicking into the application `go-sample-app-dev` and clicking on `History and Rollback`. You should see two entries.

## Test the app

Wait for the deployment to finish:

```
kubectl rollout status deployment/go-sample-app -n dev
```{{execute}}

Set up port-forwarding again and test the app:

```
kubectl port-forward service/go-sample-app 8080:8080 -n dev 2>&1 > /dev/null &
APP_PID=$!
```{{execute}}

Send a request. Validate that the app responds with "Hello, world!" again.

```
curl localhost:8080
```{{execute}}

## Cleanup
Stop the port-forwarding process for our application.

```
kill ${APP_PID} && wait $!
```{{execute}}
