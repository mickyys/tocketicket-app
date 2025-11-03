#!/bin/bash

# Script para probar el workflow de GitHub Actions
# Este script hace un cambio menor y dispara el workflow

echo "🚀 Probando workflow de GitHub Actions..."

# Crear un archivo de prueba con timestamp
echo "# Workflow Test - $(date)" > WORKFLOW_TEST.md
echo "Estado: Probando workflow con timeout mejorado y configuración robusta" >> WORKFLOW_TEST.md
echo "Fecha: $(date)" >> WORKFLOW_TEST.md

# Añadir al git
git add WORKFLOW_TEST.md
git commit -m "test: probar workflow con configuración mejorada

- Añadido timeout de 90 minutos para iOS
- Configurado fail-fast: false
- Mejorado setup de Flutter con logging
- Actualizado Xcode a versión 15.4"

echo "📤 Haciendo push para disparar el workflow..."
git push origin main

echo "✅ Push completado. El workflow debería ejecutarse ahora."
echo "🔗 Puedes ver el progreso en: https://github.com/mickyys/tocketicket-app/actions"