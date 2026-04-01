# n8n GCP Free Tier Setup

This repository contains the configuration to deploy [n8n](https://n8n.io/) on the Google Cloud Platform (GCP) "Always Free" tier.

## Project Structure
- `docker-compose.yml`: Main deployment file.
- `Caddyfile`: Reverse proxy for automatic SSL with [Caddy](https://caddyserver.com/).
- `.env.example`: Template for environment variables.
- `.gitignore`: Files excluded from the repository.

## Quick Start
1.  **Clone this repository** onto your VM.
2.  **Copy `.env.example`** to `.env` and update the values.
3.  **Run** `docker compose up -d`.

## GCP Free Tier Specs
- **Machine**: `e2-micro` (2 vCPUs, 1 GB RAM)
- **Disk**: 30 GB Standard Persistent Disk
- **Region**: `us-central1`, `us-west1`, or `us-east1`
