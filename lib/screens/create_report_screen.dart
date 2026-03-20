import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _reportService = ReportService();
  final _authService = AuthService();
  String _categoriaSeleccionada = 'Bache';
  bool _isLoading = false;
  Uint8List? _fotoBytes;
  double? _latitud;
  double? _longitud;
  bool _obteniendo = false;

  final List<Map<String, dynamic>> _categorias = [
    {'nombre': 'Bache', 'icono': Icons.report_problem_rounded, 'color': Color(0xFF795548)},
    {'nombre': 'Basura', 'icono': Icons.delete_rounded, 'color': Color(0xFF388E3C)},
    {'nombre': 'Alumbrado', 'icono': Icons.lightbulb_rounded, 'color': Color(0xFFF57F17)},
    {'nombre': 'Agua', 'icono': Icons.water_drop_rounded, 'color': Color(0xFF1565C0)},
    {'nombre': 'Otro', 'icono': Icons.more_horiz_rounded, 'color': Color(0xFF6A1B9A)},
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 70);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _fotoBytes = bytes);
    }
  }

  Future<void> _getLocation() async {
    setState(() => _obteniendo = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage('Activa el GPS en tu dispositivo', isError: true);
        setState(() => _obteniendo = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showMessage('Permiso de ubicación denegado', isError: true);
          setState(() => _obteniendo = false);
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitud = position.latitude;
        _longitud = position.longitude;
        _obteniendo = false;
      });
      _showMessage('✅ Ubicación obtenida correctamente');
    } catch (e) {
      setState(() => _obteniendo = false);
      _showMessage('No se pudo obtener la ubicación', isError: true);
    }
  }

  void _crearReporte() async {
    if (_tituloController.text.isEmpty || _descripcionController.text.isEmpty || _direccionController.text.isEmpty) {
      _showMessage('Por favor completa todos los campos', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    final userName = await _authService.getUserName();
    String? fotoBase64;
    if (_fotoBytes != null) {
      fotoBase64 = await _reportService.subirFotoBase64(_fotoBytes!);
    }
    final reporte = ReportModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      categoria: _categoriaSeleccionada,
      direccion: _direccionController.text.trim(),
      userId: FirebaseAuth.instance.currentUser!.uid,
      userName: userName,
      fechaCreacion: DateTime.now(),
      fotoUrl: fotoBase64,
      latitud: _latitud,
      longitud: _longitud,
    );
    final error = await _reportService.crearReporte(reporte);
    setState(() => _isLoading = false);
    if (error == null && mounted) {
      _showMessage('¡Reporte publicado exitosamente! 🎉');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } else if (mounted) {
      _showMessage('Error al publicar el reporte', isError: true);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: isError ? Colors.red[700] : Colors.green[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
        title: const Text('Nuevo Reporte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Categoría del problema'),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 1.5, crossAxisSpacing: 10, mainAxisSpacing: 10,
              ),
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final cat = _categorias[index];
                final selected = cat['nombre'] == _categoriaSeleccionada;
                final color = cat['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => _categoriaSeleccionada = cat['nombre']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected ? color : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? color : Colors.grey[200]!, width: 1.5),
                      boxShadow: selected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(cat['icono'] as IconData, color: selected ? Colors.white : color, size: 22),
                        const SizedBox(height: 4),
                        Text(cat['nombre'], style: TextStyle(color: selected ? Colors.white : color, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Foto del problema'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _fotoBytes != null ? const Color(0xFFE53935) : Colors.grey[200]!, width: 1.5),
                ),
                child: _fotoBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(_fotoBytes!, fit: BoxFit.cover),
                            Positioned(
                              top: 8, right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _fotoBytes = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.08), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_rounded, color: Color(0xFFE53935), size: 32),
                          ),
                          const SizedBox(height: 12),
                          const Text('Toca para agregar foto', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 4),
                          Text('Muestra el problema visualmente', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Información del reporte'),
            const SizedBox(height: 12),
            _buildTextField(controller: _tituloController, label: 'Título del reporte', hint: 'Ej: Bache peligroso en la avenida', icon: Icons.title_rounded),
            const SizedBox(height: 16),
            _buildTextField(controller: _descripcionController, label: 'Descripción detallada', hint: 'Describe el problema con detalle...', icon: Icons.description_rounded, maxLines: 4),
            const SizedBox(height: 24),
            _buildSectionTitle('Ubicación'),
            const SizedBox(height: 12),
            _buildTextField(controller: _direccionController, label: 'Dirección o punto de referencia', hint: 'Ej: Av. 27 de Febrero, frente al banco', icon: Icons.location_on_rounded),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _obteniendo ? null : _getLocation,
                icon: _obteniendo
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE53935)))
                    : Icon(_latitud != null ? Icons.check_circle_rounded : Icons.my_location_rounded, color: _latitud != null ? Colors.green : const Color(0xFFE53935)),
                label: Text(
                  _latitud != null ? '✅ Ubicación GPS obtenida' : 'Obtener ubicación GPS',
                  style: TextStyle(color: _latitud != null ? Colors.green : const Color(0xFFE53935), fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _latitud != null ? Colors.green : const Color(0xFFE53935)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _crearReporte,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded),
                          SizedBox(width: 8),
                          Text('Publicar Reporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required IconData icon, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        labelStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: const Color(0xFFE53935), size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}