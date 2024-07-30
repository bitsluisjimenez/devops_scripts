#!/bin/bash

# Load environment variables from env_vars file
source ./env_vars

# Function to validate title
validate_title() {
  TITLE=$1
  if [[ ! $TITLE =~ ^(\b\w+\b\s+){4,}\#\d+$ ]]; then
    echo "El título debe contener al menos 5 palabras y finalizar con el símbolo numeral seguido de un número (Ejemplo: 'Este es un título válido #1234')."
    return 1
  fi
  return 0
}

# Function to validate description
validate_description() {
  DESCRIPTION=$1
  WORD_COUNT=$(echo $DESCRIPTION | wc -w)
  if [ $WORD_COUNT -lt 10 ]; then
    echo "La descripción debe contener al menos 10 palabras."
    return 1
  fi
  return 0
}

# Function to create pull request
create_pull_request() {
  TITLE=$1
  HEAD=$2
  BASE=$3
  DESCRIPTION=$4

  RESPONSE=$(curl -s -X POST -H "Authorization: token $TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/$GITHUB_USERNAME/$REPOSITORY_NAME/pulls -d @- <<EOF
{
  "title": "$TITLE",
  "head": "$HEAD",
  "base": "$BASE",
  "body": "$DESCRIPTION"
}
EOF
)

  PR_URL=$(echo $RESPONSE | jq -r '.html_url')
  if [ "$PR_URL" == "null" ]; then
    echo "Error creando el Pull Request: $(echo $RESPONSE | jq -r '.message')"
  else
    echo "Pull Request creado exitosamente: $PR_URL"
  fi
}

# Input information
read -p "Ingrese el título del Pull Request: " TITLE
while ! validate_title "$TITLE"; do
  read -p "Ingrese el título del Pull Request: " TITLE
done

read -p "Ingrese la rama de origen: " HEAD
read -p "Ingrese la rama de destino: " BASE

read -p "Ingrese la descripción del Pull Request: " DESCRIPTION
while ! validate_description "$DESCRIPTION"; do
  read -p "Ingrese la descripción del Pull Request: " DESCRIPTION
done

# Create Pull Request
create_pull_request "$TITLE" "$HEAD" "$BASE" "$DESCRIPTION"
