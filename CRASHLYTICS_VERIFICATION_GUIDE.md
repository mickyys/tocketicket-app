# Verificar Errores en Firebase Crashlytics

## 📊 Firebase Console

1. **Accede a Firebase Console**:
   - Ve a [https://console.firebase.google.com](https://console.firebase.google.com)
   - Selecciona tu proyecto: `tocke-staffscanner`

2. **Navega a Crashlytics**:
   - En el menú lateral izquierdo, busca "Crashlytics"
   - Haz clic en "Crashlytics"

3. **Dashboard de Crashlytics**:
   - **Crashes**: Errores fatales que causan que la app se cierre
   - **Non-fatals**: Errores capturados que no cierran la app
   - **ANRs**: Application Not Responding (solo Android)

4. **Filtros disponibles**:
   - Por versión de la app
   - Por dispositivo/OS
   - Por usuario específico
   - Por rango de fechas

## 🔍 Información detallada de cada error

Cuando haces clic en un error específico, puedes ver:

- **Stack trace completo**
- **Información del dispositivo**
- **Versión de la app**
- **Usuario afectado** (si configuraste setUserInfo)
- **Logs personalizados** (si usaste log())
- **Custom keys** (datos adicionales)

## ⏱️ Tiempos de aparición

- **Primera vez**: Puede tomar hasta **24 horas** en aparecer
- **Errores posteriores**: Aparecen en **tiempo real** (1-5 minutos)
- **Solo en Release**: Los errores de debug mode no se envían por defecto

## 🚨 Estados de errores

- **New**: Error nuevo, no revisado
- **Open**: Error conocido, en investigación  
- **Closed**: Error resuelto
- **Regressed**: Error que volvió a aparecer después de marcarse como resuelto

## 📱 Verificación en la app

También puedes verificar localmente si el error se envió:

```dart
// En tu código, después de enviar un error
try {
  // Código que puede fallar
  throw Exception('Error de prueba');
} catch (e, stackTrace) {
  AppLogger.error('Error capturado', e, stackTrace);
  
  // Log local para confirmar que se envió
  print('Error enviado a Crashlytics: $e');
}
```

## 🧪 Testing de Crashlytics

Para probar que funciona:

```dart
// Solo en debug - forzar un crash
if (kDebugMode) {
  CrashlyticsService.testCrash();
}

// Enviar error no fatal de prueba
CrashlyticsService.recordError(
  Exception('Error de prueba'),
  StackTrace.current,
  reason: 'Testing Crashlytics',
);
```

## 📧 Notificaciones

Puedes configurar alertas automáticas:

1. En Firebase Console → Crashlytics
2. Haz clic en "Alerts" 
3. Configura notificaciones por email para:
   - Nuevos crashes
   - Aumentos en crash rate
   - Errores en versiones específicas

## 🔄 Estados de la integración

**Actualmente en tu proyecto:**
- ❌ Crashlytics está **temporalmente deshabilitado** por conflictos de dependencias
- ✅ El código está **preparado** para cuando se reactive
- 📝 Los TODOs están marcados en el código para fácil reactivación

**Para reactivar:**
1. Descomentar las dependencias en `pubspec.yaml`
2. Resolver conflictos con `mobile_scanner`
3. Descomentar el código en `main.dart` y `login_page.dart`
4. Rehabilitar `crashlytics_service.dart`