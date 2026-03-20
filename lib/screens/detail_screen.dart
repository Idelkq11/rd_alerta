import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class DetailScreen extends StatefulWidget {
  final ReportModel reporte;
  const DetailScreen({super.key, required this.reporte});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _comentarioController = TextEditingController();
  final _reportService = ReportService();
  late ReportModel _reporte;

  @override
  void initState() {
    super.initState();
    _reporte = widget.reporte;
  }

  void _compartirWhatsApp() async {
    final msg = Uri.encodeComponent(
      '🚨 *RDAlerta* 🇩🇴\n\n'
      '*${_reporte.titulo}*\n'
      '📍 ${_reporte.direccion}\n'
      '📋 Categoría: ${_reporte.categoria}\n'
      '📝 ${_reporte.descripcion}\n\n'
      'Reportado en RDAlerta 🇩🇴'
    );
    final url = Uri.parse('https://wa.me/?text=$msg');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _compartir() {
    Share.share(
      '🚨 RDAlerta 🇩🇴\n\n'
      '${_reporte.titulo}\n'
      '📍 ${_reporte.direccion}\n'
      '📋 ${_reporte.categoria}\n\n'
      '${_reporte.descripcion}',
      subject: 'Reporte ciudadano - RDAlerta',
    );
  }

  void _agregarComentario() async {
    if (_comentarioController.text.isEmpty) return;
    final comentario = _comentarioController.text.trim();
    await _reportService.agregarComentario(_reporte.id, comentario, _reporte.comentarios);
    setState(() {
      _reporte = ReportModel(
        id: _reporte.id,
        titulo: _reporte.titulo,
        descripcion: _reporte.descripcion,
        categoria: _reporte.categoria,
        direccion: _reporte.direccion,
        userId: _reporte.userId,
        userName: _reporte.userName,
        fechaCreacion: _reporte.fechaCreacion,
        likes: _reporte.likes,
        estado: _reporte.estado,
        fotoUrl: _reporte.fotoUrl,
        latitud: _reporte.latitud,
        longitud: _reporte.longitud,
        comentarios: [..._reporte.comentarios, comentario],
      );
    });
    _comentarioController.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Comentario agregado ✅'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final estadoData = {
      'Pendiente': {'color': const Color(0xFFE53935), 'bg': const Color(0xFFFFEBEE), 'icono': Icons.pending_rounded},
      'En Proceso': {'color': const Color(0xFFF57F17), 'bg': const Color(0xFFFFF3E0), 'icono': Icons.autorenew_rounded},
      'Resuelto': {'color': const Color(0xFF388E3C), 'bg': const Color(0xFFE8F5E9), 'icono': Icons.check_circle_rounded},
    };
    final estadoInfo = estadoData[_reporte.estado] ?? estadoData['Pendiente']!;
    final estadoColor = estadoInfo['color'] as Color;
    final estadoBg = estadoInfo['bg'] as Color;
    final estadoIcono = estadoInfo['icono'] as IconData;

    final categoriaData = {
      'Bache': {'color': const Color(0xFF795548), 'icono': Icons.report_problem_rounded},
      'Basura': {'color': const Color(0xFF388E3C), 'icono': Icons.delete_rounded},
      'Alumbrado': {'color': const Color(0xFFF57F17), 'icono': Icons.lightbulb_rounded},
      'Agua': {'color': const Color(0xFF1565C0), 'icono': Icons.water_drop_rounded},
      'Otro': {'color': const Color(0xFF6A1B9A), 'icono': Icons.more_horiz_rounded},
    };
    final catData = categoriaData[_reporte.categoria] ?? {'color': Colors.grey, 'icono': Icons.report_rounded};
    final catColor = catData['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: _reporte.fotoUrl != null ? 280 : 180,
            pinned: true,
            backgroundColor: catColor,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _compartirWhatsApp,
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _reporte.fotoUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(base64Decode(_reporte.fotoUrl!), fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, catColor.withOpacity(0.9)],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20, left: 20, right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_reporte.titulo, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              Text(_reporte.categoria, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [catColor.withOpacity(0.8), catColor])),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(_reporte.titulo, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              Text(_reporte.categoria, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: estadoBg, borderRadius: BorderRadius.circular(20)),
                        child: Row(children: [
                          Icon(estadoIcono, color: estadoColor, size: 16),
                          const SizedBox(width: 6),
                          Text(_reporte.estado, style: TextStyle(color: estadoColor, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                        child: Row(children: [
                          const Icon(Icons.thumb_up_rounded, color: Color(0xFFE53935), size: 16),
                          const SizedBox(width: 6),
                          Text('${_reporte.likes} apoyos', style: const TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard('Descripción', _reporte.descripcion, Icons.description_rounded),
                  const SizedBox(height: 12),
                  _buildInfoCard('Ubicación', _reporte.direccion, Icons.location_on_rounded),
                  const SizedBox(height: 12),
                  _buildInfoCard('Reportado por', _reporte.userName, Icons.person_rounded),
                  const SizedBox(height: 12),
                  _buildInfoCard('Fecha', '${_reporte.fechaCreacion.day}/${_reporte.fechaCreacion.month}/${_reporte.fechaCreacion.year}', Icons.calendar_today_rounded),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _reportService.darLike(_reporte.id, _reporte.likes);
                            setState(() => _reporte = ReportModel(
                              id: _reporte.id, titulo: _reporte.titulo, descripcion: _reporte.descripcion,
                              categoria: _reporte.categoria, direccion: _reporte.direccion, userId: _reporte.userId,
                              userName: _reporte.userName, fechaCreacion: _reporte.fechaCreacion,
                              likes: _reporte.likes + 1, estado: _reporte.estado, fotoUrl: _reporte.fotoUrl,
                              latitud: _reporte.latitud, longitud: _reporte.longitud, comentarios: _reporte.comentarios,
                            ));
                          },
                          icon: const Icon(Icons.thumb_up_rounded),
                          label: const Text('Apoyar', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _compartirWhatsApp,
                          icon: const Icon(Icons.share_rounded, color: Color(0xFF25D366)),
                          label: const Text('WhatsApp', style: TextStyle(color: Color(0xFF25D366), fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF25D366)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 8),
                      Text('Comentarios (${_reporte.comentarios.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_reporte.comentarios.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: const Center(child: Text('Sin comentarios aún. ¡Sé el primero!', style: TextStyle(color: Colors.grey))),
                    )
                  else
                    ...(_reporte.comentarios.map((c) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.08), shape: BoxShape.circle),
                            child: const Icon(Icons.person_rounded, color: Color(0xFFE53935), size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(c, style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                    ))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _comentarioController,
                          decoration: InputDecoration(
                            hintText: 'Escribe un comentario...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _agregarComentario,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 10)]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFFE53935), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}