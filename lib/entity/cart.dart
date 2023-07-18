import 'package:kasir_mobile/entity/produk.dart';
import 'package:kasir_mobile/entity/user.dart';

class Cart {
  int id;
  int produkId;
  int count;
  int createdBy;
  Produk produk;
  User userCreate;
  DateTime createdAt;
  DateTime updatedAt;

  Cart({
    required this.id,
    required this.produkId,
    required this.count,
    required this.createdBy,
    required this.produk,
    required this.userCreate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: json["id"],
    produkId: json["produk_id"],
    count: json["count"],
    createdBy: json["created_by"],
    produk: Produk.fromJson(json["produk"]),
    userCreate: User.fromJson(json["user_create"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toDetailTransaction() {
    return {
      'produk_id': produk.id,
      'harga': produk.harga,
      'jumlah_beli': count,
    };
  }

  double get subtotal => (produk.harga * count).toDouble();
}
