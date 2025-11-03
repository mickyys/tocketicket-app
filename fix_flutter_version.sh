#!/bin/bash

# Script para probar el fix de versión de Flutter/Dart

echo "🔧 Aplicando fix de versión Flutter/Dart..."

# Mostrar el cambio realizado
echo "📝 Cambios realizados:"
echo "  - Flutter version: latest (para obtener Dart 3.9.0+)"
echo "  - Actualizado en build-ios.yml, build-android.yml, deploy-dev-testflight.yml"
echo "  - Mantenido pubspec.yaml con sdk: ^3.9.0"
echo ""

# Hacer commit de los cambios
git add .
git commit -m "fix: actualizar Flutter a latest para soporte Dart 3.9.0+

- Actualizado workflows para usar flutter-version: latest
- Necesario para cumplir requirement sdk: ^3.9.0 en pubspec.yaml
- Resuelve error: current Dart SDK 3.5.0 vs required ^3.9.0"

echo "📤 Haciendo push para disparar el workflow con el fix..."
git push origin main

echo "✅ Fix aplicado. El workflow debería ejecutarse ahora con Flutter latest."
echo "🔗 Monitorea en: https://github.com/mickyys/tocketicket-app/actions"