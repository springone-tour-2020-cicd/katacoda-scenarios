#!/bin/bash

function fork-and-promote() {
  # Clone and fork repo. Set branch as master.
  REPO_NAME="${1}"
  rm -rf ${REPO_NAME}
  REPO="${GITHUB_NS}/${REPO_NAME}"
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

if [[ "${GITHUB_NS}" == "" ]] || [[ "${IMG_NS}" == "" ]]; then
  echo "Missing GitHub account information. Please run set-credentials.sh script first"
elif [ $(git ls-remote https://github.com/${REPO} &>/dev/null) -ne 0 ]; then
  echo "Repository exists. Please delete and re-run this script. [Repository: https://github.com/${REPO}]"
  echo "You can delete the repo from the GitHub UI, or using hub at the command line [hub delete ${REPO}]"
elif [[ "${BRANCH}" == "" ]]; then
  echo "Expected argument: branch-name. Got []"
else
  # app repo
  REPO_NAME=go-sample-app
  fork-and-promote $BRANCH
  # ops repo
  REPO_NAME=go-sample-app-ops
  fork-and-promote $BRANCH
fi