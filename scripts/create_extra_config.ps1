# =================================================================================================
# CREATE EXTRA PJSIP CONFIG FILE (CALLED BY GITHUB ACTIONS WORKFLOW)
#
# Author: Hugo Castro de Deco, Sufficit
# Collaboration: Gemini AI for Google
# Date: June 16, 2025
# Version: 2
#
# This script creates an additional configuration file for PJSIP, containing extra
# define statements or overrides.
#
# Changes:
#   - Changed from using here-string to Add-Content for more reliable file generation
#     to avoid C preprocessor errors.
# =================================================================================================

$outputPath = "pjlib/include/pj/pjsip_extra_defines.h"
New-Item -ItemType File -Path $outputPath -Force # Create or overwrite the file

# Write content line by line to ensure correct formatting
Add-Content -Path $outputPath -Value "// =================================================================================================" -Encoding UTF8
Add-Content -Path $outputPath -Value "// PJSIP EXTRA DEFINITIONS FILE" -Encoding UTF8
Add-Content -Path $outputPath -Value "//" -Encoding UTF8
Add-Content -Path $outputPath -Value "// This file contains additional, optional define statements for PJSIP." -Encoding UTF8
Add-Content -Path $outputPath -Value "// It is intended to be included by config_site.h." -Encoding UTF8
Add-Content -Path $outputPath -Value "// =================================================================================================" -Encoding UTF8
Add-Content -Path $outputPath -Value "" -Encoding UTF8 # Empty line
Add-Content -Path $outputPath -Value "#define PJMEDIA_HAS_G729_CODEC 0 // Example: Disable G.729 if not needed or licensed" -Encoding UTF8
Add-Content -Path $outputPath -Value "#define PJSIP_MAX_CALLS 4       // Example: Set maximum number of concurrent calls" -Encoding UTF8
Add-Content -Path $outputPath -Value "#define PJ_LOG_MAX_LEVEL 5      // Example: Set maximum log level (0=none, 6=verbose)" -Encoding UTF8
Add-Content -Path $outputPath -Value "" -Encoding UTF8 # Empty line
Add-Content -Path $outputPath -Value "// Add any other specific defines here" -Encoding UTF8

Write-Host "Created $outputPath with extra defines."
