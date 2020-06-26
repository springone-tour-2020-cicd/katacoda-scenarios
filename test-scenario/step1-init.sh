#!/bin/bash

# Get user input

##### Set git and hub credentialing so that user is not prompted multiple times to log in
# Do not change the names of the GITHUB env vars
# hub CLI uses GITHUB_USERNAME and GITHUB_TOKEN env vara
# init-foreground and init-background are also using these to configure git CLI
echo "You will use your GitHub account to create/update repos"
echo "Please enter your GitHub username, auth token, and org name (namespace) at the prompts"
echo
read -p "Enter your GitHub username: " GITHUB_USERNAME
git config --global credential.https://example.com.username "${GITHUB_USERNAME}"
mkdir -p /root/init-env \
      && echo -e '#!/bin/bash\necho "${GITHUB_TOKEN}"' > /root/init-env/git-get-token.sh \
      && chmod +x /root/init-env/git-get-token.sh \
      && export GIT_ASKPASS=/root/init-env/git-get-token.sh
read -s -p "Enter your GitHub auth token: " GITHUB_TOKEN
echo ""
read -p "Enter your GitHub org name [${GITHUB_USERNAME}]: " GITHUB_NS
GITHUB_NS="${GITHUB_NS:-$GITHUB_USERNAME}"

##### Set docker credentialing in a simple way consistent with GitHub user experience above
echo "You will use your Docker Hub account to push images"
echo "Please enter your Docker Hub username, auth token, and org name (namespace) at the prompts"
echo ""
read -p "Enter your Docker Hub username: " DOCKERHUB_USERNAME
echo "Please log in to docker CLI at the prompt"
docker login -u "${DOCKERHUB_USERNAME}"
read -p "Enter your Docker Hub org name [${DOCKERHUB_USERNAME}]: " IMG_NS
IMG_NS=${IMG_NS:-$DOCKERHUB_USERNAME}
