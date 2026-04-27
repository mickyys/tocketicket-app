# tocket_validator

A new Flutter project.

## Getting Started

# Tocket Validator - Aplicación Móvil

## 📱 Descripción
**Tocket Validator** es una aplicación móvil Flutter desarrollada para organizadores de eventos que permite validar códigos QR de entradas durante carreras o eventos deportivos. La aplicación forma parte del ecosistema Tocket Ticket y está diseñada para funcionar tanto online como offline.

## 🏗️ Arquitectura
La aplicación sigue la **Clean Architecture** con las siguientes capas:

### 📁 Estructura de Directorios
```
lib/
├── core/                          # Funcionalidades core compartidas
│   ├── constants/                 # Constantes de la aplicación
│   │   ├── app_constants.dart     # URLs, timeouts, configuraciones
│   │   └── app_colors.dart        # Paleta de colores y gradientes
│   ├── errors/                    # Manejo de errores
│   │   ├── failures.dart          # Clases de fallos
│   │   └── exceptions.dart        # Excepciones
│   ├── storage/                   # Almacenamiento local
│   │   └── database_helper.dart   # Helper de SQLite
│   ├── theme/                     # Temas de la aplicación
│   │   └── app_theme.dart         # Tema claro y oscuro
│   └── utils/                     # Utilidades
│       └── logger.dart            # Sistema de logging
├── features/                      # Funcionalidades por módulos
│   ├── auth/                      # Autenticación
│   ├── events/                    # Gestión de eventos
│   ├── scanner/                   # Escáner QR
│   ├── sync/                      # Sincronización offline
│   └── settings/                  # Configuraciones
└── main.dart                      # Punto de entrada
```

## 🚀 Funcionalidades Implementadas

### ✅ Completado
1. **Estructura base del proyecto**
   - Arquitectura Clean Architecture
   - Configuración de dependencias
   - Tema de la aplicación (claro/oscuro)
   - Sistema de logging

2. **Base de datos local (SQLite)**
   - Tablas: users, events, orders, validation_history, sync_queue
   - Índices optimizados
   - Helper de base de datos configurado

3. **Modelos de datos**
   - UserModel con serialización JSON
   - EventModel con serialización JSON
   - OrderModel con soporte offline
   - ValidationResult con estados de validación

4. **Pantallas base**
   - SplashScreen con animación
   - LoginScreen temporal
   - Configuración de navegación

5. **Configuración de API**
   - Endpoints basados en el backend Tocket Ticket
   - Constantes de configuración
   - Manejo de errores tipificado

## ▶️ Cómo Iniciar el Proyecto

### Requisitos previos
- Flutter SDK ≥ 3.35.0
- Android SDK con emulador configurado (o dispositivo físico)
- JDK 17 (Temurin recomendado)

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Verificar dispositivos disponibles
```bash
flutter devices
```

### 3. Ejecutar en Android

**Ver dispositivos disponibles:**
```bash
flutter devices
```

**Modo debug — entorno local** (backend en `localhost:8080`):
```bash
flutter run --flavor dev --debug -d emulator-5554 --dart-define=ENVIRONMENT=local
```

**Modo debug — entorno local con flavor prod:**
```bash
flutter run --flavor prod --debug -d <device-id> --dart-define=ENVIRONMENT=local
```

**Modo debug — entorno dev** (backend en `api.dev.tocketicket.cl`):
```bash
flutter run --flavor dev --debug -d emulator-5554 --dart-define=ENVIRONMENT=dev
```

**Modo debug — entorno prod** (backend en `api.tocketicket.cl`):
```bash
flutter run --flavor prod --debug -d <device-id> --dart-define=ENVIRONMENT=prod
```

**Modo release — entorno prod:**
```bash
flutter run --flavor prod --release -d <device-id> --dart-define=ENVIRONMENT=prod
```

#### Parámetros:
- `--flavor dev`: Usa el flavor de desarrollo (app name: "Tocke Staff Dev")
- `--flavor prod`: Usa el flavor de producción (app name: "Tocke Staff")
- `--debug`: Modo debug con logging y hot reload
- `--release`: Modo release optimizado
- `-d <device-id>`: Dispositivo o emulador destino
- `--dart-define=ENVIRONMENT=local|dev|prod`: Environnement del backend

### 4. Comandos durante la ejecución (`flutter run`)
| Tecla | Acción |
|-------|--------|
| `r` | Hot reload 🔥 |
| `R` | Hot restart |
| `q` | Detener la app |
| `d` | Desconectar (deja la app corriendo) |
| `h` | Ver todos los comandos disponibles |

### 5. Limpiar el proyecto
```bash
flutter clean && flutter pub get
```

---

## 🚀 Guía de Inicio Rápido

### Requisitos previos

1. **Backend local ejecutándose** en `localhost:8080`
2. **Emulador o dispositivo** conectado (ver con `flutter devices`)

### Iniciar app en entorno local

Para ejecutar la app conectándose al backend local (`localhost:8080`):

```bash
flutter run --flavor prod --debug -d <device-id> --dart-define=ENVIRONMENT=local
```

Ejemplo con emulador:
```bash
flutter run --flavor prod --debug -d emulator-5554 --dart-define=ENVIRONMENT=local
```

Ejemplo con dispositivo físico (iPhone):
```bash
flutter run --flavor prod --debug -d "iPhone de Hector" --dart-define=ENVIRONMENT=local
```

### Ambientes disponibles

| ENVIRONMENT | Backend URL | Descripción |
|-------------|-------------|-------------|
| `local` | `http://10.0.2.2:8080` (Android) / `http://127.0.0.1:8080` (iOS) | Backend local |
| `dev` | `https://api.dev.tocketicket.cl` | Desarrollo |
| `prod` | `https://api.tocketicket.cl` | Producción |

### Compilar APK con nombre personalizado

```bash
flutter build apk --flavor prod --release --dart-define=ENVIRONMENT=prod -v --build-name=1.0.5
```

O si necesitas renombrar el archivo generado:

```bash
# Compilarnormal
flutter build apk --flavor prod --release --dart-define=ENVIRONMENT=prod

# Renombrar
mv build/app/outputs/flutter-apk/app-prod-release.apk build/app/outputs/flutter-apk/tocke-1.0.5.apk
```

---

## 🔧 Tecnologías Utilizadas

### 📦 Dependencias Principales
- **flutter_bloc** (8.1.6) - Gestión de estado
- **dio** (5.7.0) - Cliente HTTP
- **sqflite** (2.4.0) - Base de datos SQLite
- **hive** (2.2.3) - Storage rápido
- **flutter_secure_storage** (9.2.2) - Almacenamiento seguro
- **mobile_scanner** (5.2.3) - Escáner QR
- **go_router** (14.2.7) - Navegación
- **connectivity_plus** (6.0.5) - Estado de conectividad
- **permission_handler** (11.3.1) - Permisos

## 🌐 Endpoints API Configurados

Basados en el backend Tocket Ticket:

### 🔐 Autenticación
- `POST /login` - Inicio de sesión
- `POST /login-otp` - Login con OTP
- `POST /request-otp` - Solicitar OTP

### 📅 Eventos
- `GET /events` - Listar eventos públicos
- `GET /organizer/events` - Eventos del organizador

### ✅ Validación
- `POST /tickets/validate-qr` - Validar código QR
- `GET /tickets/status/{code}` - Estado de ticket

## 🚀 Despliegue y Distribución

### � Build Android — Producción

#### APK (instalación directa)
```bash
flutter build apk --flavor prod --release --dart-define=ENVIRONMENT=prod
```
Salida: `build/app/outputs/flutter-apk/app-prod-release.apk`

#### AAB (Google Play Store)
```bash
flutter build appbundle --flavor prod --release --dart-define=ENVIRONMENT=prod
```
Salida: `build/app/outputs/bundle/prodRelease/app-prod-release.aab`

> **Requisito:** El archivo `android/key.properties` debe existir con las credenciales del keystore (ver `android/key.properties.example`).

---

### 🍎 Build iOS — Producción

#### Requisitos previos
- macOS con Xcode instalado
- Apple Developer account con provisioning profiles configurados
- `YOUR_TEAM_ID` en `ios/ExportOptions-TestFlight.plist` e `ios/ExportOptions.plist`

#### Compilación para Archive en Xcode (recomendado)

Usa este script en lugar de ejecutar `flutter build ios` manualmente. Incrementa automáticamente el build number en `pubspec.yaml`, compila y deja todo listo para archivar:

```bash
./scripts/build_ios_release.sh
```

Luego en Xcode: **Product → Archive**

> El script incrementa el `+N` del `pubspec.yaml` y regenera `ios/Flutter/Generated.xcconfig` con el nuevo `FLUTTER_BUILD_NUMBER`. Xcode lee ese valor al archivar.

#### Compilación manual (sin incrementar build number)
```bash
flutter build ios --dart-define=ENVIRONMENT=prod --release
```

#### 1. Compilar el archivo `.ipa`
```bash
flutter build ipa --flavor prod --release --dart-define=ENVIRONMENT=prod \
  --export-options-plist=ios/ExportOptions-TestFlight.plist
```
Salida: `build/ios/ipa/tocke.ipa`

#### 2. Subir a TestFlight (automático con el plist `upload`)
El plist `ExportOptions-TestFlight.plist` tiene `destination=upload`, por lo que el `.ipa` se sube directamente a App Store Connect al ejecutar el comando anterior.

#### 3. Solo exportar `.ipa` sin subir
```bash
flutter build ipa --flavor prod --release --dart-define=ENVIRONMENT=prod \
  --export-options-plist=ios/ExportOptions.plist
```

---

### �📱 TestFlight (iOS)
La aplicación está configurada para despliegue automático en TestFlight a través de GitHub Actions:

#### Build Automático
1. Ve a **Actions** → **🍎 Build iOS**
2. Configura:
   - **Environment**: `prod`
   - **Upload to TestFlight**: `true`
3. El build se sube automáticamente a TestFlight

#### Acceso a TestFlight
- **Internal Testing**: Hasta 100 testers
- **External Testing**: Hasta 10,000 testers (requiere revisión)
- **Link de invitación**: [Ver TESTFLIGHT_SETUP.md](TESTFLIGHT_SETUP.md)

#### Verificar Build
- [App Store Connect](https://appstoreconnect.apple.com)
- Sección: Tu App → TestFlight → iOS Builds

### 📦 Builds de Desarrollo
- **iOS Debug**: Disponible como artifact en GitHub Actions
- **Android**: Configurar workflow similar (pendiente)

Para configuración detallada, consulta: **[TESTFLIGHT_SETUP.md](TESTFLIGHT_SETUP.md)**

---

## 🎨 Diseño

### 🎨 Paleta de Colores (Tocket Ticket Brand)
- **Primario**: #6C63FF (violeta)
- **Secundario**: #00D4AA (turquesa)
- **Éxito**: #4CAF50 (verde)
- **Error**: #E53E3E (rojo)

## 📱 Estado del Proyecto

**✅ Base sólida completada** - La aplicación compila exitosamente y está lista para el desarrollo de funcionalidades específicas.

**Próximos pasos**: Implementar BLoCs, pantallas de autenticación, escáner QR, y funcionalidades offline.
