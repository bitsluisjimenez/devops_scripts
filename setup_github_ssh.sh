#!/bin/bash

# Load environment variables from env_vars file
source ./env_vars

# Define variables
ALGORITHM="ed25519"

# Generate SSH key pair
ssh-keygen -t "$ALGORITHM" -C "$EMAIL" -f ~/.ssh/id_"$ALGORITHM"

# Start the SSH agent in the background
eval "$(ssh-agent -s)"

# Add your SSH private key to the SSH agent
ssh-add ~/.ssh/id_"$ALGORITHM"

# Copy the SSH key to your clipboard (for manual step)
echo "Copy the following SSH key to your GitHub account:"
cat ~/.ssh/id_"$ALGORITHM".pub
echo "Go to GitHub > Settings > SSH and GPG keys > New SSH key, and paste the key."

read -p "Press Enter after you've added the SSH key to your GitHub account..."

## The `-d` test command option see if FILE not exists
if [ ! -d "$REPO_PATH" ]; then
  echo "$REPO_PATH does not exist."
  # create folder to your repository
  mkdir "$REPO_PATH"
fi

# Navigate to your repository
cd "$REPO_PATH"

# Update the remote URL to use SSH
git remote set-url origin git@github.com:$GITHUB_USERNAME/$REPOSITORY_NAME.git

# Test the SSH connection
ssh -T git@github.com

echo "SSH connection to GitHub has been set up successfully!"
