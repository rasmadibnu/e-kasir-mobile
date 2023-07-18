import 'package:kasir_mobile/entity/produk.dart';
import 'package:kasir_mobile/entity/user.dart';

class Kategori {
  int id;
  String name;
  String? deskripsi;
  List<Produk>? produk;
  int createdBy;
  User userCreate;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  int? updatedBy;

  Kategori({
    required this.id,
    required this.name,
    this.deskripsi,
    this.produk,
    required this.createdBy,
    required this.userCreate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.updatedBy,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'],
      name: json['name'],
      deskripsi: json['deskripsi'],
      produk: json['produk'] != null
          ? List<Produk>.from(
          json['produk'].map((data) => Produk.fromJson(data)))
          : null,
      createdBy: json['created_by'],
      userCreate: User.fromJson(json['user_create']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'],
      updatedBy: json['updated_by'],
    );
  }
}