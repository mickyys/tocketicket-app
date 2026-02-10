#!/bin/bash

# Script para verificar y configurar TestFlight
echo "🚀 Verificando configuración de TestFlight para Tocke Scanner"
echo ""

# Función para verificar secretos en GitHub (simulación)
check_github_secrets() {
    echo "🔐 Secretos requeridos en GitHub Actions:"
    echo ""
    echo "📱 iOS Signing:"
    echo "   ✓ IOS_CERTIFICATE_BASE64"
    echo "   ✓ IOS_CERTIFICATE_PASSWORD"
    echo "   ✓ IOS_PROVISIONING_PROFILE_BASE64"
    echo ""
    echo "🍎 App Store Connect API:"
    echo "   ⚠️  APP_STORE_CONNECT_API_KEY_ID (NUEVO)"
    echo "   ⚠️  APP_STORE_CONNECT_ISSUER_ID (NUEVO)"
    echo "   ⚠️  APP_STORE_CONNECT_API_KEY_BASE64 (NUEVO)"
    echo ""
    echo "Para configurar estos secretos:"
    echo "1. Ve a tu repositorio en GitHub"
    echo "2. Settings → Secrets and variables → Actions"
    echo "3. New repository secret"
    echo ""
}

# Función para verificar archivos de configuración
check_config_files() {
    echo "📄 Verificando archivos de configuración..."
    
    if [ -f ".github/workflows/deploy-testflight.yml" ]; then
        echo "✅ Workflow de TestFlight configurado"
    else
        echo "❌ Workflow de TestFlight no encontrado"
    fi
    
    if [ -f "ios/Runner/ExportOptions.plist" ]; then
        echo "✅ ExportOptions.plist encontrado"
        
        if grep -q "ZP8L46Q7JJ" ios/Runner/ExportOptions.plist; then
            echo "✅ Team ID configurado correctamente"
        else
            echo "❌ Team ID no configurado"
        fi
        
        if grep -q "app-store" ios/Runner/ExportOptions.plist; then
            echo "✅ Método de exportación para App Store"
        else
            echo "❌ Método de exportación incorrecto"
        fi
    else
        echo "❌ ExportOptions.plist no encontrado"
    fi
    
    echo ""
}

# Función para mostrar pasos de configuración de App Store Connect
show_appstore_setup() {
    echo "🏪 Configuración de App Store Connect API:"
    echo ""
    echo "1. 🔑 Crear API Key:"
    echo "   - Ve a https://appstoreconnect.apple.com"
    echo "   - Users and Access → Keys → App Store Connect API"
    echo "   - Generate API Key"
    echo "   - Name: GitHub Actions - Tocke Scanner"
    echo "   - Access: Developer"
    echo ""
    echo "2. 📝 Obtener información:"
    echo "   - Key ID (ej: 2X9R4HXF34)"
    echo "   - Issuer ID (ej: 69a6de70-xxxx-xxxx-xxxx-xxxxxxxxxxxx)"
    echo "   - Descargar archivo .p8 (solo una vez!)"
    echo ""
    echo "3. 🔧 Codificar archivo .p8:"
    echo "   base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy"
    echo ""
}

# Función para mostrar comandos de testing
show_testing_commands() {
    echo "🧪 Comandos para probar la configuración:"
    echo ""
    echo "📱 Build local (sin subir):"
    echo "flutter build ios --release --flavor prod --dart-define=ENVIRONMENT=prod"
    echo ""
    echo "🚀 Trigger manual de TestFlight:"
    echo "1. Ve a Actions en GitHub"
    echo "2. Deploy to TestFlight"
    echo "3. Run workflow"
    echo "4. Personaliza notas (opcional)"
    echo ""
    echo "📊 Monitorear en App Store Connect:"
    echo "1. https://appstoreconnect.apple.com"
    echo "2. TestFlight → iOS → Builds"
    echo "3. Verificar estado: Processing → Ready for Testing"
    echo ""
}

# Función para mostrar el flujo completo
show_workflow() {
    echo "🔄 Flujo completo de TestFlight:"
    echo ""
    echo "1. 💻 Push a main branch:"
    echo "   git push origin main"
    echo ""
    echo "2. 🤖 GitHub Actions (automático):"
    echo "   ├── Checkout código"
    echo "   ├── Setup Flutter + Xcode"
    echo "   ├── Install dependencies"
    echo "   ├── Setup iOS signing"
    echo "   ├── Build iOS release"
    echo "   ├── Create IPA"
    echo "   ├── Setup App Store Connect API"
    echo "   └── Upload to TestFlight ✨"
    echo ""
    echo "3. 🍎 App Store Connect (automático):"
    echo "   ├── Processing (5-10 min)"
    echo "   ├── Ready for Testing"
    echo "   └── Notify internal testers"
    echo ""
    echo "4. 📧 Testers reciben notificación y pueden descargar"
    echo ""
}

# Función para verificar la configuración del proyecto
check_project_config() {
    echo "📱 Verificando configuración del proyecto..."
    
    if grep -q "cl.tocketicket.staffscanner" ios/Runner/ExportOptions.plist; then
        echo "✅ Bundle ID configurado: cl.tocketicket.staffscanner"
    else
        echo "❌ Bundle ID no configurado correctamente"
    fi
    
    if [ -f "ios/Runner/Runner.entitlements" ]; then
        echo "✅ Entitlements de producción configurados"
    else
        echo "❌ Entitlements no encontrados"
    fi
    
    if [ -f "lib/config/app_config.dart" ]; then
        if grep -q "Tocke Scanner" lib/config/app_config.dart; then
            echo "✅ App name configurado: Tocke Scanner"
        else
            echo "❌ App name no configurado"
        fi
    fi
    
    echo ""
}

# Función principal
main() {
    case "$1" in
        "secrets")
            check_github_secrets
            ;;
        "files")
            check_config_files
            ;;
        "appstore")
            show_appstore_setup
            ;;
        "test")
            show_testing_commands
            ;;
        "workflow")
            show_workflow
            ;;
        "project")
            check_project_config
            ;;
        "all"|"")
            check_project_config
            check_config_files
            echo "---"
            check_github_secrets
            echo "---"
            show_appstore_setup
            echo "---"
            show_workflow
            ;;
        *)
            echo "Opciones disponibles:"
            echo "  secrets   - Mostrar secretos requeridos"
            echo "  files     - Verificar archivos de configuración"
            echo "  appstore  - Pasos para App Store Connect API"
            echo "  test      - Comandos de testing"
            echo "  workflow  - Mostrar flujo completo"
            echo "  project   - Verificar configuración del proyecto"
            echo "  all       - Ejecutar todas las verificaciones"
            echo ""
            echo "Ejemplo: ./scripts/testflight_setup.sh appstore"
            ;;
    esac
}

main "$@"