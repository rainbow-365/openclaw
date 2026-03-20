param(
    [string]$RequestId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$rootDir = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $rootDir

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "docker is not installed or not on PATH."
}

$null = docker compose version

$token = (docker compose exec -T openclaw-gateway printenv OPENCLAW_GATEWAY_TOKEN 2>$null | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($token)) {
    throw "OPENCLAW_GATEWAY_TOKEN is not set in the openclaw-gateway container."
}

$args = @(
    "compose", "exec", "-T", "openclaw-gateway",
    "node", "dist/index.js", "devices", "approve"
)

if ([string]::IsNullOrWhiteSpace($RequestId)) {
    Write-Host "Approving latest pending dashboard pairing request..."
    $args += "--latest"
} else {
    Write-Host "Approving dashboard pairing request: $RequestId"
    $args += $RequestId
}

$args += @(
    "--url", "ws://127.0.0.1:18789",
    "--token", $token,
    "--json"
)

& docker @args

Write-Host ""
Write-Host "Done. Refresh the dashboard browser tab."
