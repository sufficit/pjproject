# =================================================================================================
# CREATE PJSIP CONFIG_SITE.H FILE (CALLED BY GITHUB ACTIONS WORKFLOW)
#
# Author: Hugo Castro de Deco, Sufficit
# Collaboration: Gemini AI for Google
# Date: June 16, 2025
# Version: 2
#
# This script creates the PJSIP's config_site.h file, which includes platform-specific
# settings, Opus support, and also incorporates pjsip_extra_defines.h.
#
# Changes:
#   - Changed from using here-string to Add-Content for more reliable file generation
#     to avoid C preprocessor errors.
# =================================================================================================

$outputPath = "pjlib/include/pj/config_site.h"
New-Item -ItemType File -Path $outputPath -Force # Create or overwrite the file

# Write content line by line to ensure correct formatting
Add-Content -Path $outputPath -Value "# =================================================================================================" -Encoding UTF8
Add-Content -Path $outputPath -Value "# PJSIP CUSTOM CONFIGURATION FILE" -Encoding UTF8
Add-Content -Path $outputPath -Value "#" -Encoding UTF8
Add-Content -Path $outputPath -Value "# Author: Hugo Castro de Deco, Sufficit" -Encoding UTF8
Add-Content -Path $outputPath -Value "# Collaboration: Gemini AI for Google" -Encoding UTF8
Add-Content -Path $outputPath -Value "# Date: June 15, 2025" -Encoding UTF8
Add-Content -Path $outputPath -Value "# Version: 2" -Encoding UTF8
Add-Content -Path $outputPath -Value "#" -Encoding UTF8
Add-Content -Path $outputPath -Value "# This file provides custom configuration definitions for PJSIP," -Encoding UTF8
Add-Content -Path $outputPath -Value "# including platform-specific settings and feature flags." -Encoding UTF8
Add-Content -Path $outputPath -Value "# =================================================================================================" -Encoding UTF8
Add-Content -Path $outputPath -Value "// Define Windows version for API compatibility (e.g., for WASAPI functions)" -Encoding UTF8
Add-Content -Path $outputPath -Value "#define _WIN32_WINNT 0x0A00 // Target Windows 10 (or later for _WIN32_WINNT_WIN10) - 0x0601 for Win 7, 0x0600 for Win Vista" -Encoding UTF8
Add-Content -Path $outputPath -Value "#define PJ_CONFIG_WIN_AUTO   1" -Encoding UTF8
Add-Content -Path $outputPath -Value "#define PJ_IS_BIG_ENDIAN     0" -Encoding UTF8
Add-Content -Path $outputPath -Value "#define PJ_HAS_OPUS_CODEC    1" -Encoding UTF8
Add-Content -Path $outputPath -Value "// To prevent WinVer redefinition issue with VS2022" -Encoding UTF8
Add-Content -Path $outputPath -Value "#define PJ_DONT_NEED_WIN32_VER_HACKS 1" -Encoding UTF8
Add-Content -Path $outputPath -Value "// Explicitly define platform/architecture for broader compatibility" -Encoding UTF8
Add-Content -Path $outputPath -Value "#define _WIN32" -Encoding UTF8
Add-Content -Path $outputPath -Value "#define _M_X64" -Encoding UTF8
Add-Content -Path $outputPath -Value "#include <pj/config_site_sample.h>" -Encoding UTF8
Add-Content -Path $outputPath -Value "#include <pj/pjsip_extra_defines.h> // Include the new extra defines file" -Encoding UTF8

Write-Host "Created $outputPath with PJSIP custom configuration."
