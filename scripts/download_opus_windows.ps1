# =================================================================================================
# DOWNLOAD OPUS SCRIPT FOR WINDOWS (CALLED BY GITHUB ACTIONS WORKFLOW)
#
# Author: Hugo Castro de Deco, Sufficit
# Collaboration: Gemini AI for Google
# Date: June 16, 2025
# Version: 4
#
# This script downloads the latest pre-compiled Opus library for Windows from a GitHub Release,
# extracts it, and copies the necessary .lib and .h files to the PJSIP build environment.
#
# Changes:
#   - Improved robustness for finding and copying Opus header files, searching recursively and
#     also explicitly looking in common 'include' subdirectories.
#   - Added Set-StrictMode and ErrorActionPreference for better error handling.
#   - Added cleanup of the temporary download directory (external_libs/opus_temp).
# =================================================================================================

# Enforce stricter parsing and error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$REPO_OWNER="sufficit"
$REPO_NAME="opus"
$ARTIFACT_PREFIX="opus-windows-x64"
$ARTIFACT_EXT=".zip"

Write-Host "Fetching latest release tag from https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
$LATEST_RELEASE_DATA = Invoke-RestMethod -Uri "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" -Headers @{Authorization = "token $env:GITHUB_TOKEN"} -ErrorAction Stop

$LATEST_RELEASE_TAG = $LATEST_RELEASE_DATA.tag_name
if (-not $LATEST_RELEASE_TAG) {
  Write-Error "Could not find latest release tag for ${REPO_OWNER}/${REPO_NAME}"
  exit 1
}
Write-Host "Found latest Opus release tag: $LATEST_RELEASE_TAG"

$OPUS_BUILD_VERSION = ($LATEST_RELEASE_TAG -replace "build-", "") # Assumes tag is 'build-YYYYMMDD-HHMMSS'
$EXPECTED_ARTIFACT_NAME = "${ARTIFACT_PREFIX}-${OPUS_BUILD_VERSION}${ARTIFACT_EXT}"
Write-Host "Expected artifact name: $EXPECTED_ARTIFACT_NAME"

$DOWNLOAD_URL = $LATEST_RELEASE_DATA.assets | Where-Object { $_.name -eq $EXPECTED_ARTIFACT_NAME } | Select-Object -ExpandProperty browser_download_url
if (-not $DOWNLOAD_URL) {
  Write-Error "Could not find download URL for artifact $EXPECTED_ARTIFACT_NAME in release $LATEST_RELEASE_TAG"
  exit 1
}
Write-Host "Downloading Opus artifact from: $DOWNLOAD_URL"

$tempDownloadDir = "external_libs/opus_temp"
New-Item -ItemType Directory -Path $tempDownloadDir -Force
$zipPath = Join-Path -Path $tempDownloadDir -ChildPath $EXPECTED_ARTIFACT_NAME

Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $zipPath

Write-Host "Extracting $zipPath to $tempDownloadDir/"
Expand-Archive -Path $zipPath -DestinationPath "$tempDownloadDir/" -Force # Ensure trailing slash for destination

# Debugging: List contents after extraction to help understand the structure
Write-Host "--- Contents of $tempDownloadDir after extraction (for debugging) ---"
Get-ChildItem -Path $tempDownloadDir -Recurse | Select-Object FullName
Write-Host "-----------------------------------------------------------------"

# Copy opus.lib to PJSIP's lib directory
$pjsipLibDir = "lib"
New-Item -ItemType Directory -Path $pjsipLibDir -Force

$foundOpusLib = Get-ChildItem -Path "$tempDownloadDir" -Filter "opus.lib" -Recurse | Select-Object -First 1

if ($null -ne $foundOpusLib) {
    Copy-Item -Path $foundOpusLib.FullName -Destination $pjsipLibDir
    Write-Host "Copied opus.lib from $($foundOpusLib.FullName) to $pjsipLibDir"
} else {
    Write-Error "opus.lib not found within the extracted contents of the Opus release ($tempDownloadDir). Please check the artifact structure."
    exit 1
}

# Copy Opus headers to PJSIP's pjlib/include/pj/opus directory
$pjIncludeOpusDir = "pjlib/include/pj/opus"
New-Item -ItemType Directory -Path $pjIncludeOpusDir -Force

$foundOpusHeaders = @()

# First, try a broad recursive search
Write-Host "Attempting broad recursive search for Opus headers (*.h) in '$tempDownloadDir'..."
$foundOpusHeaders = Get-ChildItem -Path "$tempDownloadDir" -Filter "*.h" -Recurse

# If no headers found, try more specific common include paths
if ($null -eq $foundOpusHeaders -or $foundOpusHeaders.Count -eq 0) {
    Write-Host "Broad search yielded no headers. Trying specific 'include' subdirectories..."
    $possibleIncludePaths = @(
        Join-Path -Path $tempDownloadDir -ChildPath "include"
        Join-Path -Path $tempDownloadDir -ChildPath "build-windows\include"
        Join-Path -Path $tempDownloadDir -ChildPath "build-windows\Release\include" # Add if it's very specific
        Join-Path -Path $tempDownloadDir -ChildPath "src\include" # Sometimes headers are in src/include
    )

    foreach ($includePath in $possibleIncludePaths) {
        if (Test-Path $includePath -PathType Container) {
            Write-Host "Searching for headers in specific path: '$includePath'..."
            $headersInSpecificPath = Get-ChildItem -Path $includePath -Filter "*.h" -Recurse
            if ($null -ne $headersInSpecificPath -and $headersInSpecificPath.Count -gt 0) {
                $foundOpusHeaders += $headersInSpecificPath
                Write-Host "Found $($headersInSpecificPath.Count) headers in '$includePath'."
                # Break if headers are found in one of the specific paths to avoid duplicates/unnecessary searches
                break
            }
        }
    }
}


if ($null -ne $foundOpusHeaders -and $foundOpusHeaders.Count -gt 0) {
    foreach ($headerFile in $foundOpusHeaders) {
        Copy-Item -Path $headerFile.FullName -Destination $pjIncludeOpusDir
        Write-Host "Copied header: $($headerFile.FullName) to $pjIncludeOpusDir"
    }
} else {
    Write-Warning "No Opus header files (*.h) found within extracted contents ($tempDownloadDir) or common include paths. Headers might be missing."
}

# Clean up the temporary download directory
if (Test-Path $tempDownloadDir) {
    Write-Host "Cleaning up temporary directory: $tempDownloadDir"
    Remove-Item -Path $tempDownloadDir -Recurse -Force
}

Write-Host "Opus library and headers successfully processed."
