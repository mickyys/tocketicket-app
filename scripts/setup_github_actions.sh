#!/bin/bash

# Script para configurar GitHub Actions en el proyecto Tocke Validator
# Este script ayuda a configurar los secretos y archivos necesarios

echo "🚀 Configurando GitHub Actions para Tocke Validator"
echo ""

# Función para mostrar ayuda
show_help() {
    echo "Este script ayuda a configurar GitHub Actions para compilar la app en Android e iOS"
    echo ""
    echo "Para usar GitHub Actions necesitas configurar los siguientes secretos en tu repositorio:"
    echo ""
    echo "📱 ANDROID (Producción):"
    echo "  ANDROID_KEYSTORE_BASE64     - Keystore codificado en base64"
    echo "  ANDROID_KEYSTORE_PASSWORD   - Contraseña del keystore"
    echo "  ANDROID_KEY_PASSWORD        - Contraseña de la key"
    echo "  ANDROID_KEY_ALIAS           - Alias de la key"
    echo ""
    echo "🍎 iOS (Producción):"
    echo "  IOS_CERTIFICATE_BASE64      - Certificado .p12 codificado en base64"
    echo "  IOS_CERTIFICATE_PASSWORD    - Contraseña del certificado"
    echo "  IOS_PROVISIONING_PROFILE_BASE64 - Perfil de aprovisionamiento codificado en base64"
    echo ""
    echo "📋 Pasos para configurar:"
    echo "1. Ve a tu repositorio en GitHub"
    echo "2. Settings > Secrets and variables > Actions"
    echo "3. Agrega cada uno de los secretos listados arriba"
    echo ""
}

# Función para generar keystore de Android
generate_android_keystore() {
    echo "🔐 Generando keystore para Android..."
    
    read -p "Ingresa el alias para la key (ej: tocke): " KEY_ALIAS
    read -p "Ingresa tu nombre completo: " USER_NAME
    read -p "Ingresa tu organización: " ORG_NAME
    read -p "Ingresa tu ciudad: " CITY
    read -p "Ingresa tu país (código de 2 letras, ej: CL): " COUNTRY
    
    keytool -genkey -v \
        -keystore android/tocke-keystore.jks \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -alias "$KEY_ALIAS" \
        -dname "CN=$USER_NAME, OU=$ORG_NAME, O=$ORG_NAME, L=$CITY, ST=$CITY, C=$COUNTRY"
    
    if [ $? -eq 0 ]; then
        echo "✅ Keystore generado en android/tocke-keystore.jks"
        echo ""
        echo "Para codificar en base64 (requerido para GitHub Actions):"
        echo "base64 -i android/tocke-keystore.jks | pbcopy"
        echo ""
        echo "⚠️  Guarda la contraseña y el alias que acabas de crear"
    else
        echo "❌ Error generando el keystore"
    fi
}

# Función para mostrar comandos de build locales
show_build_commands() {
    echo "🔨 Comandos para compilar localmente:"
    echo ""
    echo "📱 Android:"
    echo "  Desarrollo: flutter build apk --debug --flavor dev --dart-define=ENVIRONMENT=dev"
    echo "  Producción: flutter build apk --release --flavor prod --dart-define=ENVIRONMENT=prod"
    echo "  AAB (Play Store): flutter build appbundle --release --flavor prod --dart-define=ENVIRONMENT=prod"
    echo ""
    echo "🍎 iOS:"
    echo "  Desarrollo: flutter build ios --debug --flavor dev --dart-define=ENVIRONMENT=dev"
    echo "  Producción: flutter build ios --release --flavor prod --dart-define=ENVIRONMENT=prod"
    echo ""
}

# Función para verificar la configuración
verify_setup() {
    echo "🔍 Verificando configuración..."
    
    # Verificar Flutter
    if command -v flutter &> /dev/null; then
        echo "✅ Flutter instalado: $(flutter --version | head -n 1)"
    else
        echo "❌ Flutter no encontrado"
    fi
    
    # Verificar archivos de configuración
    if [ -f ".github/workflows/build-android.yml" ]; then
        echo "✅ Workflow de Android configurado"
    else
        echo "❌ Workflow de Android no encontrado"
    fi
    
    if [ -f ".github/workflows/build-ios.yml" ]; then
        echo "✅ Workflow de iOS configurado"
    else
        echo "❌ Workflow de iOS no encontrado"
    fi
    
    if [ -f "lib/config/app_config.dart" ]; then
        echo "✅ Configuración de entornos creada"
    else
        echo "❌ Configuración de entornos no encontrada"
    fi
    
    echo ""
}

# Función principal
main() {
    case "$1" in
        "help"|"-h"|"--help")
            show_help
            ;;
        "keystore")
            generate_android_keystore
            ;;
        "commands")
            show_build_commands
            ;;
        "verify")
            verify_setup
            ;;
        *)
            echo "Opciones disponibles:"
            echo "  help     - Mostrar ayuda completa"
            echo "  keystore - Generar keystore de Android"
            echo "  commands - Mostrar comandos de build"
            echo "  verify   - Verificar configuración"
            echo ""
            echo "Ejemplo: ./scripts/setup_github_actions.sh help"
            ;;
    esac
}

main "$@"