import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionTestPage extends StatefulWidget {
  const PermissionTestPage({super.key});

  @override
  State<PermissionTestPage> createState() => _PermissionTestPageState();
}

class _PermissionTestPageState extends State<PermissionTestPage> {
  String _permissionStatus = 'Desconocido';

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    try {
      final status = await Permission.camera.status;
      setState(() {
        _permissionStatus = status.toString();
      });
      dev.log('Estado del permiso de cámara: $status');
    } catch (e) {
      setState(() {
        _permissionStatus = 'Error: $e';
      });
      dev.log('Error al verificar permisos: $e');
    }
  }

  Future<void> _requestPermission() async {
    try {
      final status = await Permission.camera.request();
      setState(() {
        _permissionStatus = status.toString();
      });
      dev.log('Resultado de solicitud de permiso: $status');
    } catch (e) {
      setState(() {
        _permissionStatus = 'Error al solicitar: $e';
      });
      dev.log('Error al solicitar permisos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test de Permisos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Estado del permiso de cámara:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _permissionStatus,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkPermissionStatus,
              child: const Text('Verificar Estado'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestPermission,
              child: const Text('Solicitar Permiso'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => openAppSettings(),
              child: const Text('Abrir Configuración'),
            ),
          ],
        ),
      ),
    );
  }
}
