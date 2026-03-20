import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportService = ReportService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1A1A)),
          ),
        ),
        title: const Text('Estadísticas 📊', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ReportModel>>(
        stream: reportService.obtenerReportes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)));
          }
          final reportes = snapshot.data ?? [];
          final total = reportes.length;
          final pendientes = reportes.where((r) => r.estado == 'Pendiente').length;
          final enProceso = reportes.where((r) => r.estado == 'En Proceso').length;
          final resueltos = reportes.where((r) => r.estado == 'Resuelto').length;
          final baches = reportes.where((r) => r.categoria == 'Bache').length;
          final basura = reportes.where((r) => r.categoria == 'Basura').length;
          final alumbrado = reportes.where((r) => r.categoria == 'Alumbrado').length;
          final agua = reportes.where((r) => r.categoria == 'Agua').length;
          final otro = reportes.where((r) => r.categoria == 'Otro').length;
          final totalLikes = reportes.fold(0, (sum, r) => sum + r.likes);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Resumen General'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard('$total', 'Total\nReportes', Icons.report_rounded, const Color(0xFFE53935)),
                    const SizedBox(width: 12),
                    _buildStatCard('$totalLikes', 'Total\nApoyos', Icons.thumb_up_rounded, const Color(0xFF1565C0)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Por Estado'),
                const SizedBox(height: 12),
                _buildProgressCard('Pendientes', pendientes, total, const Color(0xFFE53935), Icons.pending_rounded),
                const SizedBox(height: 10),
                _buildProgressCard('En Proceso', enProceso, total, const Color(0xFFF57F17), Icons.autorenew_rounded),
                const SizedBox(height: 10),
                _buildProgressCard('Resueltos', resueltos, total, const Color(0xFF388E3C), Icons.check_circle_rounded),
                const SizedBox(height: 24),
                _buildSectionTitle('Por Categoría'),
                const SizedBox(height: 12),
                _buildProgressCard('Baches', baches, total, const Color(0xFF795548), Icons.report_problem_rounded),
                const SizedBox(height: 10),
                _buildProgressCard('Basura', basura, total, const Color(0xFF388E3C), Icons.delete_rounded),
                const SizedBox(height: 10),
                _buildProgressCard('Alumbrado', alumbrado, total, const Color(0xFFF57F17), Icons.lightbulb_rounded),
                const SizedBox(height: 10),
                _buildProgressCard('Agua', agua, total, const Color(0xFF1565C0), Icons.water_drop_rounded),
                const SizedBox(height: 10),
                _buildProgressCard('Otro', otro, total, const Color(0xFF6A1B9A), Icons.more_horiz_rounded),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String label, int value, int total, Color color, IconData icon) {
    final percentage = total == 0 ? 0.0 : value / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 10)]),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const Spacer(),
              Text('$value', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
              Text('  ${(percentage * 100).toStringAsFixed(0)}%', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}