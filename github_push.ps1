# GitHub Push Script (Sanitized)
# Usage: Set the GITHUB_TOKEN environment variable or replace the placeholder below.

$token = $env:GITHUB_TOKEN 
if (-not $token) {
    # $token = "your_token_here" 
    Write-Error "GitHub token not found. Please set `$env:GITHUB_TOKEN` or edit this script."
    exit
}

$repoName = "n8n-gcp-free"
$headers = @{
    "Authorization" = "token $token"
    "Accept"        = "application/vnd.github.v3+json"
}

# Get Authenticated User Login
try {
    $userResult = Invoke-RestMethod -Uri "https://api.github.com/user" -Method Get -Headers $headers
    $login = $userResult.login
    Write-Output "Authenticated as $login"
} catch {
    Write-Output "Error authenticating: $_"
    exit
}

# 1. Create Repository (if it doesn't exist)
$repoBody = @{
    name = $repoName
    private = $true
} | ConvertTo-Json

try {
    $createResult = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $headers -Body $repoBody
    Write-Output "Repository '$repoName' created successfully."
} catch {
    # Repository might already exist
    Write-Output "Repository '$repoName' check complete (it may already exist)."
}

# 2. Upload Files
$files = @("docker-compose.yml", "Caddyfile", ".env.example", ".gitignore", "README.md", "github_push.ps1", "github_sync.ps1")
$basePath = $PSScriptRoot

foreach ($file in $files) {
    $filePath = Join-Path $basePath $file
    if (Test-Path $filePath) {
        $content = [System.IO.File]::ReadAllBytes($filePath)
        $base64Content = [Convert]::ToBase64String($content)
        
        # Check if file exists to get SHA for update
        $sha = ""
        try {
            $existingFile = Invoke-RestMethod -Uri "https://api.github.com/repos/$login/$repoName/contents/$file" -Method Get -Headers $headers
            $sha = $existingFile.sha
        } catch { }

        $fileBody = @{
            message = "Update: $file (sanitized)"
            content = $base64Content
        }
        if ($sha) { $fileBody.sha = $sha }

        try {
            $uploadResult = Invoke-RestMethod -Uri "https://api.github.com/repos/$login/$repoName/contents/$file" -Method Put -Headers $headers -Body ($fileBody | ConvertTo-Json)
            Write-Output "Uploaded: ${file}"
        } catch {
            Write-Output "Error uploading ${file}: $($_.Exception.Message)"
        }
    }
}
