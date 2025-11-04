# Firebase Crashlytics - Guía de Configuración

Firebase Crashlytics ha sido agregado exitosamente al proyecto. Sin embargo, necesitas completar la configuración con tus credenciales reales de Firebase.

## 📋 Pasos Pendientes

### 1. Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Crea un nuevo proyecto o selecciona uno existente
3. Agrega tu aplicación iOS y Android al proyecto

### 2. Configurar Firebase CLI

```bash
# Instalar Firebase CLI si no lo tienes
npm install -g firebase-tools

# Iniciar sesión en Firebase
firebase login

# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase para tu proyecto Flutter
flutterfire configure
```

### 3. Archivos de Configuración Requeridos

Después de ejecutar `flutterfire configure`, necesitarás estos archivos:

#### Android
- `/android/app/google-services.json` - Generado automáticamente por FlutterFire CLI

#### iOS  
- `/ios/Runner/GoogleService-Info.plist` - Generado automáticamente por FlutterFire CLI
- `/lib/firebase_options.dart` - Generado automáticamente por FlutterFire CLI

### 4. Configuración Adicional para iOS

En Xcode, agrega las siguientes capacidades al target de tu aplicación:

1. Abre `/ios/Runner.xcworkspace` en Xcode
2. Selecciona el target de tu aplicación
3. Ve a la pestaña "Signing & Capabilities"
4. Haz clic en "+ Capability" y agrega:
   - **Push Notifications** (para notificaciones)

### 5. Verificar Configuración

Una vez completada la configuración, puedes verificar que Crashlytics funciona:

```dart
// En cualquier parte de tu código, puedes usar:
import 'package:tocke/core/services/crashlytics_service.dart';

// Registrar un error
CrashlyticsService.recordError(
  Exception('Error de prueba'),
  StackTrace.current,
  reason: 'Prueba de Crashlytics',
);

// Establecer información del usuario
CrashlyticsService.setUserInfo(
  id: 'user123',
  email: 'usuario@ejemplo.com',
  name: 'Usuario Ejemplo',
);

// Registrar eventos personalizados
CrashlyticsService.recordCustomEvent('button_pressed', {
  'screen': 'login',
  'timestamp': DateTime.now().toIso8601String(),
});
```

## 🚀 Funcionalidades Implementadas

### ✅ CrashlyticsService
- Captura automática de errores de Flutter
- Registro de errores personalizados
- Establecimiento de información del usuario
- Logs personalizados
- Eventos personalizados

### ✅ Integración con Logger
- Los errores y errores fatales del `AppLogger` se envían automáticamente a Crashlytics
- Mantiene el logging local existente

### ✅ Configuración por Entorno
- Crashlytics se deshabilita automáticamente en modo debug
- Solo recopila datos en producción

## 📱 Uso en la Aplicación

### Errores Automáticos
```dart
// Los errores de Flutter se capturan automáticamente
throw Exception('Este error se enviará a Crashlytics');
```

### Errores Manuales
```dart
try {
  // Código que puede fallar
} catch (e, stackTrace) {
  AppLogger.error('Error en operación', e, stackTrace);
  // Se envía automáticamente a Crashlytics
}
```

### Información de Usuario
```dart
// Después del login
CrashlyticsService.setUserInfo(
  id: user.id,
  email: user.email,
  name: user.name,
);
```

### Eventos Personalizados
```dart
// Tracking de eventos importantes
CrashlyticsService.recordCustomEvent('qr_scanned', {
  'event_id': eventId,
  'scan_successful': true,
  'timestamp': DateTime.now().toIso8601String(),
});
```

## 🔧 Testing

Para probar Crashlytics en desarrollo (solo en debug):

```dart
// Forzar un crash para testing
CrashlyticsService.testCrash();
```

## 📊 Dashboard

Una vez configurado, podrás ver los crashes y análisis en:
- [Firebase Console](https://console.firebase.google.com) → Tu Proyecto → Crashlytics

## ⚠️ Notas Importantes

1. **Privacidad**: Crashlytics recopila datos de crashes. Asegúrate de que cumples con las políticas de privacidad.
2. **GDPR/CCPA**: Considera implementar opt-out para usuarios en regiones con regulaciones estrictas.
3. **Debug Mode**: Crashlytics está deshabilitado en modo debug para evitar ruido en los reportes.
4. **Primera Compilación**: Los primeros crashes pueden tomar hasta 24 horas en aparecer en la consola.

## 🆘 Solución de Problemas

### Error: "No Firebase App"
- Asegúrate de que `firebase_options.dart` existe y está configurado correctamente
- Verifica que `Firebase.initializeApp()` se llama antes que cualquier otro servicio de Firebase

### Crashes no aparecen en consola
- Verifica que estás en modo release (`flutter build apk --release`)
- Los crashes en debug mode no se envían por defecto
- Puede tomar hasta 24 horas para el primer reporte

### Problemas de build
- Limpia el proyecto: `flutter clean && flutter pub get`
- En Android, verifica que `google-services.json` está en `android/app/`
- En iOS, verifica que `GoogleService-Info.plist` está agregado correctamente en Xcode