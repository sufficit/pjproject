# =================================================================================================
# CREATE EXTRA PJSIP CONFIG FILE (CALLED BY GITHUB ACTIONS WORKFLOW)
#
# Author: Hugo Castro de Deco, Sufficit
# Collaboration: Gemini AI for Google
# Date: June 15, 2025
# Version: 1
#
# This script creates an additional configuration file for PJSIP, containing extra
# define statements or overrides.
# =================================================================================================

$extraConfigContent = @"
// =================================================================================================
// PJSIP EXTRA DEFINITIONS FILE
//
// This file contains additional, optional define statements for PJSIP.
// It is intended to be included by config_site.h.
// =================================================================================================

#define PJMEDIA_HAS_G729_CODEC 0 // Example: Disable G.729 if not needed or licensed
#define PJSIP_MAX_CALLS 4       // Example: Set maximum number of concurrent calls
#define PJ_LOG_MAX_LEVEL 5      // Example: Set maximum log level (0=none, 6=verbose)

// Add any other specific defines here
"@

$outputPath = "pjlib/include/pj/pjsip_extra_defines.h"
New-Item -ItemType File -Path $outputPath -Force
Set-Content -Path $outputPath -Value $extraConfigContent

Write-Host "Created $outputPath with extra defines."
