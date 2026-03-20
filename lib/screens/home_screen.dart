import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';
import 'create_report_screen.dart';
import 'my_reports_screen.dart';
import 'profile_screen.dart';
import 'detail_screen.dart';
import 'login_screen.dart';
import 'search_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _reportService = ReportService();
  final _authService = AuthService();
  int _currentIndex = 0;
  String _userName = '';

  final List<Map<String, dynamic>> _categorias = [
    {'nombre': 'Todos', 'icono': Icons.grid_view_rounded, 'color': Colors.blueGrey},
    {'nombre': 'Bache', 'icono': Icons.report_problem_rounded, 'color': Color(0xFF795548)},
    {'nombre': 'Basura', 'icono': Icons.delete_rounded, 'color': Color(0xFF388E3C)},
    {'nombre': 'Alumbrado', 'icono': Icons.lightbulb_rounded, 'color': Color(0xFFF57F17)},
    {'nombre': 'Agua', 'icono': Icons.water_drop_rounded, 'color': Color(0xFF1565C0)},
    {'nombre': 'Otro', 'icono': Icons.more_horiz_rounded, 'color': Color(0xFF6A1B9A)},
  ];
  String _categoriaSeleccionada = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    final name = await _authService.getUserName();
    setState(() => _userName = name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHome(),
          const MyReportsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Inicio'),
                _buildNavItem(1, Icons.list_alt_rounded, Icons.list_alt_outlined, 'Mis Reportes'),
                _buildReportButton(),
                _buildNavItem(2, Icons.person_rounded, Icons.person_outline_rounded, 'Perfil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE53935).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : inactiveIcon, color: isActive ? const Color(0xFFE53935) : Colors.grey, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: isActive ? const Color(0xFFE53935) : Colors.grey, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportButton() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReportScreen())),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFB71C1C), Color(0xFFE53935)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFFE53935).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 210,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFFE53935),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF7F0000), Color(0xFFB71C1C), Color(0xFFE53935)]),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                            child: const Row(children: [
                              Icon(Icons.location_on, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('República Dominicana 🇩🇴', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ]),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () async {
                              await _authService.logout();
                              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Hola, $_userName 👋', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('¿Qué problema reportamos hoy?', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 16),
                      StreamBuilder<List<ReportModel>>(
                        stream: _reportService.obtenerReportes(),
                        builder: (context, snapshot) {
                          final total = snapshot.data?.length ?? 0;
                          final resueltos = snapshot.data?.where((r) => r.estado == 'Resuelto').length ?? 0;
                          final pendientes = snapshot.data?.where((r) => r.estado == 'Pendiente').length ?? 0;
                          return Row(
                            children: [
                              _buildStatChip('$total', 'Total', Icons.report_rounded),
                              const SizedBox(width: 8),
                              _buildStatChip('$pendientes', 'Pendientes', Icons.pending_rounded),
                              const SizedBox(width: 8),
                              _buildStatChip('$resueltos', 'Resueltos', Icons.check_circle_rounded),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final cat = _categorias[index];
                  final selected = cat['nombre'] == _categoriaSeleccionada;
                  final color = cat['color'] as Color;
                  return GestureDetector(
                    onTap: () => setState(() => _categoriaSeleccionada = cat['nombre']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: selected ? color : color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat['icono'] as IconData, size: 14, color: selected ? Colors.white : color),
                          const SizedBox(width: 6),
                          Text(cat['nombre'], style: TextStyle(color: selected ? Colors.white : color, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        StreamBuilder<List<ReportModel>>(
          stream: _reportService.obtenerReportes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFFE53935))));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                        child: const Icon(Icons.report_off_rounded, size: 60, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      const Text('No hay reportes aún', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('¡Sé el primero en reportar!', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }
            final reportes = _categoriaSeleccionada == 'Todos'
                ? snapshot.data!
                : snapshot.data!.where((r) => r.categoria == _categoriaSeleccionada).toList();
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildReportCard(reportes[index]),
                  childCount: reportes.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatChip(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 4),
            Flexible(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(ReportModel reporte) {
    final categoriaData = {
      'Bache': {'color': const Color(0xFF795548), 'icono': Icons.report_problem_rounded},
      'Basura': {'color': const Color(0xFF388E3C), 'icono': Icons.delete_rounded},
      'Alumbrado': {'color': const Color(0xFFF57F17), 'icono': Icons.lightbulb_rounded},
      'Agua': {'color': const Color(0xFF1565C0), 'icono': Icons.water_drop_rounded},
      'Otro': {'color': const Color(0xFF6A1B9A), 'icono': Icons.more_horiz_rounded},
    };
    final data = categoriaData[reporte.categoria] ?? {'color': Colors.grey, 'icono': Icons.report_rounded};
    final color = data['color'] as Color;
    final icono = data['icono'] as IconData;

    final estadoData = {
      'Pendiente': {'color': const Color(0xFFE53935), 'bg': const Color(0xFFFFEBEE)},
      'En Proceso': {'color': const Color(0xFFF57F17), 'bg': const Color(0xFFFFF3E0)},
      'Resuelto': {'color': const Color(0xFF388E3C), 'bg': const Color(0xFFE8F5E9)},
    };
    final estadoInfo = estadoData[reporte.estado] ?? estadoData['Pendiente']!;
    final estadoColor = estadoInfo['color'] as Color;
    final estadoBg = estadoInfo['bg'] as Color;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(reporte: reporte))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reporte.fotoUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                child: Image.memory(base64Decode(reporte.fotoUrl!), height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: reporte.fotoUrl == null ? BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ) : null,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(icono, color: color, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(reporte.categoria, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: estadoBg, borderRadius: BorderRadius.circular(20)),
                    child: Text(reporte.estado, style: TextStyle(color: estadoColor, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reporte.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 6),
                  Text(reporte.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Expanded(child: Text(reporte.direccion, style: TextStyle(color: Colors.grey[500], fontSize: 12), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFFE53935).withOpacity(0.15),
                        child: Text(reporte.userName[0].toUpperCase(), style: const TextStyle(fontSize: 10, color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      Text(reporte.userName, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            const Icon(Icons.thumb_up_rounded, size: 12, color: Color(0xFFE53935)),
                            const SizedBox(width: 4),
                            Text('${reporte.likes}', style: const TextStyle(color: Color(0xFFE53935), fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Icon(Icons.comment_rounded, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text('${reporte.comentarios.length}', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}