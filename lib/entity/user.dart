import 'package:kasir_mobile/entity/transaksi.dart';

import 'cart.dart';

class User {
  int id;
  String username;
  String name;
  String phoneNumber;
  String jenisKelamin;
  String password;
  String role;
  List<Cart>? cart;
  List<Transaksi>? transaksi;
  int createdBy;
  dynamic userCreate;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.phoneNumber,
    required this.jenisKelamin,
    required this.password,
    required this.role,
    required this.cart,
    required this.transaksi,
    required this.createdBy,
    this.userCreate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Create UserCreate object from JSON data...
    return User(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      jenisKelamin: json['jenis_kelamin'],
      password: json['password'],
      role: json['role'],
      cart: json['cart'] != null
          ? List<Cart>.from(
          json['cart'].map((data) => Cart.fromJson(data)))
          : null,
      transaksi: json['transaksi'] != null
          ? List<Transaksi>.from(
          json['transaksi'].map((data) => Transaksi.fromJson(data)))
          : null,
      createdBy: json['created_by'],
      userCreate: json['user_create'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'],
    );
  }
}