# Configuración de Debug - TocketTicket App

## Credenciales por defecto

Para facilitar el desarrollo y testing, se han configurado las siguientes credenciales por defecto:

- **Email:** `hamp.martinez@yopmail.com`
- **Password:** `12345678`

## Configuración de Debug

### Archivo de configuración
La configuración se encuentra en `lib/core/config/debug_config.dart`:

```dart
class DebugConfig {
  static const String debugEmail = 'hamp.martinez@yopmail.com';
  static const String debugPassword = '12345678';
  static const bool enableDebugMode = true; // Cambiar a false en producción
}
```

### Cómo funciona

1. **Campos pre-rellenados**: Cuando `enableDebugMode` es `true`, los campos de email y password en la pantalla de login aparecen automáticamente rellenados con las credenciales de debug.

2. **Indicador visual**: Un banner naranja aparece en la pantalla de login indicando que el modo debug está activado y mostrando el email que está pre-rellenado.

3. **Auto-login**: Si no hay token JWT disponible, la app automáticamente:
   - Hace login con las credenciales de debug
   - Obtiene el token JWT
   - Usa ese token para las requests subsiguientes

4. **Logs de debug**: El sistema muestra logs detallados cuando está en modo debug:
   ```
   🐛 DEBUG: No hay token disponible, autenticando con credenciales de debug...
   ✅ SUCCESS: Autenticación exitosa con hamp.martinez@yopmail.com
   🐛 DEBUG: Iniciando obtención de eventos...
   🐛 DEBUG: Respuesta HTTP: 200
   ✅ SUCCESS: 5 eventos obtenidos exitosamente
   ```

## Beneficios para desarrollo

### 🚀 **Experiencia de desarrollo mejorada:**
- **Campos pre-rellenados**: No más tipeo manual de credenciales
- **Indicador visual**: Banner claro que muestra el modo debug activo
- **Un solo clic**: Solo presiona "Iniciar Sesión" y ya estás dentro
- **Feedback inmediato**: Logs detallados para debugging

### 🔄 **Flujos simplificados:**
1. **Desarrollo normal**: Abrir app → Ver campos pre-rellenados → Clic en login → ¡Listo!
2. **Testing de logout**: Logout → Campos siguen pre-rellenados → Login rápido
3. **Testing de funcionalidades**: Acceso inmediato sin interrupciones de autenticación

## Configuración de URLs

```dart
static const String baseUrl = 'http://localhost:8080';
static const String loginUrl = '$baseUrl/login';
static const String organizerEventsUrl = '$baseUrl/organizer/events';
```

## Configuración de red

```dart
static const int defaultPageSize = 50;           // Eventos por página
static const int attendeesPageSize = 100;        // Asistentes por página
static const Duration networkTimeout = Duration(seconds: 30);
```

## Habilitar/Deshabilitar modo debug

### Para desarrollo
```dart
static const bool enableDebugMode = true;
static const bool enableDebugLogs = true;
```

### Para producción
```dart
static const bool enableDebugMode = false;
static const bool enableDebugLogs = false;
```

## Flujo de autenticación

### Con token existente
```
1. AuthService.getAccessToken() → Retorna token válido
2. Usar token para request
```

### Sin token (modo debug habilitado)
```
1. AuthService.getAccessToken() → Retorna null
2. DebugConfig.enableDebugMode → true
3. POST /login con credenciales de debug
4. Extraer token de respuesta
5. Usar token para request
```

### Sin token (modo debug deshabilitado)
```
1. AuthService.getAccessToken() → Retorna null
2. DebugConfig.enableDebugMode → false
3. Throw Exception('Not authenticated and debug mode is disabled')
```

## Ejemplos de uso

### EventRemoteDataSource
```dart
final events = await eventRemoteDataSource.getEvents();
// Si no hay token, automáticamente hace login con credenciales debug
```

### Logs esperados
```bash
🐛 DEBUG: No hay token disponible, autenticando con credenciales de debug...
✅ SUCCESS: Autenticación exitosa con hamp.martinez@yopmail.com
🐛 DEBUG: Iniciando obtención de eventos...
🐛 DEBUG: Respuesta HTTP: 200
✅ SUCCESS: 3 eventos obtenidos exitosamente
```

## Seguridad

⚠️ **IMPORTANTE**: Asegúrate de cambiar `enableDebugMode` a `false` antes de:
- Compilar para producción
- Subir a stores (App Store, Google Play)
- Hacer releases públicos

## Testing manual

1. ~~Borrar token JWT del almacenamiento local~~ ✅ **Ya no es necesario**
2. Abrir la app
3. Los campos de login aparecerán **pre-rellenados** con:
   - **Email:** `hamp.martinez@yopmail.com`
   - **Password:** `12345678`
4. Verás un **banner naranja** que indica "MODO DEBUG ACTIVADO"
5. Solo haz clic en "Iniciar Sesión" y listo!

### Apariencia visual del modo debug:
```
┌─────────────────────────────────────────┐
│ 🐛 MODO DEBUG ACTIVADO                  │
│ Campos pre-rellenados: hamp.martinez... │
└─────────────────────────────────────────┘
Email: [hamp.martinez@yopmail.com    ]
Password: [12345678                  ]
[Iniciar Sesión]
```

## Endpoints utilizados

- `POST /login` - Autenticación con credenciales debug
- `GET /organizer/events?page=1&pageSize=50` - Obtener eventos del organizador
- `GET /organizer/events/{id}/attendees?page=X&pageSize=100` - Obtener asistentes

## Troubleshooting

### Error: "Debug authentication failed"
- Verificar que el backend esté corriendo en `localhost:8080`
- Verificar que las credenciales existan en la base de datos
- Verificar que el usuario sea un organizador válido

### Error: "Not authenticated and debug mode is disabled"
- Cambiar `DebugConfig.enableDebugMode` a `true`
- O configurar un token JWT válido manualmente