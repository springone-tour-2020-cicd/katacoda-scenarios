# Add a Deployment Pipeline

Objective:
Assuming the `PipelineRun` finished successfully, you now have a new image in your Docker Hub account.
That image's reference however needs to be manually updated in the Kustomize files.
Let's make a pipeline for this purpose as well.

In this step, you will:
- Trigger the new pipeline by reacting to Docker Hub changes

## Introduce the new Trigger

Whenever a new image gets pushed to Docker Hub, our pipeline needs to run.
Create a new

```
cat <<EOF >>bump-dev-pipeline.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: tekton-go-pipeline
spec:
  params:
    - name: repo-url
      type: string
      description: The git repository URL to clone from.
    - name: branch-name
      type: string
      description: The git branch to clone.
    - name: tag
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
          value: $(params.repo-url)
        - name: revision
          value: $(params.branch-name)
    - name: bump-dev
      taskRef:
        name: bump-dev
      runAfter:
        - fetch-repository
      workspaces:
        - name: source
          workspace: shared-workspace
      params:
        - name: GITHUB_TOKEN_SECRET
          value: $(params.github-token-secret)
        - name: GITHUB_TOKEN_SECRET_KEY
          value: $(params.github-token-secret-key)
        - name: TAG
          value: $(params.tag)
EOF
```

Take a look at the entire `Pipeline`, and apply it to the cluster.

```
yq r -C bump-dev-pipeline.yaml
tkn pipeline create -f bump-dev-pipeline.yaml
```{{execute}}
