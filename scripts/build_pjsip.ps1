# =================================================================================================
# BUILD SCRIPT FOR PJSIP SOLUTION (CALLED BY GITHUB ACTIONS WORKFLOW)
#
# Author: Hugo Castro de Deco, Sufficit
# Collaboration: Gemini AI for Google
# Date: June 15, 2025
# Version: 1
#
# This script builds the PJSIP solution using MSBuild, ensuring the correct configuration
# and platform are applied.
# =================================================================================================

param (
    [string]$SlnFile # Path to the PJSIP solution file, e.g., pjproject/pjproject-vs14.sln
)

$solutionPath = $SlnFile
$configuration = "Release"
$platform = "x64" # Targeting x64

$msbuildPath = "msbuild.exe"

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
