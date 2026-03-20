import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';
import 'detail_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportService = ReportService();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Mis Reportes', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ReportModel>>(
        stream: reportService.obtenerMisReportes(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.08), shape: BoxShape.circle),
                    child: const Icon(Icons.report_off_rounded, size: 60, color: Color(0xFFE53935)),
                  ),
                  const SizedBox(height: 20),
                  const Text('No tienes reportes aún', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Toca el botón + para crear uno', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final reporte = snapshot.data![index];
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
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.report_rounded, color: Color(0xFFE53935)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reporte.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(reporte.categoria, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 12, color: Colors.grey),
                                const SizedBox(width: 2),
                                Expanded(child: Text(reporte.direccion, style: TextStyle(color: Colors.grey[400], fontSize: 11), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: estadoBg, borderRadius: BorderRadius.circular(20)),
                            child: Text(reporte.estado, style: TextStyle(color: estadoColor, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.thumb_up_rounded, size: 12, color: Color(0xFFE53935)),
                              const SizedBox(width: 4),
                              Text('${reporte.likes}', style: const TextStyle(color: Color(0xFFE53935), fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}