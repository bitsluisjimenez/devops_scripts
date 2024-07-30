#!/bin/bash

# Load environment variables from env_vars file
source ./env_vars

# Define variables
OUTPUT_FILE="branches_info.txt"
CURRENT_DATE=$(date -u +%s)

# Function to get branch details
get_branch_details() {
  BRANCH_NAME=$1
  COMMIT_DETAILS=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/repos/$GITHUB_USERNAME/$REPOSITORY_NAME/commits/$BRANCH_NAME | jq -r '[.commit.committer.date, .commit.committer.name] | @tsv')
  COMMIT_DATE=$(echo "$COMMIT_DETAILS" | cut -f1)
  COMMITTER_NAME=$(echo "$COMMIT_DETAILS" | cut -f2)
  COMMIT_TIMESTAMP=$(date -u -d "$COMMIT_DATE" +%s)
  TIME_DIFF=$(( ($CURRENT_DATE - $COMMIT_TIMESTAMP) / 86400 ))

  echo -e "$BRANCH_NAME\t$COMMIT_DATE\t$COMMITTER_NAME" >> $OUTPUT_FILE

  if [[ $TIME_DIFF -gt 2 ]]; then
    delete_branch $BRANCH_NAME
  fi
}

# Function to delete a branch
delete_branch() {
  BRANCH_NAME=$1
  PROTECTED=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/repos/$GITHUB_USERNAME/$REPOSITORY_NAME/branches/$BRANCH_NAME | jq '.protected')
  if [ "$PROTECTED" == "false" ]; then
    curl -s -X DELETE -H "Authorization: token $TOKEN" https://api.github.com/repos/$GITHUB_USERNAME/$REPOSITORY_NAME/git/refs/heads/$BRANCH_NAME
    echo "Deleted branch: $BRANCH_NAME"
  else
    echo "Branch $BRANCH_NAME is protected, skipping deletion."
  fi
}

# Main script
echo -e "Branch Name\tLast Commit Date\tCommitter Name" > $OUTPUT_FILE

BRANCHES=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/repos/$GITHUB_USERNAME/$REPOSITORY_NAME/branches | jq -r '.[].name')
for BRANCH in $BRANCHES; do
  get_branch_details $BRANCH
done

echo "Branch information written to $OUTPUT_FILE"
