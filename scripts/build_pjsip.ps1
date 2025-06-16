# =================================================================================================
# BUILD SCRIPT FOR PJSIP SOLUTION (CALLED BY GITHUB ACTIONS WORKFLOW)
#
# Author: Hugo Castro de Deco, Sufficit
# Collaboration: Gemini AI for Google
# Date: June 16, 2025
# Version: 3
#
# This script builds the PJSIP solution using MSBuild, ensuring the correct configuration
# and platform are applied. It now attempts to find the solution file more robustly
# by including specific solution file names found in the 'sufficit/pjproject' repository.
# =================================================================================================

param (
    [string]$SlnFile # Path to the PJSIP solution file, e.g., pjproject/pjproject-vs14.sln
)

$solutionPath = $SlnFile
$configuration = "Release"
$platform = "x64" # Targeting x64

$msbuildPath = "msbuild.exe"

# --- Robustly find the solution file if the provided SlnFile does not exist ---
if (-not (Test-Path $solutionPath)) {
    Write-Host "Provided solution path '$solutionPath' does not exist. Attempting to find common PJSIP solution files..."

    $possibleSolutionPaths = @(
        "pjproject-vs14.sln", # Added based on the provided image
        "pjproject-vs8.sln",  # Added based on the provided image
        "pjproject.sln",      # Common: Solution in root
        "pjproject-vs2019.sln", # Common: Specific VS version in root
        "pjproject-vs2022.sln", # Common: Specific VS version in root
        "build/vs/pjproject.sln", # Common: VS solution in build/vs
        "build/vs/pjproject-vs2019.sln",
        "build/vs/pjproject-vs2022.sln"
    )

    $found = $false
    foreach ($path in $possibleSolutionPaths) {
        $fullPath = Join-Path -Path $env:GITHUB_WORKSPACE -ChildPath $path
        if (Test-Path $fullPath) {
            $solutionPath = $fullPath
            $found = $true
            Write-Host "Found solution file at: $solutionPath"
            break
        }
    }

    if (-not $found) {
        Write-Host "##[error]Error: Could not find any common PJSIP solution file. Please specify the correct path to the .sln file."
        exit 1
    }
}
# --- End of robust search ---


Write-Host "Building PJSIP solution: $solutionPath"
Write-Host "Configuration: $configuration"
Write-Host "Platform: $platform"

try {
    & $msbuildPath $solutionPath /p:Configuration=$configuration /p:Platform=$platform /m /t:Rebuild
    if ($LASTEXITCODE -ne 0) {
        Write-Host "##[error]MSBuild failed with exit code $LASTEXITCODE."
        exit 1
    }
} catch {
    Write-Host "##[error]An error occurred during MSBuild execution: $($_.Exception.Message)"
    exit 1
}
