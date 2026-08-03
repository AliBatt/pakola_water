#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="build/apks"
mkdir -p "$OUT"

build_one () {
  local name="$1"
  local target="$2"
  echo "Building $name..."
  flutter build apk --release --target="$target"
  cp build/app/outputs/flutter-apk/app-release.apk "$OUT/pakola-${name}-release.apk"
  echo "→ $OUT/pakola-${name}-release.apk"
}

build_one customer   lib/app/customer_app/main.dart
build_one supervisor lib/app/supervisor_app/main.dart
build_one rider      lib/app/driver_app/main.dart

echo "Done. APKs in $OUT"