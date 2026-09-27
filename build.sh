#!/bin/bash
# Stop immediately if any command fails
set -e

echo "========================================"
echo " Loading Configuration                  "
echo "========================================"
if [ -f .env ]; then
  # Export variables from .env so the shell can use them
  export $(grep -v '^#' .env | xargs)
else
  echo "Error: .env file not found!"
  exit 1
fi

echo "========================================"
echo " Authenticating with Docker Hub         "
echo "========================================"
# Securely pipes the token into docker login using the parameterized username
echo "$DOCKER_HUB_PAT" | docker login -u "$DOCKER_USERNAME" --password-stdin

echo "========================================"
echo " 1/2: Building & Pushing Backend        "
echo "========================================"
./AtsRagBackend/gradlew -p AtsRagBackend bootBuildImage --imageName="${DOCKER_USERNAME}/ats-rag-backend:latest"
docker push "${DOCKER_USERNAME}/ats-rag-backend:latest"

echo "========================================"
echo " 2/2: Building & Pushing Frontend       "
echo "========================================"
docker build -t "${DOCKER_USERNAME}/ats-rag-frontend:latest" ./ai-resume-matcher-frontend
docker push "${DOCKER_USERNAME}/ats-rag-frontend:latest"

echo "========================================"
echo " Images successfully pushed to Docker Hub!"
echo "========================================"