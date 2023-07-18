import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:convert';

import 'package:intl/intl.dart';

import '../api.dart';
import '../entity/transaksi.dart';
import '../helper.dart';
import 'home.dart';

class TransactionHistoryPage extends StatefulWidget {
  final String token;

  const TransactionHistoryPage(this.token, {super.key});

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Transaksi> transactions = [];
  bool isLoading = true;

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
      transactions = [];
    });
    try {
      final response = await Api.get(
          "transaksi?kasir_id=${Helper.getUser(widget.token)['id']}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['data'];
        setState(() {
          transactions = (jsonData as List<dynamic>)
              .map((item) => Transaksi.fromJson(item))
              .toList();
          isLoading = false;
        });
      } else {
        // Handle error response
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Error: $e');
    }
  }

  @override
  void initState() {
    fetchTransactions();
    super.initState();
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
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => HomePage(widget.token)));
                        },
                        icon: Icon(Iconsax.arrow_left_2, color: Colors.white)),
                    Text(
                      'Riwayat Transaksi',
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
                    children: [
                      isLoading
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Expanded(
                              child: RefreshIndicator(
                                onRefresh: fetchTransactions,
                                child: ListView.builder(
                                  itemCount: transactions.length,
                                  itemBuilder: (ctx, index) {
                                    return InkWell(
                                      onTap: () => {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionDetailPage(
                                                    transactions[index],
                                                    widget.token),
                                          ),
                                        )
                                      },
                                      child: ListTile(
                                        title: Text(
                                          'No: #${transactions[index].no_transaksi}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              DateFormat(
                                                      'MMM dd EEE, yyyy HH:mm:ss')
                                                  .format(transactions[index]
                                                      .tanggal),
                                            ),
                                            Text(
                                              '+${transactions[index].totalBelanjaRp}',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
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

class TransactionDetailPage extends StatelessWidget {
  final Transaksi transaction;
  final String token;

  TransactionDetailPage(this.transaction, this.token, {super.key});

  @override
  Widget build(BuildContext context) {
    double? subtotal = transaction.detail?.fold(0, (sum, item) => sum! + item.subtotal);
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
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TransactionHistoryPage(token)));
                        },
                        icon: Icon(Iconsax.arrow_left_2, color: Colors.white)),
                    Text('Detail Transaksi',
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
                    children: [
                      Center(child: Column(
                        children: [
                          Text('#${transaction.no_transaksi}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                          Text('${DateFormat('MMM dd EEE, yyyy HH:mm:ss').format(transaction.tanggal)}'),
                        ],
                      )),
                      SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: transaction.detail?.length,
                          itemBuilder: (context, index) {
                            final item = transaction.detail![index];
                            final itemSubtotal = item.subtotal;
                            return ListTile(
                              leading: Image.network(
                                item.produk.image,
                                width: 48.0,
                                height: 48.0,
                                fit: BoxFit.cover,
                              ),
                              title: Text('${item.produk.name}'),
                              subtitle: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text('Harga: ${item.hargaRp}'),
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
                                      Text('x${item.jumlahBeli}'),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('Subtotal: ${Helper.formatRupiah(subtotal!)}', style: TextStyle(fontSize: 18)),
                      Text('Diskon: ${transaction.diskon}%', style: TextStyle(fontSize: 18)),
                      Text('PPN: ${transaction.ppn}%', style: TextStyle(fontSize: 18)),
                      Text('Total: ${transaction.totalBelanjaRp}', style: TextStyle(fontSize: 18)),
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
