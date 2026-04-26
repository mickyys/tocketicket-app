#!/bin/bash

# Build script for Tocke App
# Usage: ./build_apk.sh [--version VERSION] [--platform PLATFORM] [--release|--debug] [--env ENVIRONMENT] [--api-url URL]

set -e

VERSION="1.0.5"
PLATFORM="android-arm64"
BUILD_TYPE="release"
ENVIRONMENT="prod"
API_URL="https://api.tocketicket.cl"

while [[ $# -gt 0 ]]; do
  case $1 in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --platform)
      PLATFORM="$2"
      shift 2
      ;;
    --release)
      BUILD_TYPE="release"
      shift
      ;;
    --debug)
      BUILD_TYPE="debug"
      shift
      ;;
    --env)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --api-url)
      API_URL="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--version VERSION] [--platform PLATFORM] [--release|--debug] [--env ENVIRONMENT] [--api-url URL]"
      echo "  --version VERSION   Version to build (default: 1.0.5)"
      echo "  --platform PLATFORM Target platform: android-arm64, android-arm, android-x64 (default: android-arm64)"
      echo "  --release         Release build (default)"
      echo "  --debug          Debug build"
      echo "  --env ENVIRONMENT Environment: prod, dev, staging (default: prod)"
      echo "  --api-url URL    API URL override (optional)"
      exit 1
      ;;
  esac
done

cd "$(dirname "$0")"

echo "============================================"
echo "Building Tocke App v$VERSION"
echo "Platform: $PLATFORM"
echo "Build Type: $BUILD_TYPE"
echo "Environment: $ENVIRONMENT"
if [ -n "$API_URL" ]; then
  echo "API URL: $API_URL"
fi
echo "============================================"

sed -i.bak "s/version: .*/version: $VERSION+1/" pubspec.yaml
mv pubspec.yaml.bak pubspec.yaml

OUTPUT_DIR="build/app/outputs/flutter-apk"
OUTPUT_NAME="tocke-$VERSION"

if [ "$ENVIRONMENT" != "prod" ]; then
  OUTPUT_NAME="${OUTPUT_NAME}-${ENVIRONMENT}"
fi

if [ "$BUILD_TYPE" = "debug" ]; then
  OUTPUT_NAME="${OUTPUT_NAME}-debug"
fi

BUILD_ARGS="--target-platform $PLATFORM"
if [ "$BUILD_TYPE" = "release" ]; then
  BUILD_ARGS="$BUILD_ARGS --release"
else
  BUILD_ARGS="$BUILD_ARGS --debug"
fi

BUILD_ARGS="$BUILD_ARGS --dart-define=ENVIRONMENT=$ENVIRONMENT"
if [ -n "$API_URL" ]; then
  BUILD_ARGS="$BUILD_ARGS --dart-define=API_URL=$API_URL"
fi

echo "Running: flutter build apk $BUILD_ARGS"
flutter build apk $BUILD_ARGS

if [ -d "$OUTPUT_DIR" ]; then
  for apk in "$OUTPUT_DIR"/*.apk; do
    if [ -f "$apk" ]; then
      mv "$apk" "$OUTPUT_DIR/${OUTPUT_NAME}.apk"
      echo "APK generated: ${OUTPUT_DIR}/${OUTPUT_NAME}.apk"
      break
    fi
  done
fi

if [ -d "build/app/outputs/apk/$ENVIRONMENT/$BUILD_TYPE" ]; then
  OUTPUT_DIR="build/app/outputs/apk/$ENVIRONMENT/$BUILD_TYPE"
  for apk in "$OUTPUT_DIR"/*.apk; do
    if [ -f "$apk" ]; then
      mv "$apk" "build/app/outputs/${OUTPUT_NAME}.apk"
      echo "APK generated: build/app/outputs/${OUTPUT_NAME}.apk"
      break
    fi
  done
fi

echo ""
echo "Build completed successfully!"