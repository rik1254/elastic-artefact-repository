#!/bin/bash
source variables.env

# Function to display the menu
function display_menu() {
  echo "Choose an action:"
  echo "up - Starts the container, can also be used to restart the container if a new image has been defined."
  echo "down - Stops the container."
  echo "logs - Prints the logs of the container."
  echo "exit - Terminates this script."
}

# Initialize choice variable
choice=""

# Loop until the user enters a valid choice
while [[ "$choice" != "up" && "$choice" != "down" ]]; do
  display_menu
  read choice
  # Check the user's input
  case $choice in
    up)
      echo "Running 'docker compose up -d'..."
      docker compose up -d
      ;;
    down)
      echo "Running 'docker compose down'..."
      docker compose down
      ;;
    logs)
      docker logs elastic-artefact-repository_artifact_1
      exit 0
      ;;
    exit)
      exit 0
      ;;
    *)
      echo "Invalid choice. Please enter one of the available options."
      choice="" # Reset choice to ensure the loop continues
      ;;
  esac
done
