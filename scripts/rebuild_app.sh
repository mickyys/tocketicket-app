#!/bin/bash

echo "🔄 Limpiando proyecto Flutter..."

# Limpiar caché de Flutter
flutter clean

# Limpiar caché de pub
flutter pub cache clean --force

# Eliminar build folders
rm -rf build/
rm -rf android/build/
rm -rf android/app/build/
rm -rf ios/build/
rm -rf .dart_tool/

echo "📦 Obteniendo dependencias..."
flutter pub get

echo "🔨 Reconstruyendo para Android..."
flutter build apk --debug

echo "✅ Reconstrucción completada"
echo "💡 Ahora puedes ejecutar: flutter run"