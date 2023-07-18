import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kasir_mobile/api.dart';
import 'package:kasir_mobile/entity/cart.dart';
import 'package:kasir_mobile/helper.dart';

import '../entity/produk.dart';
import 'home.dart';

class CartPage extends StatefulWidget {
  final String token;
  const CartPage(this.token, {super.key});


  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Cart> cartItems = [];
  double subtotal = 0.0;
  int discount = 0;
  int ppn = 2;
  double total = 0.0;
  bool isLoading = true;
  bool isLoadingT = false;


  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
      cartItems = [];
    });
    try {
      final response = await Api.get("carts?created_by=${Helper.getUser(widget.token)['id']}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['data'];
        setState(() {
          cartItems = (jsonData as List<dynamic>)
              .map((item) => Cart.fromJson(item))
              .toList();
          isLoading = false;
        });
        calculateTotal();
      } else {
        // Handle error response
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Error: $e');
    }
  }

  Future<void> fecthTransaction() async {
    setState(() {
      isLoadingT = true;
    });
    try {
      if (cartItems.isNotEmpty) {
        List<Map<String, dynamic>> jsonList =
            cartItems.map((obj) => obj.toDetailTransaction()).toList();

        Map<String, dynamic> payload = {
          'diskon': discount,
          'ppn': ppn,
          'total_belanja': total.toInt(),
          'kasir_id': Helper.getUser(widget.token)['id'],
          'detail': jsonList
        };

        final response = await Api.post("transaksi", payload);
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body)['data'];
          setState(() {
            Fluttertoast.showToast(
                msg: 'Transakasi berhasil',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(widget.token)));
          });
        } else {
          // Handle error response
          print('Error: ${response.body}');
        }
      } else {
        Fluttertoast.showToast(
            msg: 'Keranjang belanja anda kosong',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Error: $e');
    }
  }

  Future<void> addCount(Produk produk) async {
    Map<String, dynamic> data = {
      'produk_id': produk.id,
      'count': 1,
      'created_by': int.parse(Helper.getUser(widget.token)['id']),
    };

    final response = await Api.post('carts/add', data);

    if (response.statusCode == 200) {
      setState(() {});
    } else {
      print('Failed to add item to cart: ${response.body}');
    }
  }

  Future<void> minCount(Produk produk) async {
    Map<String, dynamic> data = {
      'produk_id': produk.id,
      'count': 1,
      'created_by': int.parse(Helper.getUser(widget.token)['id']),
    };

    final response = await Api.post('carts/min', data);

    if (response.statusCode == 200) {
      setState(() {});
    } else {
      print('Failed to min item from cart: ${response.body}');
    }
  }

  void calculateTotal() {
    subtotal = cartItems.fold(0, (sum, item) => sum + item.subtotal);
    double discountDouble = (discount / 100) * subtotal;
    double totalDiscount = subtotal - discountDouble;
    double ppnDouble = (ppn / 100) * totalDiscount;
    total = totalDiscount + ppnDouble;
  }

  void updateDiscount(int newDiscount) {
    setState(() {
      discount = newDiscount;
      calculateTotal();
    });
  }

  void updatePpn(int newPpn) {
    setState(() {
      ppn = newPpn;
      calculateTotal();
    });
  }

  Future<void> showDiscountDialog() async {
    final newDiscount = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int newDiscount = discount;
        return AlertDialog(
          title: Text('Diskon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newDiscount = int.parse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Set'),
              onPressed: () {
                Navigator.of(context).pop(newDiscount);
              },
            ),
          ],
        );
      },
    );

    if (newDiscount != null) {
      updateDiscount(newDiscount);
    }
  }

  Future<void> showPpnDialog() async {
    final newPpn = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int newPpn = ppn;
        return AlertDialog(
          title: Text('PPN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newPpn = int.parse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Set'),
              onPressed: () {
                Navigator.of(context).pop(newPpn);
              },
            ),
          ],
        );
      },
    );

    if (newPpn != null) {
      updatePpn(newPpn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(widget.token)));
                    }, icon: Icon(Iconsax.arrow_left_2, color: Colors.white)),
                    Text(
                      'Keranjang Anda',
                      style: TextStyle(fontSize: 24.0, color: Colors.white),
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      isLoading
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Expanded(
                              child: RefreshIndicator(
                                onRefresh: fetchCartItems,
                                child: cartItems.length > 0 ? ListView.builder(
                                  itemCount: cartItems.length,
                                  itemBuilder: (context, index) {
                                    final item = cartItems[index];
                                    final itemSubtotal = item.subtotal;
                                    return ListTile(
                                      leading: Image.network(
                                        item.produk.image,
                                        width: 48.0,
                                        height: 48.0,
                                        fit: BoxFit.cover,
                                      ),
                                      title: Text(item.produk.name),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Harga: ${item.produk.hargaRp}'),
                                          SizedBox(height: 4.0),
                                          Text(
                                              'Subtotal: ${Helper.formatRupiah(itemSubtotal)}'),
                                        ],
                                      ),
                                      trailing: Column(
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Iconsax.minus),
                                                onPressed: () {
                                                  if (item.count >= 1) {
                                                    setState(() {
                                                      item.count--;
                                                      calculateTotal();
                                                      minCount(item.produk);
                                                      if (item.count == 0) {
                                                        cartItems
                                                            .removeAt(index);
                                                      }
                                                    });
                                                  }
                                                },
                                              ),
                                              Text('${item.count}'),
                                              IconButton(
                                                icon: Icon(Iconsax.add),
                                                onPressed: () {
                                                  if (item.produk.stok.stok >
                                                      0) {
                                                    setState(() {
                                                      item.count++;
                                                      item.produk.stok.stok--;
                                                      calculateTotal();
                                                    });
                                                    addCount(item.produk);
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Stok ${item.produk.name} sudah habis",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.red,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ): const Center(child: Text('Klik ikon (+) pada list produk untuk menambahkan ke keranjang')),
                              ),
                            ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Text(
                            'Subtotal: ',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            '${Helper.formatRupiah(subtotal)}',
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.blue),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.0),
                      Row(
                        children: [
                          Text(
                            'Discount:',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.center),                            onPressed: () {
                              showDiscountDialog();
                            },
                            child: Text(
                              discount.toString() + "%",
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'PPN:',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.center),                            onPressed: () {
                              showPpnDialog();
                            },
                            child: Text(
                              ppn.toString() + "%",
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.0),
                      Text(
                        'Total: ${Helper.formatRupiah(total)}',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          fecthTransaction();
                        },
                        child: isLoadingT ? CircularProgressIndicator(color: Colors.white):Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
