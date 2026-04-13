# Preflight Windows install script. Downloads a release bundle and installs the
# executable.
#
# Usage:
#   irm https://raw.githubusercontent.com/octokraft/preflight-releases/main/scripts/install.ps1 | iex
#   irm https://raw.githubusercontent.com/octokraft/preflight-releases/main/scripts/install.ps1 | iex -Version 0.1.0

param(
    [string]$Version = "",
    [string]$InstallDir = "",
    [string]$Repo = ""
)

$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($Repo)) {
    $Repo = if ($env:PREFLIGHT_RELEASE_REPO) { $env:PREFLIGHT_RELEASE_REPO } else { "octokraft/preflight-releases" }
}

function Info($msg)  { Write-Host "  → $msg" -ForegroundColor Blue }
function Ok($msg)    { Write-Host "  ✓ $msg" -ForegroundColor Green }
function Err($msg)   { Write-Host "  ✗ $msg" -ForegroundColor Red }
function Fatal($msg) { Err $msg; exit 1 }

function Get-InstallDir {
    if ($InstallDir) { return $InstallDir }
    if ($env:PREFLIGHT_HOME) { return $env:PREFLIGHT_HOME }
    return (Join-Path $env:LOCALAPPDATA "Preflight")
}

function Get-LatestVersion {
    if ($Version) { return $Version }
    Info "Fetching latest version..."
    try {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -Headers @{ "User-Agent" = "preflight-installer" }
        return ($release.tag_name -replace "^v", "")
    } catch {
        Fatal "Failed to fetch latest release metadata: $_"
    }
}

function Do-Install {
    $dir = Get-InstallDir
    $ver = Get-LatestVersion
    New-Item -ItemType Directory -Path $dir -Force | Out-Null

    $arch = if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq "Arm64") { "arm64" } else { "amd64" }
    $archive = "preflight-v${ver}-windows-${arch}.zip"
    $baseUrl = "https://github.com/$Repo/releases/download/v$ver"
    $archivePath = Join-Path ([System.IO.Path]::GetTempPath()) $archive
    $checksumPath = Join-Path ([System.IO.Path]::GetTempPath()) "preflight-checksums.txt"
    $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "preflight-install-$(Get-Random)"

    try {
        Info "Downloading preflight v$ver for windows/$arch..."
        Invoke-WebRequest -Uri "$baseUrl/$archive" -OutFile $archivePath -UseBasicParsing
        Invoke-WebRequest -Uri "$baseUrl/checksums.txt" -OutFile $checksumPath -UseBasicParsing

        $checksumLine = Get-Content $checksumPath | Where-Object { $_ -match [regex]::Escape($archive) }
        if (-not $checksumLine) { Fatal "Checksum not found for $archive" }
        $expected = ($checksumLine -split '\s+')[0].ToLower()
        $actual = (Get-FileHash -Path $archivePath -Algorithm SHA256).Hash.ToLower()
        if ($expected -ne $actual) { Fatal "Checksum mismatch." }

        New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
        Expand-Archive -Path $archivePath -DestinationPath $tmpDir -Force

        Copy-Item (Join-Path $tmpDir "preflight.exe") (Join-Path $dir "preflight.exe") -Force
    } finally {
        Remove-Item -Path $archivePath -ErrorAction SilentlyContinue
        Remove-Item -Path $checksumPath -ErrorAction SilentlyContinue
        Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$dir*") {
        Info "Adding $dir to your user PATH..."
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$dir", "User")
        $env:Path = "$env:Path;$dir"
        Ok "Added to PATH. Restart your terminal for it to take effect."
    }

    Write-Host ""
    Ok "preflight v$ver installed to $dir"
    Write-Host ""
    Info "Next steps:"
    Write-Host "    preflight init --path C:\path\to\repo"
    Write-Host "    preflight start --path C:\path\to\repo"
    Write-Host ""
}

Do-Install
