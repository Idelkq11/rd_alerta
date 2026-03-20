import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final reportService = ReportService();
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFFE53935),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF7F0000), Color(0xFFE53935)]),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
                        ),
                        child: Center(
                          child: Text(
                            user.email![0].toUpperCase(),
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<String>(
                        future: authService.getUserName(),
                        builder: (context, snapshot) => Text(
                          snapshot.data ?? 'Usuario',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(user.email!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  StreamBuilder<List<ReportModel>>(
                    stream: reportService.obtenerMisReportes(user.uid),
                    builder: (context, snapshot) {
                      final total = snapshot.data?.length ?? 0;
                      final resueltos = snapshot.data?.where((r) => r.estado == 'Resuelto').length ?? 0;
                      final likes = snapshot.data?.fold(0, (sum, r) => sum! + r.likes) ?? 0;
                      return Row(
                        children: [
                          _buildStatCard('$total', 'Reportes', Icons.report_rounded, const Color(0xFFE53935)),
                          const SizedBox(width: 12),
                          _buildStatCard('$resueltos', 'Resueltos', Icons.check_circle_rounded, const Color(0xFF388E3C)),
                          const SizedBox(width: 12),
                          _buildStatCard('$likes', 'Apoyos', Icons.thumb_up_rounded, const Color(0xFF1565C0)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 10)]),
                    child: Column(
                      children: [
                        _buildMenuItem(Icons.person_outline_rounded, 'Mi información', () {}),
                        _buildDivider(),
                        _buildMenuItem(Icons.list_alt_rounded, 'Mis reportes', () {}),
                        _buildDivider(),
                        _buildMenuItem(Icons.notifications_outlined, 'Notificaciones', () {}),
                        _buildDivider(),
                        _buildMenuItem(Icons.info_outline_rounded, 'Acerca de RDAlerta', () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 10)]),
                    child: _buildMenuItem(Icons.logout_rounded, 'Cerrar Sesión', () async {
                      await authService.logout();
                      if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    }, color: const Color(0xFFE53935)),
                  ),
                  const SizedBox(height: 32),
                  Text('RDAlerta v1.0.0 🇩🇴', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (color ?? const Color(0xFFE53935)).withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color ?? const Color(0xFF1A1A1A), size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color ?? const Color(0xFF1A1A1A))),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
    );
  }

  Widget _buildDivider() => Divider(height: 1, indent: 56, color: Colors.grey[100]);
}