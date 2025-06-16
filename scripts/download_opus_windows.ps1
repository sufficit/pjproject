# =================================================================================================
# DOWNLOAD OPUS SCRIPT FOR WINDOWS (CALLED BY GITHUB ACTIONS WORKFLOW)
#
# Author: Hugo Castro de Deco, Sufficit
# Collaboration: Gemini AI for Google
# Date: June 15, 2025
# Version: 1
#
# This script downloads the latest pre-compiled Opus library for Windows from a GitHub Release,
# extracts it, and copies the necessary .lib and .h files to the PJSIP build environment.
# =================================================================================================

$REPO_OWNER="sufficit"
$REPO_NAME="opus"
$ARTIFACT_PREFIX="opus-windows-x64"
$ARTIFACT_EXT=".zip"

Write-Host "Fetching latest release tag from https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
$LATEST_RELEASE_DATA = Invoke-RestMethod -Uri "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" -Headers @{Authorization = "token $env:GITHUB_TOKEN"} -ErrorAction Stop

$LATEST_RELEASE_TAG = $LATEST_RELEASE_DATA.tag_name
if (-not $LATEST_RELEASE_TAG) {
  Write-Host "##[error]Error: Could not find latest release tag for ${REPO_OWNER}/${REPO_NAME}"
  exit 1
}
Write-Host "Found latest Opus release tag: $LATEST_RELEASE_TAG"

$OPUS_BUILD_VERSION = ($LATEST_RELEASE_TAG -replace "build-", "") # Assumes tag is 'build-YYYYMMDD-HHMMSS'
$EXPECTED_ARTIFACT_NAME = "${ARTIFACT_PREFIX}-${OPUS_BUILD_VERSION}${ARTIFACT_EXT}"
Write-Host "Expected artifact name: $EXPECTED_ARTIFACT_NAME"

$DOWNLOAD_URL = $LATEST_RELEASE_DATA.assets | Where-Object { $_.name -eq $EXPECTED_ARTIFACT_NAME } | Select-Object -ExpandProperty browser_download_url
if (-not $DOWNLOAD_URL) {
  Write-Host "##[error]Error: Could not find download URL for artifact $EXPECTED_ARTIFACT_NAME in release $LATEST_RELEASE_TAG"
  exit 1
}
Write-Host "Downloading Opus artifact from: $DOWNLOAD_URL"

New-Item -ItemType Directory -Path "external_libs/opus_temp" -Force
$zipPath = Join-Path -Path "external_libs/opus_temp" -ChildPath $EXPECTED_ARTIFACT_NAME

Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $zipPath

Write-Host "Extracting $zipPath to external_libs/opus_temp/"
Expand-Archive -Path $zipPath -DestinationPath "external_libs/opus_temp/" -Force

# Copy opus.lib to PJSIP's lib directory
$pjsipLibDir = "lib"
New-Item -ItemType Directory -Path $pjsipLibDir -Force

$foundOpusLib = Get-ChildItem -Path "external_libs/opus_temp" -Filter "opus.lib" -Recurse | Select-Object -First 1

if ($foundOpusLib) {
    Copy-Item -Path $foundOpusLib.FullName -Destination $pjsipLibDir
    Write-Host "Copied opus.lib from $($foundOpusLib.FullName) to $pjsipLibDir"
} else {
    Write-Host "##[error]Error: opus.lib not found within the extracted contents of the Opus release. Please check the structure."
    exit 1
}

# Copy Opus headers to PJSIP's pjlib/include/pj/opus directory
$pjIncludeOpusDir = "pjlib/include/pj/opus"
New-Item -ItemType Directory -Path $pjIncludeOpusDir -Force

$foundOpusHeadersPath = Get-ChildItem -Path "external_libs/opus_temp" -Filter "opus.h" -Recurse | Select-Object -ExpandProperty DirectoryName | Select-Object -First 1

if ($foundOpusHeadersPath) {
    Copy-Item -Path (Join-Path -Path $foundOpusHeadersPath -ChildPath "*.h") -Destination $pjIncludeOpusDir
    Write-Host "Copied Opus headers from $($foundOpusHeadersPath) to $pjIncludeOpusDir"
} else {
    Write-Host "##[warning]Warning: Opus 'opus.h' header file not found within extracted contents. Headers might be missing."
}
