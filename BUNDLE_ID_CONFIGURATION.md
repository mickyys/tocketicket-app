# Configuración de Bundle ID y Team ID para Staff Scanner

## 📱 Configuración Actualizada

### Bundle IDs:
- **Producción**: `cl.tocketicket.staffscanner`
- **Desarrollo**: `cl.tocketicket.staffscanner.dev`

### Team ID:
- **Apple Developer Team ID**: `ZP8L46Q7JJ`

---

## 🔧 Configuración en Apple Developer Portal

### 1. Crear App IDs

Ve a [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list) y crea dos App IDs:

#### App ID de Producción:
```
Bundle ID: cl.tocketicket.staffscanner
Name: Staff Scanner
Description: Staff Scanner - Event validation app
```

#### App ID de Desarrollo:
```
Bundle ID: cl.tocketicket.staffscanner.dev
Name: Staff Scanner Dev
Description: Staff Scanner Development - Event validation app
```

### 2. Capabilities a Habilitar (en ambos App IDs):

- ✅ **App Groups**
  - `group.cl.tocketicket.staffscanner` (producción)
  - `group.cl.tocketicket.staffscanner.dev` (desarrollo)

- ✅ **Associated Domains**
  - Producción: `tocketicket.cl`, `www.tocketicket.cl`, `api.tocketicket.cl`
  - Desarrollo: `dev.tocketicket.cl`, `api-dev.tocketicket.cl`

- ✅ **Background App Refresh**

- ✅ **Data Protection** (Complete Protection)

- ✅ **Keychain Sharing**
  - `ZP8L46Q7JJ.cl.tocketicket.staffscanner` (producción)
  - `ZP8L46Q7JJ.cl.tocketicket.staffscanner.dev` (desarrollo)

- ✅ **Push Notifications**

- ✅ **Sign in with Apple** (opcional pero recomendado)

### 3. Crear Provisioning Profiles

#### Para Desarrollo:
```
Profile Name: Staff Scanner Development
App ID: cl.tocketicket.staffscanner.dev
Certificates: iOS Development
Devices: Todos los dispositivos de prueba
```

#### Para Producción:
```
Profile Name: Staff Scanner Production
App ID: cl.tocketicket.staffscanner
Certificates: iOS Distribution
Type: App Store
```

---

## 📄 Archivos Configurados

### ✅ Android (`android/app/build.gradle.kts`):
```gradle
applicationId = "cl.tocketicket.staffscanner"

productFlavors {
    dev {
        applicationIdSuffix = ".dev"
        resValue("string", "app_name", "Staff Scanner Dev")
    }
    prod {
        resValue("string", "app_name", "Staff Scanner")
    }
}
```

### ✅ iOS (`ios/Runner/Info.plist`):
```xml
<key>CFBundleDisplayName</key>
<string>Staff Scanner</string>
<key>CFBundleName</key>
<string>staffscanner</string>
```

### ✅ iOS Entitlements (`ios/Runner/Runner.entitlements`):
```xml
<!-- App Groups -->
<key>com.apple.security.application-groups</key>
<array>
    <string>group.cl.tocketicket.staffscanner</string>
</array>

<!-- Keychain Sharing -->
<key>keychain-access-groups</key>
<array>
    <string>ZP8L46Q7JJ.cl.tocketicket.staffscanner</string>
</array>
```

### ✅ Export Options (`ios/Runner/ExportOptions.plist`):
```xml
<key>teamID</key>
<string>ZP8L46Q7JJ</string>
<key>provisioningProfiles</key>
<dict>
    <key>cl.tocketicket.staffscanner</key>
    <string>Staff Scanner Production</string>
    <key>cl.tocketicket.staffscanner.dev</key>
    <string>Staff Scanner Development</string>
</dict>
```

### ✅ App Config (`lib/config/app_config.dart`):
```dart
static String get appName {
  switch (_environment) {
    case Environment.dev:
      return 'Staff Scanner Dev';
    case Environment.prod:
      return 'Staff Scanner';
  }
}

static String get packageName {
  switch (_environment) {
    case Environment.dev:
      return 'cl.tocketicket.staffscanner.dev';
    case Environment.prod:
      return 'cl.tocketicket.staffscanner';
  }
}
```

---

## 🚀 Comandos de Build

### Android:
```bash
# Desarrollo
flutter build apk --debug --flavor dev --dart-define=ENVIRONMENT=dev

# Producción
flutter build apk --release --flavor prod --dart-define=ENVIRONMENT=prod
flutter build appbundle --release --flavor prod --dart-define=ENVIRONMENT=prod
```

### iOS:
```bash
# Desarrollo
flutter build ios --debug --flavor dev --dart-define=ENVIRONMENT=dev

# Producción
flutter build ios --release --flavor prod --dart-define=ENVIRONMENT=prod
```

---

## 🔐 Secretos de GitHub Actions

Actualiza estos secretos en tu repositorio con los valores específicos para Staff Scanner:

### Android:
- `ANDROID_KEYSTORE_BASE64` - Keystore para cl.tocketicket.staffscanner
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

### iOS:
- `IOS_CERTIFICATE_BASE64` - Certificado para Team ZP8L46Q7JJ
- `IOS_CERTIFICATE_PASSWORD`
- `IOS_PROVISIONING_PROFILE_BASE64` - Para Staff Scanner profiles

---

## ✅ Checklist de Configuración

### Apple Developer Portal:
- [ ] App ID `cl.tocketicket.staffscanner` creado
- [ ] App ID `cl.tocketicket.staffscanner.dev` creado
- [ ] Capabilities habilitadas en ambos App IDs
- [ ] Provisioning Profile "Staff Scanner Development" creado
- [ ] Provisioning Profile "Staff Scanner Production" creado
- [ ] Certificados iOS válidos y descargados

### Proyecto:
- [x] Android applicationId actualizado
- [x] iOS Bundle Identifier configurado
- [x] Entitlements creados con Team ID correcto
- [x] ExportOptions.plist actualizado
- [x] App names actualizados
- [x] GitHub Actions workflows actualizados

### Servidor:
- [ ] Dominio `tocketicket.cl` configurado
- [ ] Archivo `apple-app-site-association` subido
- [ ] APIs `api.tocketicket.cl` y `api-dev.tocketicket.cl` funcionando

---

## 🔗 Associated Domains Setup

Crea este archivo en `https://tocketicket.cl/.well-known/apple-app-site-association`:

```json
{
    "applinks": {
        "apps": [],
        "details": [
            {
                "appID": "ZP8L46Q7JJ.cl.tocketicket.staffscanner",
                "paths": [
                    "/event/*",
                    "/ticket/*",
                    "/auth/*",
                    "/staff/*"
                ]
            },
            {
                "appID": "ZP8L46Q7JJ.cl.tocketicket.staffscanner.dev",
                "paths": [
                    "/event/*",
                    "/ticket/*",
                    "/auth/*",
                    "/staff/*"
                ]
            }
        ]
    }
}
```

**Importante**: Sirve este archivo con `Content-Type: application/json` sin extensión `.json`.

---

¡Tu aplicación Staff Scanner ahora está configurada con el Bundle ID `cl.tocketicket.staffscanner` y Team ID `ZP8L46Q7JJ`! 🎉