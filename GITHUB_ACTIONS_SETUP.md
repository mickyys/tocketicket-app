# 🚀 GitHub Actions - Configuración de Builds

## Workflows Disponibles

### 🤖 Android Build
- **Archivo**: `.github/workflows/android-build.yml`
- **Trigger**: Manual (workflow_dispatch)
- **Outputs**: APK y/o AAB
- **Entornos**: dev, prod

### 🍎 iOS Build  
- **Archivo**: `.github/workflows/ios-build.yml`
- **Trigger**: Manual (workflow_dispatch)
- **Outputs**: Debug app (dev), IPA (prod)
- **Entornos**: dev, prod

## 🔐 Secrets Requeridos

### Para Android (Producción)
Configura estos secrets en **GitHub Settings → Secrets and variables → Actions**:

```
KEYSTORE_PASSWORD      # Contraseña del keystore
KEY_PASSWORD          # Contraseña de la key
KEY_ALIAS            # Alias de la key (generalmente "upload")
```

**Comandos para configurar (desde terminal con GitHub CLI):**
```bash
gh secret set KEYSTORE_PASSWORD --body="TU_KEYSTORE_PASSWORD"
gh secret set KEY_PASSWORD --body="TU_KEY_PASSWORD"
gh secret set KEY_ALIAS --body="upload"
```

### Para iOS (Producción)
```
IOS_DIST_SIGNING_KEY           # Certificado de distribución (base64)
IOS_DIST_SIGNING_KEY_PASSWORD  # Contraseña del certificado
APPSTORE_ISSUER_ID             # App Store Connect Issuer ID
APPSTORE_KEY_ID                # App Store Connect Key ID
APPSTORE_PRIVATE_KEY           # App Store Connect Private Key
```

**Comandos para configurar:**
```bash
# Convertir certificado a base64 y configurar
base64 -i tu-certificado.p12 | gh secret set IOS_DIST_SIGNING_KEY --body-file -

gh secret set IOS_DIST_SIGNING_KEY_PASSWORD --body="TU_CERT_PASSWORD"
gh secret set APPSTORE_ISSUER_ID --body="TU_ISSUER_ID"
gh secret set APPSTORE_KEY_ID --body="TU_KEY_ID"
gh secret set APPSTORE_PRIVATE_KEY --body="TU_PRIVATE_KEY"
```

## 🔧 Configuración Inicial

### 1. Generar Android Keystore (Una sola vez)
```bash
# Generar keystore
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# El keystore se debe subir al repositorio en: android/app/upload-keystore.jks
```

### 2. Configurar iOS Certificates
1. **Apple Developer Account**: Crear cuenta activa
2. **App IDs**: Crear App IDs necesarios:
   - `cl.tocketicket.staffscanner` (Tocke Staff - Producción)
   - `cl.tocketicket.staffscanner.dev` (Tocke Staff - Desarrollo)
3. **Certificados**: Descargar certificados de distribución
4. **Provisioning Profiles**: Crear y descargar profiles
5. **Team ID**: Actualizar en `ios/ExportOptions.plist`

### 3. Configurar GitHub Secrets
Usar los comandos mostrados en la sección de **Secrets Requeridos** arriba.

## 🚀 Cómo Ejecutar los Workflows

### 🤖 Android Build
1. Ve a **Actions** en tu repositorio de GitHub
2. Selecciona **"🤖 Build Android"**
3. Click **"Run workflow"**
4. Selecciona parámetros:
   - **Environment**: `dev` o `prod`
   - **Build Type**: `apk`, `aab`, o `both`
5. Click **"Run workflow"**

### 🍎 iOS Build
1. Ve a **Actions** en tu repositorio de GitHub
2. Selecciona **"🍎 Build iOS"**
3. Click **"Run workflow"**
4. Selecciona parámetros:
   - **Environment**: `dev` o `prod`
5. Click **"Run workflow"**

## 📱 URLs por Entorno

Los builds usarán automáticamente las URLs configuradas en `lib/config/app_config.dart`:

- **Dev**: https://api-dev.tocketicket.cl
- **Prod**: https://api.tocketicket.cl

## 📦 Artefactos Generados

Los archivos compilados se suben automáticamente como artefactos y se pueden descargar desde la página del workflow.

### Android
- `tocke-dev-apk` / `tocke-prod-apk`
- `tocke-dev-aab` / `tocke-prod-aab`

### iOS  
- `tocke-dev-ios-debug` (solo dev)
- `tocke-prod-ipa` (solo prod)

## ⚠️ Notas Importantes

1. **iOS requiere macOS runners**: Los builds de iOS solo funcionan en runners de macOS
2. **Certificados iOS**: Para producción necesitas certificados válidos de Apple Developer
3. **Team ID**: Actualiza el Team ID en `ios/ExportOptions.plist`
4. **Primera ejecución**: Puede tomar más tiempo debido al cache inicial

## 🔍 Troubleshooting

### Android
- Verificar que `upload-keystore.jks` está en `android/app/`
- Validar que todos los secrets de Android están configurados

### iOS
- Verificar certificados de código signing
- Confirmar que provisioning profiles están actualizados
- Verificar Team ID en ExportOptions.plist

## 📝 Personalización

Puedes modificar los workflows para:
- Cambiar versiones de Flutter/Xcode
- Agregar tests automáticos antes del build
- Configurar notificaciones en Slack/Discord
- Añadir deployment automático a stores
- Configurar builds automáticos en push/PR

## 📚 Recursos Adicionales

- [Flutter Build Documentation](https://docs.flutter.dev/deployment)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Android Developer Documentation](https://developer.android.com/studio/publish)