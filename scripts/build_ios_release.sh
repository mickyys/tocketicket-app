#!/bin/bash

# Script para incrementar el build number y compilar iOS release
# Uso: ./scripts/build_ios_release.sh
#
# Flujo:
#   1. Incrementa FLUTTER_BUILD_NUMBER en pubspec.yaml
#   2. Ejecuta flutter build ios --dart-define=ENVIRONMENT=prod --release
#   3. Al finalizar, abre Xcode y realiza el Archive (Product → Archive)

set -e

PUBSPEC="pubspec.yaml"

# Leer versión actual
CURRENT_VERSION=$(grep "^version: " "$PUBSPEC" | cut -d' ' -f2)
SEMANTIC_VERSION=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

# Incrementar build number
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
NEW_VERSION="$SEMANTIC_VERSION+$NEW_BUILD_NUMBER"

echo "📦 Versión actual:  $CURRENT_VERSION"
echo "🚀 Nueva versión:   $NEW_VERSION"
echo ""

# Actualizar pubspec.yaml
sed -i '' "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC"
echo "✅ pubspec.yaml actualizado → $NEW_VERSION"

# Compilar Flutter iOS release
echo ""
echo "🔨 Compilando Flutter iOS release..."
echo "   (esto actualiza ios/Flutter/Generated.xcconfig con FLUTTER_BUILD_NUMBER=$NEW_BUILD_NUMBER)"
echo ""

flutter build ios --dart-define=ENVIRONMENT=prod --release

echo ""
echo "✅ Build completado: $NEW_VERSION"
echo "   FLUTTER_BUILD_NAME   = $SEMANTIC_VERSION"
echo "   FLUTTER_BUILD_NUMBER = $NEW_BUILD_NUMBER"
echo ""
echo "📱 Siguiente paso: abre Xcode y haz Product → Archive"
