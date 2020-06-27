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

RESET_FONT="\033[0m"
BOLD="\033[1m"
RED="\033[0;31m"

if [[ "${REPO_NAME}" == "" ]]; then
  echo -e "${BOLD}${RED}Expected argument: repo-name. Got [${1}]${RESET_FONT}"
elif [[ "${BRANCH}" == "" ]]; then
  echo -e "${BOLD}${RED}Expected argument: branch-name. Got [${2}]${RESET_FONT}"
elif [[ "${GITHUB_NS}" == "" ]] || [[ "${IMG_NS}" == "" ]]; then
  echo -e "${BOLD}${RED}Missing GitHub/Docker Hub account info. Run 'source set-credentials.sh' first.${RESET_FONT}"
else
    git ls-remote https://github.com/${REPO} &>/dev/null
    exit_code=$?
    if [[ $exit_code == 0 ]]; then
      echo -e "${BOLD}${RED}Repository https://github.com/${REPO} exists. Please delete it, and then re-run this script.${RESET_FONT}"
      echo -e "${BOLD}${RED}You can delete the repo from the GitHub UI.${RESET_FONT}"
    else
      fork-and-promote
    fi
fi
