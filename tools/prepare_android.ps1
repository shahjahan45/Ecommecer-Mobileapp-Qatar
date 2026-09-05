$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$gradlew = Join-Path $root "android\gradlew.bat"
$wrapperJar = Join-Path $root "android\gradle\wrapper\gradle-wrapper.jar"

if (-not (Test-Path $gradlew) -or -not (Test-Path $wrapperJar)) {
    Write-Host "Android Gradle wrapper is missing. Regenerating it with the installed Flutter SDK..." -ForegroundColor Yellow

    $backup = Join-Path $env:TEMP ("dcx_android_backup_" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $backup | Out-Null

    $preserve = @(
        "android\app\src\main",
        "android\app\src\debug\AndroidManifest.xml",
        "android\app\build.gradle",
        "android\app\google-services.json",
        "android\build.gradle",
        "android\settings.gradle",
        "android\gradle.properties"
    )

    foreach ($relative in $preserve) {
        $source = Join-Path $root $relative
        if (Test-Path $source) {
            $destination = Join-Path $backup $relative
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
            Copy-Item $source $destination -Recurse -Force
        }
    }

    flutter create --platforms=android --org com.example --project-name ecommerce_mobile .

    foreach ($relative in $preserve) {
        $source = Join-Path $backup $relative
        if (Test-Path $source) {
            $destination = Join-Path $root $relative
            if (Test-Path $destination) {
                Remove-Item $destination -Recurse -Force
            }
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
            Copy-Item $source $destination -Recurse -Force
        }
    }

    Remove-Item $backup -Recurse -Force
    Write-Host "Android wrapper regenerated; DCX Firebase/branding configuration restored." -ForegroundColor Green
}

if (-not (Test-Path "$root\android\app\google-services.json")) {
    throw "android\app\google-services.json is missing. Firebase Android configuration cannot initialize."
}

flutter pub get
Write-Host "Android platform and Firebase client configuration are ready." -ForegroundColor Green
