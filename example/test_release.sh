#!/bin/bash
set -e

echo "=========================================="
echo "Testing flutter_release_manager package"
echo "=========================================="

echo "1. Cleaning project..."
fvm flutter clean

echo "2. Getting dependencies..."
fvm flutter pub get

echo "3. Running doctor..."
fvm dart run flutter_release_manager:flutter_release doctor

echo "4. Running preview..."
fvm dart run flutter_release_manager:flutter_release preview

echo "5. Building APK..."
fvm dart run flutter_release_manager:flutter_release build --target apk

echo "=========================================="
echo "Verification"
echo "=========================================="
if find .build_release -type f -name "*.apk" | grep -q .; then
    echo "✅ SUCCESS: Release APK generated successfully!"
    find .build_release -type f -name "*.apk" -exec ls -lh {} +
else
    echo "❌ FAILURE: Release APK not found in .build_release/"
    exit 1
fi
