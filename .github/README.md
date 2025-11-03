# GitHub Actions para Tocke Validator

Este repositorio incluye flujos de trabajo automatizados de GitHub Actions para compilar la aplicación Flutter tanto para Android como iOS, con soporte para entornos de desarrollo y producción.

## Flujos de Trabajo Configurados

### 1. Tests (`test.yml`)
- Se ejecuta en todos los push y pull requests
- Ejecuta análisis de código y tests unitarios
- Genera reporte de cobertura

### 2. Build Android (`build-android.yml`)
- Compila la aplicación para Android
- Soporta entornos `dev` y `prod`
- Genera APK para desarrollo y APK/AAB para producción
- Se ejecuta automáticamente en push/PR y manualmente

### 3. Build iOS (`build-ios.yml`)
- Compila la aplicación para iOS
- Soporta entornos `dev` y `prod`
- Genera aplicación para desarrollo e IPA para producción
- Se ejecuta automáticamente en push/PR y manualmente

### 4. Build and Deploy (`build-and-deploy.yml`)
- Orquesta los builds para ambas plataformas
- Se ejecuta en push a `main` o en tags
- Permite ejecución manual con selección de plataforma

## Configuración de Secretos

Para que los flujos de trabajo funcionen correctamente, necesitas configurar los siguientes secretos en tu repositorio de GitHub:

### Android (Producción)
```
ANDROID_KEYSTORE_BASE64: [keystore codificado en base64]
ANDROID_KEYSTORE_PASSWORD: [contraseña del keystore]
ANDROID_KEY_PASSWORD: [contraseña de la key]
ANDROID_KEY_ALIAS: [alias de la key]
```

### iOS (Producción)
```
IOS_CERTIFICATE_BASE64: [certificado .p12 codificado en base64]
IOS_CERTIFICATE_PASSWORD: [contraseña del certificado]
IOS_PROVISIONING_PROFILE_BASE64: [perfil de aprovisionamiento codificado en base64]
```

## Configuración de Entornos

### Android
La aplicación soporta dos flavors:
- **dev**: `cl.tocke.tocke_validator.dev` - Para desarrollo
- **prod**: `cl.tocke.tocke_validator` - Para producción

### iOS
La aplicación soporta dos schemes:
- **dev**: Para desarrollo
- **prod**: Para producción

## Cómo Usar

### Ejecución Automática
Los flujos se ejecutan automáticamente en:
- Push a `main`, `develop` o branches `feature/*`
- Pull requests a `main` o `develop`
- Push de tags que empiecen con `v`

### Ejecución Manual
Puedes ejecutar manualmente los flujos desde la pestaña "Actions" en GitHub:

1. **Build Android/iOS**: Permite elegir el entorno (dev/prod)
2. **Build and Deploy**: Permite elegir la plataforma (android/ios/both) y entorno

### Comandos Locales

Para compilar localmente:

```bash
# Android - Desarrollo
flutter build apk --debug --flavor dev --dart-define=ENVIRONMENT=dev

# Android - Producción
flutter build apk --release --flavor prod --dart-define=ENVIRONMENT=prod
flutter build appbundle --release --flavor prod --dart-define=ENVIRONMENT=prod

# iOS - Desarrollo
flutter build ios --debug --flavor dev --dart-define=ENVIRONMENT=dev

# iOS - Producción
flutter build ios --release --flavor prod --dart-define=ENVIRONMENT=prod
```

## Artefactos Generados

Los builds exitosos generan artefactos que se pueden descargar:

### Desarrollo
- `tocke-android-dev-apk`: APK de desarrollo (30 días de retención)
- `tocke-ios-dev-app`: App iOS de desarrollo (30 días de retención)

### Producción
- `tocke-android-prod-apk`: APK de producción (90 días de retención)
- `tocke-android-prod-aab`: AAB para Google Play (90 días de retención)
- `tocke-ios-prod-ipa`: IPA para App Store (90 días de retención)

## Preparación para Producción

### Android
1. Genera un keystore para firma:
   ```bash
   keytool -genkey -v -keystore tocke-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias tocke
   ```

2. Codifica el keystore en base64:
   ```bash
   base64 tocke-keystore.jks | pbcopy
   ```

3. Agrega los secretos en GitHub con los valores correspondientes

### iOS
1. Exporta tu certificado de desarrollo/distribución como .p12
2. Codifica en base64:
   ```bash
   base64 certificate.p12 | pbcopy
   ```

3. Codifica tu perfil de aprovisionamiento:
   ```bash
   base64 profile.mobileprovision | pbcopy
   ```

4. Agrega los secretos en GitHub

5. Actualiza `ExportOptions.plist` con tu Team ID y nombres de perfiles correctos