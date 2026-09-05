$ErrorActionPreference = "Stop"

# Phase 19.1 Final: Firebase Android config is already integrated through
# android/app/google-services.json. Only DCX Core network address is required.
$apiBaseUrl = "http://192.168.18.21:8000"

flutter run `
  --dart-define=DCX_API_MODE=remote `
  --dart-define=DCX_API_BASE_URL=$apiBaseUrl
