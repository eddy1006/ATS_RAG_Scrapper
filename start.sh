#!/bin/bash
# Stop immediately if any command fails
set -e

echo "========================================"
echo " 1/3: Building Spring Boot Image        "
echo "========================================"
# Builds the optimized backend image using your local Gradle wrapper
./AtsRagBackend/gradlew -p AtsRagBackend bootBuildImage

echo "========================================"
echo " 2/3: Starting Infrastructure           "
echo "========================================"
# Start the DB and Ollama first so they are ready for the backend
docker compose up -d ats-rag-db ats-rag-ollama

echo "Waiting for Ollama to boot up..."
# Robust health check: Wait until Ollama API is responsive
until curl -s http://localhost:11434/api/tags > /dev/null; do
  echo "Ollama is starting up... waiting 2 seconds."
  sleep 2
done

echo "========================================"
echo " 3/3: Pulling Ollama Model              "
echo "========================================"
# Downloads the embedding model directly into ats_rag_ollama_data
docker exec ats-rag-ollama ollama pull nomic-embed-text

echo "========================================"
echo " Starting Backend and Frontend          "
echo "========================================"
# Builds the frontend and starts the remaining containers
docker compose up -d --build ats-rag-backend ats-rag-frontend

echo "========================================"
echo " Stack is up and running!               "
echo " Frontend: http://localhost:3000        "
echo " Backend : http://localhost:8080        "
echo " Ollama  : http://localhost:11434       "
echo " Database: localhost:5432               "
echo "========================================"