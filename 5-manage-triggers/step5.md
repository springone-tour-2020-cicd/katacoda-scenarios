# Add the promotion pipeline

Objective:
Now that you've sorted out the ops repository, you can start creating the promotion pipeline.

In this step, you will:
- Create a new `Pipeline` specification

## Introduce the new Pipeline

You're going to use the `git-clone`, as well as the newly created `ops-dev` Tasks.

```
cat <<EOF >ops-dev-pipeline.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: ops-dev-pipeline
spec:
  params:
    - name: repo-url
      type: string
      description: The Git repository URL to clone from.
    - name: revision
      type: string
      description: The Git revision to clone.
    - name: tag
      type: string
      description: The new image tag.
    - name: github-token-secret
      type: string
      description: Name of the secret holding the github-token.
    - name: github-token-secret-key
      description: Name of the secret key holding the github-token.
  workspaces:
    - name: shared-workspace
      description: This workspace will receive the cloned git repo and be passed to the next Task.
  tasks:
    - name: fetch-repository
      taskRef:
        name: git-clone
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: url
          value: \$(params.repo-url)
        - name: revision
          value: \$(params.revision)
        - name: deleteExisting
          value: "true"
    - name: ops-dev
      taskRef:
        name: ops-dev
      runAfter:
        - fetch-repository
      workspaces:
        - name: source
          workspace: shared-workspace
      params:
        - name: GITHUB_TOKEN_SECRET
          value: \$(params.github-token-secret)
        - name: GITHUB_TOKEN_SECRET_KEY
          value: \$(params.github-token-secret-key)
        - name: TAG
          value: \$(params.tag)
EOF
```{{execute}}

Take a look at the entire `Pipeline`, and apply it to the cluster.

```
yq r -C ops-dev-pipeline.yaml
kubectl apply -f ops-dev-pipeline.yaml
```{{execute}}

