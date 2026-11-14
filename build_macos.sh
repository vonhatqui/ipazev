#!/usr/bin/env bash
set -euo pipefail

echo "=========================================================="
echo "  🚀 BUILDING CLEAN ZEVCHEATIOS ARM64 IPA VIA SWIFTC"
echo "=========================================================="

APP_NAME="ZevCheatiOS"
SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)
BUILD_DIR="build_out"
PAYLOAD_DIR="${BUILD_DIR}/Payload/${APP_NAME}.app"

rm -rf "${BUILD_DIR}" "${APP_NAME}.ipa" *.o
mkdir -p "${PAYLOAD_DIR}"

echo "[1/4] Compiling 3105 C/Objective-C exploit bridge..."
xcrun --sdk iphoneos clang -c \
    -target arm64-apple-ios16.0 \
    -isysroot "${SDK_PATH}" \
    -fmodules \
    -fobjc-arc \
    Source/Exploit/mcm_bridge.m \
    Source/Exploit/bad_query.c \
    -I Source/Exploit

echo "[2/4] Compiling Swift source files targeting iOS arm64..."
SWIFT_FILES=$(find Source -name "*.swift")

xcrun --sdk iphoneos swiftc \
    -target arm64-apple-ios16.0 \
    -sdk "${SDK_PATH}" \
    -O \
    -whole-module-optimization \
    -parse-as-library \
    -import-objc-header Source/ZevCheatiOS-Bridging-Header.h \
    -framework UIKit \
    -framework Foundation \
    -framework Network \
    -framework Security \
    -framework CoreGraphics \
    -framework QuartzCore \
    -framework UniformTypeIdentifiers \
    mcm_bridge.o bad_query.o \
    ${SWIFT_FILES} \
    -o "${PAYLOAD_DIR}/${APP_NAME}"

echo "  ✓ Compiled binary: ${PAYLOAD_DIR}/${APP_NAME}"
ls -lh "${PAYLOAD_DIR}/${APP_NAME}"

echo "[3/4] Copying Info.plist and PkgInfo..."
cp Info.plist "${PAYLOAD_DIR}/Info.plist"
echo -n "APPL????" > "${PAYLOAD_DIR}/PkgInfo"

echo "[3.5] Copying App Icons & Resources..."
if [ -d "Resources/AppIcons" ]; then
    cp -r Resources/AppIcons/* "${PAYLOAD_DIR}/"
fi
if [ -d "Resources/Images" ]; then
    cp -r Resources/Images/* "${PAYLOAD_DIR}/"
fi
if [ -f "Resources/Images/logo.png" ]; then
    cp "Resources/Images/logo.png" "${PAYLOAD_DIR}/logo.png"
fi

echo "[3.6] Ad-hoc code signing Mach-O executable..."
codesign --force --deep --sign - "${PAYLOAD_DIR}" || true

echo "[4/4] Packaging into IPA (zip)..."
cd "${BUILD_DIR}"
zip -r9 "../${APP_NAME}.ipa" Payload
cd ..

IPA_SIZE=$(du -h "${APP_NAME}.ipa" | cut -f1)
echo "=========================================================="
echo "  🎉 BUILD SUCCESS: ${APP_NAME}.ipa (${IPA_SIZE})"
echo "=========================================================="
