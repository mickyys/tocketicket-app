# Testing Development Builds en TestFlight

## 🧪 Configuración Completada para DEV → TestFlight

Ahora tanto **desarrollo** como **producción** suben automáticamente a TestFlight, pero como aplicaciones separadas.

---

## 📱 Dos Apps en TestFlight

### 🔧 **Staff Scanner Dev** (`cl.tocketicket.staffscanner.dev`)
- **Trigger**: Push a `develop` o `feature/*` branches
- **Propósito**: Testing diario, features en desarrollo
- **Testers**: Internal testers (desarrollo)
- **Retention**: 7 días de artefactos

### 🚀 **Staff Scanner** (`cl.tocketicket.staffscanner`)
- **Trigger**: Push a `main` o tags `v*`
- **Propósito**: Releases oficiales
- **Testers**: Internal + External testers
- **Retention**: 30 días de artefactos

---

## 🔄 Workflows Configurados

### 1. **Deploy Dev to TestFlight** (`deploy-dev-testflight.yml`)
```yaml
Triggers:
  - workflow_dispatch (manual)
  - push to: develop, feature/*
  - only if changes in: lib/, ios/, android/, pubspec.yaml

Steps:
  - Build iOS release with dev flavor
  - Create IPA for .dev bundle ID
  - Upload to TestFlight automatically
```

### 2. **Build iOS** (`build-ios.yml`) - Actualizado
```yaml
Triggers:
  - push to: main, develop, feature/*
  - pull_request to: main, develop

Changes:
  - DEV: Ahora builds release + upload TestFlight
  - PROD: Builds release + upload TestFlight
```

---

## 🚀 Formas de Probar DEV → TestFlight

### 1. **Manual desde GitHub Actions** (Recomendado para testing)
```bash
# Ve a GitHub → Actions → Deploy Dev to TestFlight
# Click "Run workflow"
# Personaliza notas: "Testing new QR scanner feature"
# Click "Run workflow"
```

### 2. **Push Automático** (Para desarrollo diario)
```bash
# Hacer cambios en código
git add .
git commit -m "feat: improve QR scanner UI"
git push origin feature/qr-scanner-improvements

# ✨ Se trigger automáticamente
```

### 3. **Script de Testing** (Para crear commits de prueba)
```bash
# Crear commit de prueba automático
./scripts/test_dev_testflight.sh commit

# Hacer push para trigger
git push origin $(git branch --show-current)
```

---

## 📊 Diferencias entre Builds

| Aspecto | Development | Production |
|---------|-------------|------------|
| **App Name** | Staff Scanner Dev | Staff Scanner |
| **Bundle ID** | `cl.tocketicket.staffscanner.dev` | `cl.tocketicket.staffscanner` |
| **API URL** | `api-dev.tocketicket.cl` | `api.tocketicket.cl` |
| **Database** | `staffscanner_dev.db` | `staffscanner.db` |
| **Debug** | ✅ Enabled | ❌ Disabled |
| **Logging** | ✅ Verbose | ❌ Minimal |
| **Analytics** | ❌ Disabled | ✅ Enabled |

---

## 🧪 Flujo de Testing Recomendado

### Para Features en Desarrollo:
```bash
1. 🔧 Desarrollar en feature branch
2. 📤 Push → trigger automático dev TestFlight
3. 📱 Internal testers prueban Staff Scanner Dev
4. 🐛 Feedback y fixes
5. 🔄 Repeat hasta feature completa
6. 🚀 Merge a main → prod TestFlight
```

### Para Releases:
```bash
1. 🔖 Tag version: git tag v1.2.0
2. 📤 Push tag → trigger prod TestFlight
3. 📧 External testers reciben notificación
4. 🧪 Beta testing extensivo
5. 🏪 Release a App Store
```

---

## 📱 Gestión de Testers

### Internal Testers (ambas apps):
- **Automático**: Se notifican cuando hay nuevo build
- **Límite**: 100 testers por app
- **Acceso**: Inmediato después de processing

### External Testers (solo producción):
- **Manual**: Agregar en App Store Connect
- **Límite**: 10,000 testers
- **Review**: Puede requerir approval de Apple

---

## 🔍 Monitoreo

### En GitHub Actions:
```bash
# Ver logs de desarrollo
gh run list --workflow=deploy-dev-testflight.yml

# Ver logs de producción  
gh run list --workflow=deploy-testflight.yml

# Ver run específico
gh run view [run-id] --web
```

### En App Store Connect:
```
TestFlight → iOS → Builds:
├── Staff Scanner Dev (cl.tocketicket.staffscanner.dev)
│   └── Builds frecuentes de desarrollo
└── Staff Scanner (cl.tocketicket.staffscanner)
    └── Builds de release oficiales
```

---

## 🚨 Troubleshooting

### Si dev build falla:
```bash
# 1. Verificar configuración
./scripts/test_dev_testflight.sh check

# 2. Verificar logs en GitHub Actions
gh run view --web

# 3. Build local para debugging
flutter build ios --release --flavor dev --dart-define=ENVIRONMENT=dev

# 4. Verificar Bundle ID en Xcode
open ios/Runner.xcworkspace
```

### Errores comunes:
- **"Invalid Bundle ID"**: Verificar provisioning profile para .dev
- **"Missing Entitlements"**: Verificar Runner-Dev.entitlements
- **"Signing Failed"**: Verificar certificados y profiles

---

## 📝 Scripts de Ayuda

```bash
# Testing completo
./scripts/test_dev_testflight.sh test

# Crear commit de prueba
./scripts/test_dev_testflight.sh commit

# Ver diferencias dev vs prod
./scripts/test_dev_testflight.sh diff

# Simular flujo completo
./scripts/test_dev_testflight.sh simulate
```

---

## ✅ Ready to Test!

Con esta configuración puedes:

1. **🧪 Test Features Diarias**: Push a feature branches → dev TestFlight automático
2. **🚀 Release Testing**: Push a main → prod TestFlight automático  
3. **📝 Custom Notes**: Manual workflows con notas personalizadas
4. **👥 Separate Testers**: Different groups for dev vs prod testing

**¿Listo para probar?** Ejecuta:
```bash
./scripts/test_dev_testflight.sh commit
git push origin $(git branch --show-current)
```

¡En 10-15 minutos tendrás tu primera build de desarrollo en TestFlight! 🎉