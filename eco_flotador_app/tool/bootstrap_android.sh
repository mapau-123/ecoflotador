#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter no está instalado o no está disponible en PATH." >&2
  exit 1
fi

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

if [[ ! -f android/settings.gradle.kts ]]; then
  backup_root="$(mktemp -d)"
  trap 'rm -rf "$backup_root"' EXIT

  cp -R lib test "$backup_root/"
  cp pubspec.yaml analysis_options.yaml README.md ARCHITECTURE.md "$backup_root/"

  flutter create \
    --empty \
    --platforms=android \
    --org co.edu.ecoflotador \
    --project-name eco_flotador \
    .

  cp -R "$backup_root/lib" "$backup_root/test" .
  cp \
    "$backup_root/pubspec.yaml" \
    "$backup_root/analysis_options.yaml" \
    "$backup_root/README.md" \
    "$backup_root/ARCHITECTURE.md" \
    .
fi

flutter pub get
dart format .
flutter analyze
flutter test

echo "ECO FLOTADOR preparado. Ejecute: flutter run"
