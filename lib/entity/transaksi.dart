import 'package:kasir_mobile/entity/produk.dart';

class Transaksi {
  int id;
  String no_transaksi;
  int diskon;
  int ppn;
  List<DetailTransaksi>? detail;
  int totalBelanja;
  String totalBelanjaRp;
  int kasirId;
  DateTime tanggal;

  Transaksi({
    required this.id,
    required this.no_transaksi,
    required this.diskon,
    required this.ppn,
    required this.detail,
    required this.totalBelanja,
    required this.totalBelanjaRp,
    required this.kasirId,
    required this.tanggal,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) => Transaksi(
    id: json["id"],
    no_transaksi: json["no_transaksi"],
    diskon: json["diskon"],
    ppn: json["ppn"],
    detail: json['detail'] != null
        ? List<DetailTransaksi>.from(
        json['detail'].map((data) => DetailTransaksi.fromJson(data)))
        : null,
    totalBelanja: json["total_belanja"],
    totalBelanjaRp: json["total_belanja_rp"],
    kasirId: json["kasir_id"],
    tanggal: DateTime.parse(json["tanggal"]),
  );
}

class DetailTransaksi {
  int id;
  int transaksiId;
  int produkId;
  int harga;
  String hargaRp;
  Produk produk;
  int jumlahBeli;

  DetailTransaksi({
    required this.id,
    required this.transaksiId,
    required this.produkId,
    required this.harga,
    required this.hargaRp,
    required this.produk,
    required this.jumlahBeli,
  });

  factory DetailTransaksi.fromJson(Map<String, dynamic> json) => DetailTransaksi(
    id: json["id"],
    transaksiId: json["transaksi_id"],
    produkId: json["produk_id"],
    harga: json["harga"],
    hargaRp: json["harga_rp"],
    produk: Produk.fromJson(json["produk"]),
    jumlahBeli: json["jumlah_beli"],
  );

  double get subtotal => (harga * jumlahBeli).toDouble();

}
