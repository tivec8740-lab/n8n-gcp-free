# n8n Deployment on GCP Free Tier: Walkthrough

We have successfully deployed a secure, self-hosted n8n instance on the Google Cloud Platform "Always Free" tier. Here is the summary of the work accomplished.

## 🛠️ Infrastructure & Services
*   **GCP VM**: `e2-micro` in `us-central1-a` (2 vCPU, 1 GB RAM).
*   **Storage**: 30 GB Standard Persistent Disk (Ubuntu 22.04 LTS).
*   **Reverse Proxy**: [Caddy](https://caddyserver.com/) for automatic SSL/HTTPS.
*   **DNS**: Linked to `tivec8740.duckdns.org`.

## 📁 GitHub Integration
We configured a **private repository** to store your n8n configuration.
*   **Repo Name**: `n8n-gcp-free`
*   **MCP Configured**: Antigravity is now linked to your GitHub account using your PAT.
*   **Push Script**: Used a custom REST API script to upload files since `git` was unavailable on the local host.

## 🚀 Deployment Steps Taken
1.  **Local Workspace Initialization**: Created `docker-compose.yml`, `Caddyfile`, `.env.example`, and `.gitignore`.
2.  **VM Creation**: Used the browser assistant to configure the VM in your GCP Console.
3.  **Deployment Script**: Executed a one-liner to install Docker, enable **2GB Swap** (essential for the 1GB RAM machine), and clone the repo.
4.  **Troubleshooting**:
    > [!IMPORTANT]
    > **Permission Fix**: Resolved a **502 Bad Gateway** by correcting folder ownership (`chown -R 1000:1000`) for the n8n data directory on the VM.

## ✅ Verification
The n8n setup screen is now live and confirmed!

![n8n Setup Screenshot](file:///C:/Users/hamza/.gemini/antigravity/brain/8b94f29e-b762-4f36-973d-b404c1f04746/n8n_setup_screen_1775061621648.png)

### Access URL
👉 **[https://tivec8740.duckdns.org](https://tivec8740.duckdns.org)**

## 💡 Maintenance Tips
*   **Low RAM**: Because this is a Free Tier instance, avoid running more than 2-3 complex workflows simultaneously.
*   **Pruning**: I've enabled automatic pruning of execution data (72 hours max) to keep the SQLite database small and fast.
*   **Updates**: To update n8n, simply SSH into the VM and run:
    ```bash
    cd n8n-gcp-free && sudo docker-compose pull && sudo docker-compose up -d
    ```
