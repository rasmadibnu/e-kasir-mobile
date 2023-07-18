import 'package:kasir_mobile/entity/user.dart';

class Stok {
  int id;
  int produkId;
  int stok;
  int value;
  String type;
  int createdBy;
  User? userCreate;
  DateTime createdAt;

  Stok(
      {required this.id,
        required this.produkId,
        required this.stok,
        required this.value,
        required this.type,
        required this.createdBy,
        required this.createdAt,
        this.userCreate});

  factory Stok.fromJson(Map<String, dynamic> json) {
    return Stok(
      id: json['id'],
      produkId: json['produk_id'],
      stok: json['stok'],
      value: json['value'],
      type: json['type'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      userCreate: User.fromJson(json['user_create']),
    );
  }
}