# Implementación del cURL /organizer/events en Flutter

## Resumen de cambios realizados

### 1. EventRemoteDataSource - Implementación de la llamada HTTP real

**Archivo:** `lib/features/events/data/datasources/event_remote_data_source.dart`

**Cambios principales:**
- Reemplazó los datos mock con una llamada HTTP real al endpoint `/organizer/events`
- Implementó autenticación JWT usando `AuthService.getAccessToken()`
- Agregó paginación con `page=1&pageSize=50`
- Mapeo de la respuesta JSON de la API a los modelos de Flutter
- Manejo de errores HTTP (401 para no autorizado, otros códigos de error)
- Funciones auxiliares para extraer datos de la respuesta compleja:
  - `_extractLocationFromAddress()`: Extrae ubicación de la dirección
  - `_formatFullAddress()`: Formatea la dirección completa
  - `_extractImageUrl()`: Extrae URL de imagen del carrusel o tarjeta

### 2. EventBloc - Mejorado con manejo de errores

**Archivo:** `lib/features/events/presentation/bloc/event_bloc.dart`

**Mejoras implementadas:**
- Importó `../../../../core/error/failures.dart` para manejo específico de errores
- Mejoró `_onFetchEvents()` con:
  - Manejo específico de diferentes tipos de fallos (ServerFailure, NetworkFailure, ValidationFailure)
  - Mensajes de error en español más descriptivos
  - Try-catch para excepciones no controladas
- Mejoró `_onSynchronizeEventAttendees()` con el mismo enfoque de manejo de errores

### 3. OrganizerEventsPage - UI mejorada

**Archivo:** `lib/features/events/presentation/pages/organizer_events_page.dart`

**Mejoras en la interfaz:**
- Estado de error mejorado con:
  - Icono de error visual
  - Mensaje descriptivo del error
  - Botón "Reintentar" para recargar eventos
- Estado vacío mejorado con:
  - Icono indicativo
  - Mensaje motivacional
  - Botón para crear primer evento

### 4. Ejemplo de uso completo

**Archivo:** `lib/features/events/presentation/example_usage.dart`

Incluye:
- Configuración completa de dependencias con `MultiRepositoryProvider`
- Documentación del cURL request y respuesta esperada
- Explicación del flujo de datos siguiendo Clean Architecture

## Especificaciones técnicas

### cURL Request
```bash
curl -X GET "http://localhost:8080/organizer/events?page=1&pageSize=50" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

### Mapeo de datos API → Flutter

| Campo API | Campo Flutter | Transformación |
|-----------|---------------|----------------|
| `id` | `id` | Directo |
| `name` | `name` | Directo |
| `description` | `description` | Con fallback a string vacío |
| `startDate` | `startDate` | Parsing de DateTime |
| `endDate` | `endDate` | Parsing de DateTime |
| `address.street + commune` | `location` | Concatenación |
| `address` completa | `address` | Formateo completo |
| `images.carousel[0].url` | `imageUrl` | Extracción de primera imagen |
| `organizer.name` | `organizerId` | Uso del nombre del organizador |
| `status == 'active'` | `isActive` | Conversión booleana |
| `ticketsSold` | `ticketsSold` | Con fallback a 0 |
| `maxCapacity` | `totalTickets` | Con fallback a 0 |
| `status` | `status` | Directo |

### Estados del Bloc

1. **EventInitial**: Estado inicial
2. **EventLoading**: Cargando eventos
3. **EventLoaded**: Eventos cargados exitosamente
4. **EventError**: Error al cargar eventos
5. **SyncInProgress**: Sincronizando asistentes de un evento específico
6. **SyncSuccess**: Sincronización exitosa
7. **SyncFailure**: Error en sincronización

### Manejo de errores

- **ServerFailure**: "Error del servidor. Intenta de nuevo."
- **NetworkFailure**: "Error de conexión. Verifica tu internet."
- **ValidationFailure**: Muestra el mensaje específico del error
- **Excepción general**: "Error inesperado: [detalles]"

## Flujo de datos completo

```
UI (OrganizerEventsPage)
↓ dispatch FetchEvents
EventBloc
↓ call
GetEvents UseCase
↓ call
EventRepositoryImpl
↓ call
EventRemoteDataSource
↓ HTTP GET
API /organizer/events
```

## Consideraciones de seguridad

1. **Autenticación**: Cada request incluye el JWT token del usuario autenticado
2. **Autorización**: El endpoint requiere permisos de organizador
3. **Error handling**: No expone información sensible en mensajes de error
4. **Token expiration**: Maneja respuestas 401 apropiadamente

## Próximos pasos sugeridos

1. Implementar paginación infinita en la UI
2. Agregar filtros por estado de evento
3. Implementar cache local para mejorar performance
4. Agregar pull-to-refresh en toda la lista
5. Implementar navegación a detalles de evento