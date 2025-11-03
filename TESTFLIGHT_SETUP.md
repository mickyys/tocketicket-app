# Configuración de TestFlight para GitHub Actions

## 🚀 Subida Automática a TestFlight

He configurado GitHub Actions para que suba automáticamente tu app a TestFlight cuando compiles en producción.

---

## 🔐 Secretos Adicionales Requeridos

Necesitas agregar estos **3 nuevos secretos** en tu repositorio de GitHub:

### 1. `APP_STORE_CONNECT_API_KEY_ID`
- **Descripción**: ID de tu API Key de App Store Connect
- **Ejemplo**: `2X9R4HXF34`
- **Dónde obtenerlo**: App Store Connect → Users and Access → Keys

### 2. `APP_STORE_CONNECT_ISSUER_ID`
- **Descripción**: Issuer ID de tu cuenta de App Store Connect
- **Ejemplo**: `69a6de70-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- **Dónde obtenerlo**: App Store Connect → Users and Access → Keys (arriba de la página)

### 3. `APP_STORE_CONNECT_API_KEY_BASE64`
- **Descripción**: Tu archivo .p8 de API Key codificado en base64
- **Cómo obtenerlo**:
  ```bash
  # Después de descargar el archivo .p8
  base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
  ```

---

## 📋 Pasos para Configurar App Store Connect API

### 1. Crear API Key en App Store Connect

1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. **Users and Access** → **Keys** → **App Store Connect API**
3. Click **"Generate API Key"**
4. **Name**: `GitHub Actions - Staff Scanner`
5. **Access**: `Developer` (mínimo requerido)
6. Click **"Generate"**

### 2. Obtener la Información

Después de crear la key:

```yaml
Key ID: 2X9R4HXF34 (ejemplo)
Issuer ID: 69a6de70-xxxx-xxxx-xxxx-xxxxxxxxxxxx (ejemplo)
Archivo: AuthKey_2X9R4HXF34.p8 (descargar)
```

⚠️ **IMPORTANTE**: Solo puedes descargar el archivo .p8 **UNA VEZ**. Guárdalo en un lugar seguro.

### 3. Configurar Secretos en GitHub

Ve a tu repositorio → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

```
APP_STORE_CONNECT_API_KEY_ID = 2X9R4HXF34
APP_STORE_CONNECT_ISSUER_ID = 69a6de70-xxxx-xxxx-xxxx-xxxxxxxxxxxx
APP_STORE_CONNECT_API_KEY_BASE64 = [contenido del archivo .p8 en base64]
```

---

## 🔄 Flujos de Trabajo Configurados

### 1. **Build iOS** (`build-ios.yml`)
- Compila la app
- **Producción**: Sube automáticamente a TestFlight
- **Desarrollo**: Solo genera artefacto

### 2. **Deploy TestFlight** (`deploy-testflight.yml`) - NUEVO
- Workflow dedicado solo para TestFlight
- Se ejecuta en:
  - Push a `main`
  - Tags `v*`
  - Manualmente con notas personalizadas

---

## 🚀 Cómo Usar

### Subida Automática:
```bash
# Al hacer push a main, se sube automáticamente
git push origin main
```

### Subida Manual con Notas:
1. Ve a **Actions** en GitHub
2. Selecciona **"Deploy to TestFlight"**
3. Click **"Run workflow"**
4. Personaliza las notas de versión
5. Click **"Run workflow"**

---

## 📱 Proceso de TestFlight

### Lo que hace GitHub Actions:
1. ✅ Compila la app en modo release
2. ✅ Genera el IPA firmado
3. ✅ Sube automáticamente a App Store Connect
4. ✅ Notifica el éxito

### Lo que sucede en App Store Connect:
1. 🔄 **Processing** (5-10 minutos): Apple procesa el build
2. ✅ **Ready for Testing**: Disponible para internal testing
3. 📧 **Notifications**: Se envían emails a testers internos
4. 🧪 **External Testing**: Puedes agregar external testers manualmente

---

## 📧 Gestión de Testers

### Internal Testers (automático):
- Se notifican automáticamente
- Pueden descargar inmediatamente
- Hasta 100 usuarios

### External Testers (manual):
- Requiere agregar manualmente en App Store Connect
- Pueden requerir review de Apple
- Hasta 10,000 usuarios

---

## 🔍 Monitoreo y Logs

### En GitHub Actions:
```
✅ Build successfully uploaded to TestFlight!
📱 Check App Store Connect for processing status
🔔 TestFlight users will be notified when ready
```

### En App Store Connect:
1. **TestFlight** → **iOS** → **Builds**
2. Verifica el estado: Processing → Ready for Testing
3. **Activity** para ver logs detallados

---

## ⚠️ Consideraciones Importantes

### Límites:
- **90 días**: Los builds expiran automáticamente
- **150 builds**: Máximo por app por año
- **30 días**: Review para external testing

### Troubleshooting:
- **"Invalid Bundle"**: Revisa signing y provisioning
- **"Missing Compliance"**: Configura export compliance
- **"Processing Failed"**: Revisa logs en App Store Connect

### Automatización vs Manual:
```yaml
Automático: Perfecto para builds de desarrollo frecuentes
Manual: Mejor para releases importantes con notas específicas
```

---

## 🧪 Testing del Setup

### 1. Test Básico:
```bash
# Hacer un small change y push
git add .
git commit -m "Test TestFlight upload"
git push origin main
```

### 2. Verificar en GitHub:
- Actions → Deploy to TestFlight → Ver logs

### 3. Verificar en App Store Connect:
- TestFlight → iOS → Builds → Ver nuevo build

---

## 📱 Configuración Completa de Secretos

Ahora necesitas **11 secretos en total**:

### Android (4):
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

### iOS Signing (4):
- `IOS_CERTIFICATE_BASE64`
- `IOS_CERTIFICATE_PASSWORD`
- `IOS_PROVISIONING_PROFILE_BASE64`

### TestFlight (3) - NUEVOS:
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_BASE64`

---

¡Con esta configuración, cada vez que hagas push a `main` o crees un tag, tu app se compilará y subirá automáticamente a TestFlight! 🚀📱