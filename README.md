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

## 🎨 Diseño

### 🎨 Paleta de Colores (Tocket Ticket Brand)
- **Primario**: #6C63FF (violeta)
- **Secundario**: #00D4AA (turquesa)
- **Éxito**: #4CAF50 (verde)
- **Error**: #E53E3E (rojo)

## 📱 Estado del Proyecto

**✅ Base sólida completada** - La aplicación compila exitosamente y está lista para el desarrollo de funcionalidades específicas.

**Próximos pasos**: Implementar BLoCs, pantallas de autenticación, escáner QR, y funcionalidades offline.
