import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../events/presentation/pages/organizer_events_page.dart';
import '../../../scanner/presentation/pages/scan_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await AuthService.getUserData();
    if (mounted) {
      setState(() {
        userData = data;
      });
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Eventos - stay on home
        break;
      case 1:
        // Scanner
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const OrganizerEventsPage(),
          ),
        );
        break;
      case 2:
        // History
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ScanHistoryPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Header
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.qr_code, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tocket',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Validator',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: _handleLogout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      // Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.padding,
          AppConstants.padding,
          AppConstants.padding,
          120, // Espacio para BottomNav
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Acciones principales
            MainActionsGrid(
              onScanPress: () => _onNavTapped(1),
              onHistoryPress: () => _onNavTapped(2),
            ),
            const SizedBox(height: 24),

            // Estadísticas rápidas
            const QuickStatsCard(
              eventsCount: 5,
              scannedCount: 42,
              todayCount: 12,
            ),
            const SizedBox(height: 24),

            // Título de eventos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Eventos Disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '5',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de eventos simulados
            _buildEventsList(),
          ],
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }

  Widget _buildEventsList() {
    // Datos simulados para eventos
    final List<Map<String, dynamic>> events = [
      {
        'name': 'Marathon 2026',
        'date': '29 Enero 2026',
        'location': 'Lima, Perú',
        'tickets': 150,
      },
      {
        'name': 'Trail Running',
        'date': '05 Febrero 2026',
        'location': 'Cusco, Perú',
        'tickets': 80,
      },
      {
        'name': 'Urban Race',
        'date': '12 Febrero 2026',
        'location': 'Arequipa, Perú',
        'tickets': 120,
      },
      {
        'name': 'Challenge Cup',
        'date': '20 Febrero 2026',
        'location': 'Trujillo, Perú',
        'tickets': 100,
      },
      {
        'name': 'Sprint Championship',
        'date': '28 Febrero 2026',
        'location': 'Lima, Perú',
        'tickets': 200,
      },
    ];

    return Column(
      children: List.generate(
        events.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EventCard(
            eventName: events[index]['name'] as String,
            date: events[index]['date'] as String,
            location: events[index]['location'] as String,
            totalTickets: events[index]['tickets'] as int,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrganizerEventsPage(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
