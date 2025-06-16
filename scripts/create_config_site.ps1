# =================================================================================================
# CREATE PJSIP CONFIG_SITE.H FILE (CALLED BY GITHUB ACTIONS WORKFLOW)
#
# Author: Hugo Castro de Deco, Sufficit
# Collaboration: Gemini AI for Google
# Date: June 16, 2025
# Version: 3
#
# This script creates the PJSIP's config_site.h file, which includes platform-specific
# settings, Opus support, and also incorporates pjsip_extra_defines.h.
#
# Changes:
#   - Changed file generation to use Set-Content with ASCII encoding for robustness
#     against C preprocessor errors.
# =================================================================================================

$outputPath = "pjlib/include/pj/config_site.h"

$configSiteContent = @"
# =================================================================================================
# PJSIP CUSTOM CONFIGURATION FILE
#
# Author: Hugo Castro de Deco, Sufficit
# Collaboration: Gemini AI for Google
# Date: June 15, 2025
# Version: 2
#
# This file provides custom configuration definitions for PJSIP,
# including platform-specific settings and feature flags.
# =================================================================================================
// Define Windows version for API compatibility (e.g., for WASAPI functions)
#define _WIN32_WINNT 0x0A00 // Target Windows 10 (or later for _WIN32_WINNT_WIN10) - 0x0601 for Win 7, 0x0600 for Win Vista
#define PJ_CONFIG_WIN_AUTO   1
#define PJ_IS_BIG_ENDIAN     0
#define PJ_HAS_OPUS_CODEC    1
// To prevent WinVer redefinition issue with VS2022
#define PJ_DONT_NEED_WIN32_VER_HACKS 1
// Explicitly define platform/architecture for broader compatibility
#define _WIN32
#define _M_X64
#include <pj/config_site_sample.h>
#include <pj/pjsip_extra_defines.h> // Include the new extra defines file
"@

# Write content to file using Set-Content and ASCII encoding
Set-Content -Path $outputPath -Value $configSiteContent -Encoding ASCII -Force

Write-Host "Created $outputPath with PJSIP custom configuration."
