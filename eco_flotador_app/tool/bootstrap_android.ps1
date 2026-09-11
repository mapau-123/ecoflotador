$ErrorActionPreference = 'Stop'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter no está instalado o no está disponible en PATH.'
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $projectRoot

if (
    -not (Test-Path (Join-Path $projectRoot 'android')) -or
    -not (Test-Path (Join-Path $projectRoot 'android\settings.gradle.kts'))
) {
    $backupRoot = Join-Path `
        ([System.IO.Path]::GetTempPath()) `
        ("eco-flotador-backup-" + [guid]::NewGuid().ToString())

    New-Item -ItemType Directory -Path $backupRoot | Out-Null

    try {
        Copy-Item -Path lib, test -Destination $backupRoot -Recurse
        Copy-Item `
            -Path pubspec.yaml, analysis_options.yaml, README.md, ARCHITECTURE.md `
            -Destination $backupRoot

        flutter create `
            --empty `
            --platforms=android `
            --org co.edu.ecoflotador `
            --project-name eco_flotador `
            .

        Copy-Item `
            -Path "$backupRoot\lib", "$backupRoot\test" `
            -Destination $projectRoot `
            -Recurse `
            -Force
        Copy-Item `
            -Path `
                "$backupRoot\pubspec.yaml", `
                "$backupRoot\analysis_options.yaml", `
                "$backupRoot\README.md", `
                "$backupRoot\ARCHITECTURE.md" `
            -Destination $projectRoot `
            -Force
    }
    finally {
        if (Test-Path $backupRoot) {
            Remove-Item -LiteralPath $backupRoot -Recurse -Force
        }
    }
}

flutter pub get
dart format .
flutter analyze
flutter test

Write-Host 'ECO FLOTADOR preparado. Ejecute: flutter run' -ForegroundColor Green
