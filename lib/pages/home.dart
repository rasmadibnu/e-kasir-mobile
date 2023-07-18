import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kasir_mobile/api.dart';
import 'package:kasir_mobile/helper.dart';
import 'package:kasir_mobile/pages/cart.dart';
import 'package:kasir_mobile/pages/history.dart';
import 'package:kasir_mobile/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:iconsax/iconsax.dart';
import '../debouce.dart';
import '../entity/kategori.dart';
import '../entity/produk.dart';
import '../entity/user.dart';

enum Menu { history, logout }

class HomePage extends StatefulWidget {
  final String token;

  const HomePage(this.token, {super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String token = widget.token as String;
  int cartCount = 0;
  late bool _showCartBadge;
  bool isLoadingKategori = true;
  bool isSearch = false;
  bool isLoadingUser = true;
  List<int> myProduk = [];

  List<Kategori> kategoris = [];
  List<Produk> produks = [];
  String keyword = "";
  int totalTransaction = 0;
  int sumTransaction = 0;
  final _debouncer = Debouncer(milliseconds: 500);

  late User user;

  @override
  void initState() {
    super.initState();
    fetchKategori();
    fetchUser();
  }

  Future<void> addToCart(Produk produk) async {
    if (produk.stok.stok > 0) {
      Map<String, dynamic> data = {
        'produk_id': produk.id,
        'count': 1,
        'created_by': Helper.getUser(token)['id'],
      };

      final response = await Api.post('carts/add', data);

      if (response.statusCode == 200) {
        setState(() {});
      } else {
        print('Failed to add item to cart: ${response.body}');
      }
    }
  }

  Future<void> fetchKategori() async {
    setState(() {
      isLoadingKategori = true;
      kategoris = [];
    });
    try {
      // Ganti URL_API dengan URL API yang sesuai
      final response = await Api.get("kategori");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['data'];
        setState(() {
          kategoris = (jsonData as List<dynamic>)
              .map((item) => Kategori.fromJson(item))
              .toList();
          isLoadingKategori = false;
        });
      } else {
        Fluttertoast.showToast(
            msg:
            'Gagal mengambil data produk. Status code: ${response.statusCode}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: 'Gagal mengambil data produk. Error: $error',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> fetchUser() async {
    setState(() {
      isLoadingUser = true;
    });
    try {
      final response = await Api.get("users/${Helper.getUser(token)['id']}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['data'];
        setState(() {
          user = User.fromJson(jsonData);
          cartCount = user.cart?.length ?? 0;
          totalTransaction = user.transaksi?.length ?? 0;
          sumTransaction = user.transaksi
              ?.map((e) => e.totalBelanja)
              .reduce((value, element) => value + element) ??
              0;

          isLoadingUser = false;
        });
      } else {
        Fluttertoast.showToast(
            msg:
            'Gagal mengambil data user. Status code: ${response.statusCode}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (error) {
      // Fluttertoast.showToast(
      //     msg:
      //     'Gagal mengambil data user. Error: $error',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0
      // );
    }
  }

  Future<void> searchProduk(String val) async {
    setState(() {
      produks = [];
    });

    try {
      final response = await Api.get("produk/search/${val}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['data'];
        setState(() {
          produks = (jsonData as List<dynamic>)
              .map((item) => Produk.fromJson(item))
              .toList();
          isLoadingKategori = false;
        });
      } else {
        Fluttertoast.showToast(
            msg:
            'Gagal mengambil data produk. Status code: ${response.statusCode}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (error) {
      print(error);
      // Fluttertoast.showToast(
      //     msg:
      //     'Gagal mengambil data user. Error: $error',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    _showCartBadge = cartCount > 0;
    // bool _isAppBarExpanded = false;

    Future<void> _logout() async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Konfirmasi Logout'),
            content: Text('Apakah Anda yakin ingin logout?'),
            actions: <Widget>[
              TextButton(
                child: Text('Batal'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Logout'),
                onPressed: () async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  await prefs.remove('token');
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.blue,
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Helper.getUser(token)['name'],
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              Helper.getUser(token)['role'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Stack(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Iconsax.bag,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CartPage(token)));
                                  },
                                ),
                                Positioned(
                                  right: 0,
                                  child: cartCount > 0
                                      ? Container(
                                    padding: EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        cartCount.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                      : Container(),
                                ),
                              ],
                            ),
                            PopupMenuButton<Menu>(
                              icon: const Icon(
                                Iconsax.more_circle,
                                size: 24,
                                color: Colors.white,
                              ), //use this icon
                              onSelected: (Menu item) {
                                setState(() {
                                  switch (item.name) {
                                    case "logout":
                                      _logout();
                                      break;
                                    case "history":
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TransactionHistoryPage(
                                                      token)));
                                  }
                                });
                              },
                              itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<Menu>>[
                                PopupMenuItem<Menu>(
                                  value: Menu.history,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Iconsax.receipt),
                                      SizedBox(width: 8),
                                      Text('Riwayat Transaksi'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<Menu>(
                                  value: Menu.logout,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Iconsax.logout, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Logout',
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: CardItem(
                            icon: Iconsax.receipt_add,
                            iconColor: Colors.blue,
                            title: 'Total Transaksi',
                            amount: '$totalTransaction',
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: CardItem(
                            icon: Iconsax.money_add,
                            iconColor: Colors.green,
                            title: 'Uang Masuk',
                            amount:
                            Helper.formatRupiah(sumTransaction.toDouble()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26.0),
                    topRight: Radius.circular(26.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: 16.0, left: 16.0, right: 16.0, bottom: 4.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            keyword = val;
                            if(val.isNotEmpty){
                              isSearch = true;
                              isLoadingKategori = true;
                              _debouncer.run(() => searchProduk(val));
                            } else {
                              isSearch = false;
                              produks = [];
                            }
                          });
                        },
                      ),
                    ),
                    isLoadingKategori
                        ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                        : Expanded(
                        child: !isSearch
                            ? DefaultTabController(
                          length: kategoris.length,
                          child: Scaffold(
                            appBar: TabBar(
                              isScrollable: true,
                              tabs: kategoris
                                  .map((e) =>
                                  Tab(
                                    child: Text(
                                      e.name,
                                      style: TextStyle(
                                          color: Colors.blue),
                                    ),
                                  ))
                                  .toList(),
                            ),
                            backgroundColor: Colors.white,
                            body: TabBarView(
                              children: kategoris.map((e) {
                                if (e.produk != []) {
                                  return RefreshIndicator(
                                    onRefresh: fetchKategori,
                                    child: ListView.builder(
                                      itemCount: e.produk!.length,
                                      itemBuilder:
                                          (BuildContext context,
                                          int index) {
                                        final produk =
                                        e.produk![index];
                                        final stok =
                                            e.produk![index].stok;
                                        return ListTile(
                                          leading: Container(
                                            width: 80,
                                            height: 80,
                                            child: Image.network(
                                              produk.image,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          title: Text(produk.name),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                  'Stok: ${stok.stok}'),
                                              SizedBox(height: 8),
                                              Text(
                                                produk.hargaRp,
                                                style: TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: [
                                              SizedBox(height: 8),
                                              Container(
                                                width: 40,
                                                height: 40,
                                                child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      if (stok.stok >
                                                          0) {
                                                        produk.stok
                                                            .stok--;
                                                        addToCart(
                                                            produk);
                                                        if (!myProduk
                                                            .contains(
                                                            produk
                                                                .id)) {
                                                          myProduk.add(
                                                              produk
                                                                  .id);
                                                          cartCount++;
                                                        }
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                            "Stok ${produk
                                                                .name} sudah habis",
                                                            toastLength:
                                                            Toast
                                                                .LENGTH_SHORT,
                                                            gravity: ToastGravity
                                                                .BOTTOM,
                                                            timeInSecForIosWeb:
                                                            1,
                                                            backgroundColor:
                                                            Colors
                                                                .red,
                                                            textColor:
                                                            Colors
                                                                .white,
                                                            fontSize:
                                                            16.0);
                                                      }
                                                    });
                                                  },
                                                  icon: Icon(Iconsax
                                                      .add_circle),
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: Text(
                                      'Tidak ada produk dikategori ini.',
                                      style: TextStyle(
                                          color: Colors.black),
                                    ),
                                  );
                                }
                              }).toList(),
                            ),
                          ),
                        )
                            : RefreshIndicator(
                          onRefresh: () => searchProduk(keyword),
                          child: ListView.builder(
                            itemCount: produks.length,
                            itemBuilder:
                                (BuildContext context,
                                int index) {
                              final produk =
                              produks[index];
                              final stok =
                                  produks[index].stok;
                              return ListTile(
                                leading: Container(
                                  width: 80,
                                  height: 80,
                                  child: Image.network(
                                    produk.image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                title: Text(produk.name),
                                subtitle: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                        'Stok: ${stok.stok}'),
                                    SizedBox(height: 8),
                                    Text(
                                      produk.hargaRp,
                                      style: TextStyle(
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                                  children: [
                                    SizedBox(height: 8),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            if (stok.stok >
                                                0) {
                                              produk.stok
                                                  .stok--;
                                              addToCart(
                                                  produk);
                                              if (!myProduk
                                                  .contains(
                                                  produk
                                                      .id)) {
                                                myProduk.add(
                                                    produk
                                                        .id);
                                                cartCount++;
                                              }
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                  "Stok ${produk
                                                      .name} sudah habis",
                                                  toastLength:
                                                  Toast
                                                      .LENGTH_SHORT,
                                                  gravity: ToastGravity
                                                      .BOTTOM,
                                                  timeInSecForIosWeb:
                                                  1,
                                                  backgroundColor:
                                                  Colors
                                                      .red,
                                                  textColor:
                                                  Colors
                                                      .white,
                                                  fontSize:
                                                  16.0);
                                            }
                                          });
                                        },
                                        icon: Icon(Iconsax
                                            .add_circle),
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                        ),
                    )
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

class CardItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String amount;

  const CardItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Menghapus margin
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 38,
              ),
            ),
            SizedBox(height: 8.0),
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Center(
              child: Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
