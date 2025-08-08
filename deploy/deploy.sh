#!/bin/bash
source variables.env

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
      docker compose up -d || {
        echo "Docker compose not installed or malfunctioning, attempting docker run"
        docker run -d --name artifact -p ${EAR_PORT}:443 -v ${CERTIFICATE_PATH}:/usr/share/nginx/certs/ear-http.crt:z -v ${KEY_PATH}:/usr/share/nginx/certs/ear-http.pem:z -v $(pwd)/nginx.conf:/etc/nginx/conf.d/nginx.conf:z ${IMAGE}
      }
      ;;
    down)
      echo "Running 'docker compose down'..."
      docker compose down || {
        echo "Docker compose not installed or malfunctioning, attempting docker container stop"
        docker container stop artifact
        docker container rm artifact
      }
      ;;
    logs)
      docker logs deploy_artifact_1
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
