#!/bin/bash

# Define your email and GitHub repository details
EMAIL="your_email@example.com"
REPO_PATH="/path/to/your/repository"
GITHUB_USERNAME="your_github_username"
REPOSITORY_NAME="your_repository_name"

# Generate SSH key pair
ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/id_ed25519 -N ""

# Start the SSH agent in the background
eval "$(ssh-agent -s)"

# Add your SSH private key to the SSH agent
ssh-add ~/.ssh/id_ed25519

# Copy the SSH key to your clipboard (for manual step)
echo "Copy the following SSH key to your GitHub account:"
cat ~/.ssh/id_ed25519.pub
echo "Go to GitHub > Settings > SSH and GPG keys > New SSH key, and paste the key."

read -p "Press Enter after you've added the SSH key to your GitHub account..."

# Navigate to your repository
cd "$REPO_PATH"

# Update the remote URL to use SSH
git remote set-url origin git@github.com:$GITHUB_USERNAME/$REPOSITORY_NAME.git

# Test the SSH connection
ssh -T git@github.com

echo "SSH connection to GitHub has been set up successfully!"
