#!/bin/bash

RETRIES=5
WAIT_TIME=5
DOCKER_CMD="$1"
shift
DOCKER_ARGS="$@"

# Function to check if Docker is installed
check_docker_installed() {
  if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker to continue."
    exit 1
  fi
}

# Function to check if Docker daemon is running
check_docker_daemon() {
  if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running or not reachable. Please start Docker."
    exit 1
  fi
}

# Function to check if Docker is logged into any ECR registries
check_registry_login() {
  if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Required to check Docker ECR login."
    exit 1
  fi
  # Retrieve the list of authenticated Docker registries
  local auths
  auths=$(jq -r '.auths | keys[]' ~/.docker/config.json 2>/dev/null)

  if [ -z "$auths" ]; then
    echo "No Docker registries found in Docker configuration. Please login to a registry to continue"
    exit 1
  fi
}

# Function to handle retries for Docker image-related commands
retry_docker_image_command() {
  local cmd="$1"
  local retries="$2"
  local wait_time="$3"

  for ((i=1; i<=retries; i++)); do
    if eval "$cmd"; then
      return 0
    else
      echo "Retrying in $wait_time seconds..."
      sleep "$wait_time"
    fi
  done

  echo "failed after $retries attempts."
  return 1
}

# Function to determine if the command is Docker image-related
is_docker_image_command() {
  local cmd="$1"
  case "$cmd" in
    *push*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

if [ -z "$DOCKER_CMD" ]; then
  echo "Usage: $0 <docker-command> [options...]"
  exit 1
fi

FULL_CMD="docker $DOCKER_CMD $DOCKER_ARGS"

# Execute checks
check_docker_installed
check_docker_daemon
check_registry_login

# Determine if the command is Docker image push related and apply retry logic accordingly
if is_docker_image_command "$FULL_CMD"; then
  retry_docker_image_command "$FULL_CMD" "$RETRIES" "$WAIT_TIME"
else
  eval "$FULL_CMD"
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi
