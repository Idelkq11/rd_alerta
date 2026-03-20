import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> crearReporte(ReportModel reporte) async {
    try {
      await _firestore.collection('reportes').doc(reporte.id).set(reporte.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<ReportModel>> obtenerReportes() {
    return _firestore
        .collection('reportes')
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<ReportModel>> obtenerMisReportes(String userId) {
    return _firestore
        .collection('reportes')
        .where('userId', isEqualTo: userId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.data()))
            .toList());
  }

  Future<List<ReportModel>> buscarReportes(String query) async {
    try {
      final snapshot = await _firestore.collection('reportes').get();
      return snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data()))
          .where((r) =>
              r.titulo.toLowerCase().contains(query.toLowerCase()) ||
              r.descripcion.toLowerCase().contains(query.toLowerCase()) ||
              r.direccion.toLowerCase().contains(query.toLowerCase()) ||
              r.categoria.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> darLike(String reporteId, int likesActuales) async {
    try {
      await _firestore.collection('reportes').doc(reporteId).update({
        'likes': likesActuales + 1,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> agregarComentario(String reporteId, String comentario, List<String> comentariosActuales) async {
    try {
      final nuevos = [...comentariosActuales, comentario];
      await _firestore.collection('reportes').doc(reporteId).update({'comentarios': nuevos});
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> eliminarReporte(String reporteId) async {
    try {
      await _firestore.collection('reportes').doc(reporteId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<Map<String, int>> obtenerEstadisticas() async {
    try {
      final snapshot = await _firestore.collection('reportes').get();
      final reportes = snapshot.docs.map((doc) => ReportModel.fromMap(doc.data())).toList();
      return {
        'total': reportes.length,
        'pendientes': reportes.where((r) => r.estado == 'Pendiente').length,
        'enProceso': reportes.where((r) => r.estado == 'En Proceso').length,
        'resueltos': reportes.where((r) => r.estado == 'Resuelto').length,
      };
    } catch (e) {
      return {'total': 0, 'pendientes': 0, 'enProceso': 0, 'resueltos': 0};
    }
  }

  // Guardar foto como base64 en Firestore
  Future<String?> subirFotoBase64(Uint8List bytes) async {
    try {
      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }
}