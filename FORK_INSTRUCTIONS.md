# Instrucciones para Fork Temporal

## Si necesitas ejecutar el workflow urgentemente:

1. **Crear un fork personal:**
   - Ve a https://github.com/mickyys/tocketicket-app
   - Click "Fork" (crear en tu cuenta personal)

2. **Configurar secrets en tu fork:**
   - Ve a Settings → Secrets and variables → Actions
   - Agrega todos los secrets necesarios:
     - `IOS_CERTIFICATE_BASE64`
     - `IOS_CERTIFICATE_PASSWORD`
     - `IOS_PROVISIONING_PROFILE_BASE64`
     - `APP_STORE_CONNECT_API_KEY_BASE64`
     - `APP_STORE_CONNECT_API_KEY_ID`
     - `APP_STORE_CONNECT_ISSUER_ID`

3. **Ejecutar el workflow:**
   - Actions → Deploy to TestFlight → Run workflow

4. **Después del deployment:**
   - Crear PR de tu fork al repo original
   - O simplemente eliminar el fork

## Nota sobre límites:
- Las cuentas gratuitas de GitHub tienen 2000 minutos/mes de GitHub Actions
- Las cuentas Pro tienen 3000 minutos/mes
- Los runners macOS consumen 10x minutos (1 minuto real = 10 minutos facturados)