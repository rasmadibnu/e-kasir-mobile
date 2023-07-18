import 'package:kasir_mobile/entity/stok.dart';
import 'package:kasir_mobile/entity/user.dart';

import '../api.dart';
import 'kategori.dart';

class Produk {
  int id;
  int supplierId;
  String image;
  String name;
  String deskripsi;
  int kategoriId;
  int harga;
  String hargaRp;
  Kategori supplier;
  Kategori kategori;
  Stok stok;
  int createdBy;
  dynamic userCreate;
  int updatedBy;
  dynamic userUpdate;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  Produk({
    required this.id,
    required this.supplierId,
    required this.image,
    required this.name,
    required this.deskripsi,
    required this.kategoriId,
    required this.harga,
    required this.hargaRp,
    required this.supplier,
    required this.kategori,
    required this.stok,
    required this.createdBy,
    this.userCreate,
    required this.updatedBy,
    this.userUpdate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'],
      supplierId: json['supplier_id'],
      image: '${Api.imageURL}/' + json['image'],
      name: json['name'],
      deskripsi: json['deskripsi'],
      kategoriId: json['kategori_id'],
      harga: json['harga'],
      hargaRp: json['harga_rp'],
      supplier: Kategori.fromJson(json['supplier']),
      kategori: Kategori.fromJson(json['kategori']),
      stok: Stok.fromJson(json['stok']),
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      userCreate: User.fromJson(json['user_create']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'],
    );
  }
}