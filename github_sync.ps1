# GitHub Sync Script (Sanitized)
# Use GITHUB_TOKEN environment variable.

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

# Mapping files to their absolute local paths
$fileMap = @{
    "docker-compose.yml" = "$PSScriptRoot/docker-compose.yml"
    "Caddyfile"          = "$PSScriptRoot/Caddyfile"
    ".env.example"       = "$PSScriptRoot/.env.example"
    ".gitignore"         = "$PSScriptRoot/.gitignore"
    "README.md"          = "$PSScriptRoot/README.md"
    "github_push.ps1"    = "$PSScriptRoot/github_push.ps1"
    "github_sync.ps1"    = "$PSScriptRoot/github_sync.ps1"
}

# Add dynamic logic for syncing artifacts if needed
$artifactDir = "C:/Users/hamza/.gemini/antigravity/brain/35da7bd3-04dd-4314-a632-c672bc2d0a1e"
if (Test-Path $artifactDir) {
    $fileMap["task.md"] = "$artifactDir/task.md"
    $fileMap["walkthrough.md"] = "$artifactDir/walkthrough.md"
}

foreach ($fileName in $fileMap.Keys) {
    $filePath = $fileMap[$fileName]
    if (Test-Path $filePath) {
        $content = [System.IO.File]::ReadAllBytes($filePath)
        $base64Content = [Convert]::ToBase64String($content)
        
        # Check if file exists to get its SHA (required for updating)
        $sha = ""
        try {
            $existingFile = Invoke-RestMethod -Uri "https://api.github.com/repos/$login/$repoName/contents/$fileName" -Method Get -Headers $headers
            $sha = $existingFile.sha
        } catch {
            # File doesn't exist yet, that's fine
        }
        
        $fileBody = @{
            message = "Update: $fileName (sanitized)"
            content = $base64Content
        }
        if ($sha) { $fileBody.sha = $sha }
        
        $jsonBody = $fileBody | ConvertTo-Json
        
        try {
            $uploadResult = Invoke-RestMethod -Uri "https://api.github.com/repos/$login/$repoName/contents/$fileName" -Method Put -Headers $headers -Body $jsonBody
            Write-Output "Uploaded: ${fileName}"
        } catch {
            Write-Output "Error uploading ${fileName}: $($_.Exception.Message)"
        }
    }
}
