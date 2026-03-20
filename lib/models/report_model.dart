class ReportModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String direccion;
  final String userId;
  final String userName;
  final DateTime fechaCreacion;
  int likes;
  String estado;
  final String? fotoUrl;
  final double? latitud;
  final double? longitud;
  final List<String> comentarios;

  ReportModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.direccion,
    required this.userId,
    required this.userName,
    required this.fechaCreacion,
    this.likes = 0,
    this.estado = 'Pendiente',
    this.fotoUrl,
    this.latitud,
    this.longitud,
    this.comentarios = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'direccion': direccion,
      'userId': userId,
      'userName': userName,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'likes': likes,
      'estado': estado,
      'fotoUrl': fotoUrl,
      'latitud': latitud,
      'longitud': longitud,
      'comentarios': comentarios,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      categoria: map['categoria'] ?? '',
      direccion: map['direccion'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
      likes: map['likes'] ?? 0,
      estado: map['estado'] ?? 'Pendiente',
      fotoUrl: map['fotoUrl'],
      latitud: map['latitud']?.toDouble(),
      longitud: map['longitud']?.toDouble(),
      comentarios: List<String>.from(map['comentarios'] ?? []),
    );
  }
}