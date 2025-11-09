#!/bin/bash

echo "🍎 Limpiando y reconstruyendo proyecto iOS..."

# Navegar al directorio del proyecto
cd "$(dirname "$0")/.."

# Limpiar Flutter
flutter clean

# Limpiar pod cache
cd ios
rm -rf Pods/
rm -rf .symlinks/
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf .dart_tool/
rm Podfile.lock

echo "📦 Obteniendo dependencias Flutter..."
cd ..
flutter pub get

echo "🔨 Instalando pods de iOS..."
cd ios
pod deintegrate
pod setup
pod install --repo-update

echo "✅ Reconstrucción de iOS completada"
echo "💡 Ahora puedes ejecutar: flutter run o abrir Runner.xcworkspace en Xcode"