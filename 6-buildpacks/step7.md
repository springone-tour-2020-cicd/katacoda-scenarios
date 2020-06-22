# The entire flow

Objective:
You now have all the necessary building blocks to put entire build and deploy pipeline together.

## Argo CD applications

Apply all the Argo CD configuration to the cluster.

```
kubectl create ns dev
kubectl create ns prod
kubectl create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl apply -f . -n argocd
```{{execute}}

## Disable the Kustomize load restrictor

Kustomize v3 allows us to disable the [security check introduced in Kustomize v2](https://kubernetes-sigs.github.io/kustomize/faq/#security-file-foo-is-not-in-or-below-bar) that prevents kustomizations from reading files outside their own directory root.
This was meant to help protect the person inclined to download kustomization directories from the web and use them without inspection to control their production cluster.
In our case we can safely disable this feature and preserve our folder structure.

```
yq m <(kubectl get cm argocd-cm -o yaml -n argocd) <(cat << EOF
data:
  kustomize.buildOptions: --load_restrictor none
EOF
) | kubectl apply -f -
```{{execute}}

## Deploy Tekton pipelines

Make sure all the pipelines are deployed.

```
cd ../tekton
kubectl apply -f .
```{{execute}}

## Test it out

Now we can make a change in our application and push it straight through our entire pipeline.

```
cd /workspace/go-sample-app
sed -i 's/sunshine/pipeline/g' hello-server.go
git add hello-server.go
git commit -m "Hello pipeline!"
git push
```

Store the pushed commit for the simulated webhook.

```
SHA=$(git rev-parse origin/master)
```{{execute}}

Our tutorial environment doesn't expose public IP addresses for `LoadBalancer` services, so we need to manually simulate a webhook call.

Wait for the deployment to finish.

```
kubectl rollout status deployment/el-build-event-listener
kubectl rollout status deployment/el-ops-dev-event-listener
```{{execute}}

Let's port-forward our service.

```
kubectl port-forward --address 0.0.0.0 svc/el-build-event-listener 8081:8080 2>&1 > /dev/null &
```{{execute}}

Now we can trigger a pull request event, which should create a new `PipelineRun`.

```
curl \
    -H 'X-GitHub-Event: pull_request' \
    -H 'Content-Type: application/json' \
    -d '{
      "repository": {"clone_url": "'"https://github.com/${IMG_NS}/go-sample-app"'"},
      "pull_request": {"head": {"sha": "${SHA}"}}
    }' \
localhost:8081
```{{execute}}

Next, verify the `PipelineRun` executes without any errors.

```
tkn pipelinerun list
tkn pipelinerun logs -f
```{{execute}}

If the pipeline finishes without errors, Argo CD should have noticed a change in the `Image` manifest.
Argo's automatic synchronization should have kicked off a kpack build.

```
kubectl get builds
```{{execute}}

Edit the name of the build in the following command to see the details:
```
kubectl describe build go-sample-app-build-1-<uuid>
```{{copy}}

The `Revision` field will contain the corresponding git commit id.

The build is executed in a pod. Each build creates a new pod.
```
kubectl get pods
```{{execute}}

Each phase of the buildpack lifecycle is executed in a separate _init container_, so getting the logs directly from the pod involves appending the pods from each init container in the right order. To facilitate this, kpack includes a special `logs` CLI that makes it easy to get the build log:
```
logs -image go-sample-app -build 1
```{{execute}}

## Port-forward the Argo CD Server

Wait until Argo CD is fully initialized. This may take a few minutes.

```
kubectl rollout status deployment/argocd-server -n argocd
```{{execute}}

In order to expose the Argo CD API endpoint (`argocd-server`) so that you can reach it using the argocd CLI and UI, set up port-forwaring:

```
kubectl port-forward --address 0.0.0.0 svc/argocd-server 8080:80 -n argocd 2>&1 > /dev/null &
```{{execute}}

## Log in using the argocd CLI

First, we need to obtain login credentials. The default admin username is `admin`.
In order to get the default admin password, run:
```
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```{{execute}}

## Log in using the Argo CD UI

Click on the tab titled `Argo CD UI`.
This tab is pointing to localhost:8080, so it should open the Argo CD dashboard UI.
Click the refresh icon at the top of the tab if it does not load automatically.

Alternatively, you can click on the link below and open in a separate tab in your browser:

https://[[HOST_SUBDOMAIN]]-8080-[[KATACODA_HOST]].environments.katacoda.com

Enter the same credentials you used for the CLI.
