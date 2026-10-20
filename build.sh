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
# Extract version natively using the Gradle JVM task
BACKEND_VERSION=$(./AtsRagBackend/gradlew -p AtsRagBackend -q printProjectVersion)
if [ -z "$BACKEND_VERSION" ]; then BACKEND_VERSION="latest"; fi

echo "Backend Version detected: $BACKEND_VERSION"

# Build with the specific version tag
./AtsRagBackend/gradlew -p AtsRagBackend bootBuildImage --imageName="${DOCKER_USERNAME}/ats-rag-backend:${BACKEND_VERSION}"

# Tag as latest explicitly for the push
docker tag "${DOCKER_USERNAME}/ats-rag-backend:${BACKEND_VERSION}" "${DOCKER_USERNAME}/ats-rag-backend:latest"

# Push both tags
docker push "${DOCKER_USERNAME}/ats-rag-backend:${BACKEND_VERSION}"
docker push "${DOCKER_USERNAME}/ats-rag-backend:latest"

echo "========================================"
echo " 2/2: Building & Pushing Frontend       "
echo "========================================"
# Extract version natively using Node.js evaluation
FRONTEND_VERSION=$(node -p "require('./ai-resume-matcher-frontend/package.json').version")
if [ -z "$FRONTEND_VERSION" ]; then FRONTEND_VERSION="latest"; fi

echo "Frontend Version detected: $FRONTEND_VERSION"

# Build and apply both tags simultaneously
docker build -t "${DOCKER_USERNAME}/ats-rag-frontend:${FRONTEND_VERSION}" -t "${DOCKER_USERNAME}/ats-rag-frontend:latest" ./ai-resume-matcher-frontend

# Push both tags
docker push "${DOCKER_USERNAME}/ats-rag-frontend:${FRONTEND_VERSION}"
docker push "${DOCKER_USERNAME}/ats-rag-frontend:latest"

echo "========================================"
echo " Images successfully pushed to Docker Hub!"
echo "========================================"