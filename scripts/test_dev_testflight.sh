#!/bin/bash

# Script para probar subida de desarrollo a TestFlight
echo "🧪 Testing Development Build Upload to TestFlight"
echo ""

# Función para mostrar opciones
show_options() {
    echo "Opciones para probar desarrollo en TestFlight:"
    echo ""
    echo "1. 🚀 Trigger manual desde GitHub Actions:"
    echo "   - Ve a Actions → Deploy Dev to TestFlight"
    echo "   - Run workflow"
    echo "   - Personaliza notas de versión"
    echo ""
    echo "2. 📱 Push automático (triggers en cambios):"
    echo "   - Push a 'develop' branch"
    echo "   - Push a cualquier 'feature/*' branch"
    echo "   - Solo si hay cambios en: lib/, ios/, android/, pubspec.yaml"
    echo ""
    echo "3. 🔧 Build local para testing:"
    echo "   flutter build ios --release --flavor dev --dart-define=ENVIRONMENT=dev"
    echo ""
}

# Función para crear un commit de prueba
create_test_commit() {
    echo "📝 Creando commit de prueba para trigger automático..."
    
    # Crear un pequeño cambio en el archivo de configuración
    current_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Agregar comentario temporal en app_config.dart
    if [ -f "lib/config/app_config.dart" ]; then
        echo "" >> lib/config/app_config.dart
        echo "  // Test build triggered at: $current_time" >> lib/config/app_config.dart
        
        git add lib/config/app_config.dart
        git commit -m "test: trigger dev TestFlight build at $current_time"
        
        echo "✅ Commit de prueba creado"
        echo "📤 Haz push para trigger automático:"
        echo "   git push origin $(git branch --show-current)"
    else
        echo "❌ Archivo app_config.dart no encontrado"
    fi
    
    echo ""
}

# Función para verificar la configuración
check_config() {
    echo "🔍 Verificando configuración para desarrollo..."
    
    # Verificar workflow de dev
    if [ -f ".github/workflows/deploy-dev-testflight.yml" ]; then
        echo "✅ Workflow de desarrollo configurado"
    else
        echo "❌ Workflow de desarrollo no encontrado"
    fi
    
    # Verificar build.gradle para flavor dev
    if grep -q "dev.*applicationIdSuffix.*\.dev" android/app/build.gradle.kts; then
        echo "✅ Android dev flavor configurado"
    else
        echo "❌ Android dev flavor no configurado"
    fi
    
    # Verificar entitlements de dev
    if [ -f "ios/Runner/Runner-Dev.entitlements" ]; then
        echo "✅ iOS dev entitlements configurados"
    else
        echo "❌ iOS dev entitlements no encontrados"
    fi
    
    # Verificar app config
    if grep -q "Tocke Scanner Dev" lib/config/app_config.dart; then
        echo "✅ App config para desarrollo configurado"
    else
        echo "❌ App config para desarrollo no configurado"
    fi
    
    echo ""
}

# Función para mostrar diferencias entre dev y prod
show_differences() {
    echo "📊 Diferencias entre Development y Production:"
    echo ""
    echo "🔧 Development Build:"
    echo "   App Name: Staff Scanner Dev"
    echo "   Bundle ID: cl.tocketicket.staffscanner.dev"
    echo "   Base URL: api.dev.tocketicket.cl"
    echo "   Database: staffscanner_dev.db"
    echo "   Debug: enabled"
    echo "   TestFlight: Internal testers only"
    echo ""
    echo "🚀 Production Build:"
    echo "   App Name: Staff Scanner"
    echo "   Bundle ID: cl.tocketicket.staffscanner"
    echo "   Base URL: api.tocketicket.cl"
    echo "   Database: staffscanner.db"
    echo "   Debug: disabled"
    echo "   TestFlight: External testing available"
    echo ""
}

# Función para simular el flujo
simulate_workflow() {
    echo "🎬 Simulando flujo de desarrollo a TestFlight:"
    echo ""
    echo "1. 👨‍💻 Developer hace cambios en feature branch"
    echo "2. 📤 Push a feature/new-scanner-ui"
    echo "3. 🤖 GitHub Actions detecta cambios"
    echo "4. 🔨 Build iOS release con flavor dev"
    echo "5. 📱 Create IPA para cl.tocketicket.staffscanner.dev"
    echo "6. 🍎 Setup App Store Connect API"
    echo "7. 🚀 Upload a TestFlight automáticamente"
    echo "8. 📧 Internal testers reciben notificación"
    echo "9. 🧪 Testers pueden descargar Tocke Scanner Dev"
    echo ""
    echo "⏱️  Tiempo total estimado: 10-15 minutos"
    echo ""
}

# Función para mostrar comandos útiles
show_commands() {
    echo "📝 Comandos útiles para testing:"
    echo ""
    echo "🔍 Ver logs de GitHub Actions:"
    echo "   gh run list --workflow=deploy-dev-testflight.yml"
    echo "   gh run view --web"
    echo ""
    echo "📱 Build local para verificar:"
    echo "   flutter clean"
    echo "   flutter pub get"
    echo "   cd ios && pod install && cd .."
    echo "   flutter build ios --release --flavor dev --dart-define=ENVIRONMENT=dev"
    echo ""
    echo "🔧 Verificar configuración de Xcode:"
    echo "   open ios/Runner.xcworkspace"
    echo "   # Verificar Bundle ID: cl.tocketicket.staffscanner.dev"
    echo "   # Verificar Signing & Capabilities"
    echo ""
}

# Función principal
main() {
    case "$1" in
        "options")
            show_options
            ;;
        "commit")
            create_test_commit
            ;;
        "check")
            check_config
            ;;
        "diff")
            show_differences
            ;;
        "simulate")
            simulate_workflow
            ;;
        "commands")
            show_commands
            ;;
        "test"|"")
            echo "🧪 Flujo completo de testing para desarrollo:"
            echo ""
            check_config
            echo "---"
            show_differences
            echo "---"
            show_options
            echo "---"
            simulate_workflow
            ;;
        *)
            echo "Opciones disponibles:"
            echo "  options   - Mostrar formas de trigger TestFlight dev"
            echo "  commit    - Crear commit de prueba para trigger automático"
            echo "  check     - Verificar configuración"
            echo "  diff      - Mostrar diferencias dev vs prod"
            echo "  simulate  - Simular flujo completo"
            echo "  commands  - Comandos útiles para debugging"
            echo "  test      - Ejecutar verificación completa"
            echo ""
            echo "Ejemplo: ./scripts/test_dev_testflight.sh commit"
            ;;
    esac
}

main "$@"