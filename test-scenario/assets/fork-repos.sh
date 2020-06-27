#!/bin/bash

function fork-and-promote() {
  # Clone and fork repo. Set branch as master.
  hub clone https://github.com/springone-tour-2020-cicd/${REPO_NAME}.git && cd "${REPO_NAME}"
  hub fork --remote-name origin
  git checkout --track origin/$BRANCH
  find . -name *.yaml -exec sed -i "s//springone-tour-2020-cicd//${GITHUB_NS}/g" {} +
  find . -name *.yaml -exec sed -i "s/ springone-tour-2020-cicd/ ${IMG_NS}/g" {} +
  git add -A
  git commit -m "Reset from branch $BRANCH"
  git branch -m master scenario-1-start
  git branch -m $BRANCH master
  git push -f -u origin master
  git push -f origin scenario-1-start
  git branch -d scenario-1-start
  cd ..
}

REPO_NAME="${1}"
BRANCH="${2}"
REPO="${GITHUB_NS}/${REPO_NAME}"

if [[ "${REPO_NAME}" == "" ]]; then
  echo "Expected argument: repo-name. Got [${1}]"
elif [[ "${BRANCH}" == "" ]]; then
  echo "Expected argument: branch-name. Got [${2}]"
elif [[ "${GITHUB_NS}" == "" ]] || [[ "${IMG_NS}" == "" ]]; then
  echo "Missing GitHub/Docker Hub account info. Run 'source set-credentials.sh' first"
else
    git ls-remote https://github.com/${REPO} &>/dev/null
    exit_code=$?
    if [[ $exit_code == 0 ]]; then
      echo "Repository https://github.com/${REPO} exists. Please delete it, and then re-run this script."
      echo "You can delete the repo from the GitHub UI"
    else
      fork-and-promote
    fi
fi
