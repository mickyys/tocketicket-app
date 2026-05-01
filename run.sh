#!/bin/bash

# ============================================
# Script para iniciar Tocke Validator con parámetros configurables
# ============================================

# Valores por defecto
ENV="dev"
API_URL="https://api.tocketicket.cl"
GOOGLE_CLIENT_ID="1054622389903-o3rr07gqdm9k395e3roc33buqs033v9f.apps.googleusercontent.com"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar uso
usage() {
    echo -e "${BLUE}Uso: $0 [opciones]${NC}"
    echo ""
    echo "Opciones:"
    echo "  -e, --env ENTORNO     Entorno: local, dev, prod (default: dev)"
    echo "  -u, --url URL         URL personalizada del API"
    echo "  -g, --google-id ID    Client ID de Google Sign-In"
    echo "  -h, --help            Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0                                    # Iniciar con valores por defecto"
    echo "  $0 -e local                           # Entorno local"
    echo "  $0 -e local -u http://localhost:8080  # Local con API personalizada"
    echo "  $0 -e dev -u https://api.test.cl      # Dev con API personalizada"
    exit 1
}

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--env)
            ENV="$2"
            shift 2
            ;;
        -u|--url)
            API_URL="$2"
            shift 2
            ;;
        -g|--google-id)
            GOOGLE_CLIENT_ID="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Opción desconocida: $1${NC}"
            usage
            ;;
    esac
done

# Validar entorno
case $ENV in
    local|dev|prod|development|production)
        ;;
    *)
        echo -e "${RED}Entorno inválido: $ENV. Use: local, dev, o prod${NC}"
        exit 1
        ;;
esac

# Normalizar entorno
case $ENV in
    development) ENV="dev" ;;
    production) ENV="prod" ;;
esac

# Construir comando flutter
FLUTTER_CMD="flutter run"

# Agregar --dart-define para cada variable
if [ "$ENV" != "dev" ]; then
    FLUTTER_CMD="$FLUTTER_CMD --dart-define=ENVIRONMENT=$ENV"
fi

if [ -n "$API_URL" ]; then
    FLUTTER_CMD="$FLUTTER_CMD --dart-define=API_URL=$API_URL"
fi

if [ -n "$GOOGLE_CLIENT_ID" ]; then
    FLUTTER_CMD="$FLUTTER_CMD --dart-define=GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID"
fi

# Mostrar configuración
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Tocke Validator - Inicializando${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}Entorno:${NC}      $ENV"
echo -e "${YELLOW}API URL:${NC}      ${API_URL:-'(default del entorno)'}"
echo -e "${YELLOW}Google ID:${NC}    ${GOOGLE_CLIENT_ID:-'(default hardcodeado)'}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Comando:${NC} $FLUTTER_CMD"
echo ""

# Ejecutar
eval $FLUTTER_CMD