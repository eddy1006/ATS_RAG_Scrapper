# ATS RAG Application Stack

This project is a full-stack AI-powered Resume Applicant Tracking System (ATS) using Retrieval-Augmented Generation (RAG). It features a Spring Boot backend (Java 21), a React frontend, a PostgreSQL database extended with `pgvector`, and a local instance of Ollama for AI embeddings and generation.

This guide explains how to configure and run the application locally using Docker.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

* [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine with Docker Compose)

## 🚀 How to Run the Application

If you just want to run the application using pre-built images, follow these steps:

### 1. Set Up Environment Variables

Create a file named `.env` in the root directory of the project (the same folder as the `docker-compose.yml` file) and add the following configuration.

*(Note: Replace the placeholder API keys and passwords with your actual values.)*

```env
# ------------------------------
# Database Configuration
# ------------------------------
DB_NAME=ats_db
DB_USERNAME=postgres
DB_PASSWORD=your_secure_password_here

# ------------------------------
# External AI & API Keys
# ------------------------------
APIFY_API_TOKEN=your_apify_token_here
OLLAMA_API_KEY=your_ollama_key_here

# ------------------------------
# Docker Hub Namespace
# ------------------------------
# Set this to the repository owner's username to pull pre-built images
DOCKER_USERNAME=eddy1006
```

### 2. Start the Application

Open your terminal in the project root directory and run the following command to start all services in detached mode (background):

```bash
docker compose up -d
```

Docker will automatically pull the necessary images and start the containers.

### 3. Access the Application

Once the containers are running, you can access the services at the following local URLs:

* **React Frontend:** [http://localhost:3000](http://localhost:3000)
* **Spring Boot Backend (API):** [http://localhost:8080](http://localhost:8080)
* **Ollama Server:** [http://localhost:11434](http://localhost:11434)
* **PostgreSQL DB:** `localhost:5432` (Connect via tools like DBeaver or pgAdmin using your `.env` credentials)

### 4. Stop the Application

To safely stop the application and spin down the containers without deleting your database data, run:

```bash
docker compose down
```

*(If you want to completely wipe the database and start fresh, run `docker compose down -v` to destroy the volumes).*

## 🛠️ For Contributors: Building and Pushing Images

If you are developing the application and want to build new Docker images from the source code and push them to Docker Hub, use the automated build script.

### 1. Update the `.env` file

Add your Personal Access Token (PAT) to the `.env` file for authentication.

```env
# Add these to your existing .env file
DOCKER_USERNAME=your_docker_hub_username
DOCKER_HUB_PAT=your_docker_hub_personal_access_token
```

*You can generate a PAT in your Docker Hub account under **Account settings > Security > New Access Token**.*

### 2. Run the Build Script

Ensure the script is executable, then run it. This will securely log you into Docker Hub, build the Spring Boot and React images using your local cache, and push them to your Docker Hub repository.

```bash
# Make the script executable (only needed once)
chmod +x build.sh

# Run the build and push process
./build.sh
```

### 3. Restart the Local Stack

After pushing your new images, update your running containers with:

```bash
docker compose pull
docker compose up -d
```# ATS_RAG_Scrapper