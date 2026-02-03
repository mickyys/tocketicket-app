# 🍎 TestFlight Integration Guide

## Overview
Este proyecto está configurado para subir builds de iOS automáticamente a TestFlight usando GitHub Actions.

## Configuración Requerida

### 1. Secrets de GitHub
Asegúrate de que los siguientes secrets estén configurados en tu repositorio:

```
APPSTORE_ISSUER_ID       # ID del emisor de App Store Connect
APPSTORE_KEY_ID          # ID de la clave API
APPSTORE_PRIVATE_KEY     # Clave privada API (formato .p8)
IOS_DIST_SIGNING_KEY     # Certificado de distribución (formato .p12 base64)
IOS_DIST_SIGNING_KEY_PASSWORD # Contraseña del certificado .p12
```

### 2. App Store Connect API Key
1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Navega a Users and Access > Integrations > App Store Connect API
3. Genera una nueva clave API con rol **App Manager**
4. Descarga la clave `.p8` y guarda el **Key ID** e **Issuer ID**

### 3. Certificados de Distribución
1. Ve a [Apple Developer](https://developer.apple.com)
2. Certificates, Identifiers & Profiles > Certificates
3. Crea un certificado de **iOS Distribution**
4. Descarga e instala en Keychain Access
5. Exporta como `.p12` y convierte a base64:
   ```bash
   base64 -i certificate.p12 | pbcopy
   ```

## Uso del Workflow

### Build Manual
1. Ve a la tab **Actions** en GitHub
2. Selecciona el workflow **🍎 Build iOS**
3. Clic en **Run workflow**
4. Configura:
   - **Environment**: `prod` (para TestFlight)
   - **Upload to TestFlight**: `true`

### Build Automático
El workflow se puede configurar para ejecutarse automáticamente en:
- Push a branch `main` (producción)
- Tags de versión
- Pull requests merged

## Proceso de TestFlight

### Flujo Completo
1. **Build**: Se compila la app en modo Release
2. **Archive**: Se crea un archivo `.xcarchive`
3. **Export**: Se genera el archivo `.ipa`
4. **Upload**: Se sube automáticamente a TestFlight
5. **Processing**: Apple procesa el build (~10-15 minutos)
6. **Testing**: El build está disponible para testers

### Verificación en App Store Connect
1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Navega a tu app > TestFlight
3. Verifica que el build aparezca en **iOS Builds**
4. Una vez procesado, distribúyelo a testers

## Configuración de Testers

### Internal Testing
- Hasta 100 usuarios
- Acceso inmediato después del procesamiento
- No requiere revisión de Apple

### External Testing
- Hasta 10,000 usuarios
- Requiere revisión de Apple (24-48 horas)
- Más control sobre distribución

## Troubleshooting

### Errores Comunes

#### "Invalid Bundle ID"
- Verifica que el Bundle ID en `Info.plist` coincida con App Store Connect
- Asegúrate de que el Provisioning Profile sea correcto

#### "Certificate not found"
- Verifica que el certificado de distribución esté válido
- Confirma que el secret `IOS_DIST_SIGNING_KEY` esté en formato base64

#### "API Key invalid"
- Verifica que los secrets de App Store Connect API estén correctos
- Confirma que la clave API tenga permisos de **App Manager**

#### "Build already exists"
- Incrementa el build number en `Info.plist`
- O usa el script `increment_version.sh`

### Logs Útiles
```bash
# Ver status del workflow
gh run list --workflow="ios-build.yml"

# Ver logs de la última ejecución
gh run view --log
```

## Automatización Adicional

### Auto-increment Version
Agrega este paso antes del build:
```yaml
- name: 📈 Auto-increment build number
  run: |
    cd ios
    agvtool next-version -all
```

### Slack Notifications
```yaml
- name: 📢 Notify Slack on Success
  if: success()
  uses: 8398a7/action-slack@v3
  with:
    status: success
    text: "🎉 New TestFlight build available!"
```

## Monitoreo

### GitHub Actions Dashboard
- Ve el estado de todos los builds
- Revisa logs detallados de errores
- Monitorea tiempo de ejecución

### App Store Connect
- Estado del procesamiento
- Crash reports
- Usage analytics

## Próximos Pasos

1. **Configurar auto-deploy** en push a `main`
2. **Integrar tests** antes del build
3. **Configurar notificaciones** de build exitoso
4. **Automatizar release notes** desde commits

---

Para más información, consulta la [documentación oficial de TestFlight](https://developer.apple.com/testflight/).