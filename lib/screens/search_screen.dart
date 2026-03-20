import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _reportService = ReportService();
  List<ReportModel> _resultados = [];
  bool _buscando = false;
  bool _buscado = false;

  void _buscar() async {
    if (_searchController.text.isEmpty) return;
    setState(() { _buscando = true; _buscado = false; });
    final resultados = await _reportService.buscarReportes(_searchController.text.trim());
    setState(() { _resultados = resultados; _buscando = false; _buscado = true; });
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Buscar Reportes', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _buscar(),
                    decoration: InputDecoration(
                      hintText: 'Buscar por título, lugar, categoría...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFE53935)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _buscar,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.search_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_buscando)
              const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFFE53935))))
            else if (_buscado && _resultados.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                        child: const Icon(Icons.search_off_rounded, size: 50, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      const Text('No se encontraron resultados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Intenta con otras palabras', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                ),
              )
            else if (_buscado)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_resultados.length} resultado(s) encontrado(s)', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _resultados.length,
                        itemBuilder: (context, index) {
                          final r = _resultados[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(reporte: r))),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 10)]),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.report_rounded, color: Color(0xFFE53935)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.titulo, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text(r.categoria, style: const TextStyle(color: Color(0xFFE53935), fontSize: 12)),
                                        Text(r.direccion, style: TextStyle(color: Colors.grey[500], fontSize: 12), overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.06), shape: BoxShape.circle),
                        child: const Icon(Icons.search_rounded, size: 50, color: Color(0xFFE53935)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Busca reportes ciudadanos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Por título, lugar o categoría', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}