#!/bin/bash

# Script para incrementar automáticamente las versiones
# Uso: ./increment_version.sh [patch|minor|major]

set -e

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [patch|minor|major]"
    echo ""
    echo "Ejemplos:"
    echo "  $0 patch  # 1.0.0+1 -> 1.0.1+2"
    echo "  $0 minor  # 1.0.1+2 -> 1.1.0+3" 
    echo "  $0 major  # 1.1.0+3 -> 2.0.0+4"
    echo ""
    exit 1
}

# Verificar parámetros
if [ $# -eq 0 ]; then
    show_help
fi

TYPE=$1

# Leer versión actual del pubspec.yaml
CURRENT_VERSION=$(grep "version: " pubspec.yaml | cut -d' ' -f2)
SEMANTIC_VERSION=$(echo $CURRENT_VERSION | cut -d'+' -f1)
BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f2)

# Separar componentes de la versión semántica
MAJOR=$(echo $SEMANTIC_VERSION | cut -d'.' -f1)
MINOR=$(echo $SEMANTIC_VERSION | cut -d'.' -f2)
PATCH=$(echo $SEMANTIC_VERSION | cut -d'.' -f3)

# Incrementar número de build
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))

# Incrementar versión según tipo
case $TYPE in
    "patch")
        NEW_PATCH=$((PATCH + 1))
        NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH+$NEW_BUILD_NUMBER"
        ;;
    "minor")
        NEW_MINOR=$((MINOR + 1))
        NEW_VERSION="$MAJOR.$NEW_MINOR.0+$NEW_BUILD_NUMBER"
        ;;
    "major")
        NEW_MAJOR=$((MAJOR + 1))
        NEW_VERSION="$NEW_MAJOR.0.0+$NEW_BUILD_NUMBER"
        ;;
    *)
        echo "Error: Tipo de versión inválido '$TYPE'"
        show_help
        ;;
esac

echo "Versión actual: $CURRENT_VERSION"
echo "Nueva versión:  $NEW_VERSION"

# Confirmar cambio
read -p "¿Continuar con el cambio? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operación cancelada."
    exit 1
fi

# Actualizar pubspec.yaml
sed -i '' "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" pubspec.yaml

echo "✅ Versión actualizada en pubspec.yaml"
echo "💡 No olvides hacer commit de los cambios:"
echo "   git add pubspec.yaml"
echo "   git commit -m \"chore: bump version to $NEW_VERSION\""
echo "   git tag v$NEW_VERSION"