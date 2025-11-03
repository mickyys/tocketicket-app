#!/bin/bash

# Script para ejecutar el deployment a TestFlight localmente
# Requiere: Xcode, Flutter, certificados iOS configurados localmente

set -e

echo "🚀 Iniciando deployment local a TestFlight..."

# Verificar que estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Este script debe ejecutarse desde el directorio raíz del proyecto Flutter"
    exit 1
fi

# Verificar Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter no está instalado"
    exit 1
fi

echo "📦 Obteniendo dependencias de Flutter..."
flutter pub get

echo "🍎 Instalando pods de iOS..."
cd ios
pod install
cd ..

echo "🔨 Construyendo app iOS para Release..."
flutter build ios --release --verbose

echo "📦 Creando archivo IPA..."
cd ios

# Verificar que el workspace existe
if [ ! -f "Runner.xcworkspace" ]; then
    echo "❌ Error: Runner.xcworkspace no encontrado"
    exit 1
fi

# Crear archivo
xcodebuild -workspace Runner.xcworkspace \
           -scheme Runner \
           -configuration Release \
           -destination generic/platform=iOS \
           -archivePath build/Runner.xcarchive \
           archive

# Exportar IPA
xcodebuild -exportArchive \
           -archivePath build/Runner.xcarchive \
           -exportPath build \
           -exportOptionsPlist Runner/ExportOptions.plist

echo "📤 Subiendo a TestFlight..."
# Nota: Necesitarás configurar tu API Key de App Store Connect localmente
IPA_FILE=$(find build -name "*.ipa" | head -n 1)

if [ -z "$IPA_FILE" ]; then
    echo "❌ Error: No se encontró el archivo IPA"
    exit 1
fi

echo "📱 Archivo IPA creado: $IPA_FILE"
echo "✅ Para subir a TestFlight, necesitas:"
echo "   1. Configurar tu API Key de App Store Connect"
echo "   2. Ejecutar: xcrun altool --upload-app --type ios --file '$IPA_FILE' --apiKey [TU_API_KEY] --apiIssuer [TU_ISSUER_ID]"

cd ..
echo "🎉 Proceso completado!"