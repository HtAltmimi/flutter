import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:untitled13/Constant/appFonts.dart';
import 'package:untitled13/Constant/myColor.dart';
import 'package:untitled13/Controller/invoiceController.dart';
import 'package:untitled13/Model/InvoiceModel.dart';
import 'package:untitled13/Networking/Socket-io.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({Key? key}) : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  void insertToDataBase(data) {
    if (SocketIO.socket.connected) {
      isLoading.value = true;
      SocketIO.socket.emit("InsertInvoice", data);
    } else {
      Fluttertoast.showToast(
          msg: "لا يوجد اتصال",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void dataInserted() {
    SocketIO.socket.on("InsertInvoice", (data) {
      if (data) {
        isLoading.value = false;
        NotifierSocket.removeAll();
        Fluttertoast.showToast(
            msg: "تم الدفع",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        isLoading.value = false;
        Fluttertoast.showToast(
            msg: "فشلت عملية الدفع",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataInserted();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_outlined),
            ),
          ),
          body: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ValueListenableBuilder(
                valueListenable: NotifierSocket.socketResponse,
                builder: (context, value, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'المبلغ الكلي : ${value.totalPrice}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: MyColor.primary,
                                  fontSize: FontSize.totalFonts,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      )),
                      Expanded(
                          child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'الوزن الكلي : ${value.totalWeight}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: MyColor.primary,
                                  fontSize: FontSize.totalFonts,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      )),
                      Expanded(
                        flex: 7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 50,
                              color: MyColor.getStarted,
                              child: Center(
                                child: Text(
                                  "المنتجات",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSize.totalFonts),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                itemCount: value.product!.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    trailing: Wrap(
                                      spacing: -15,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              NotifierSocket.increaseProduct(
                                                  value.product![index]);
                                            },
                                            icon: const Icon(
                                              Icons.add,
                                              color: Colors.blue,
                                            )),
                                        IconButton(
                                            onPressed: () {
                                              NotifierSocket.decreaseProduct(
                                                  value.product![index]);
                                            },
                                            icon: const Icon(
                                              Icons.remove,
                                              color: Colors.blue,
                                            )),
                                        IconButton(
                                            onPressed: () {
                                              NotifierSocket.removeFromValue(
                                                  value.product![index]);
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            )),
                                      ],
                                    ),
                                    leading: Container(
                                      constraints: const BoxConstraints(
                                          minWidth: 30.0, maxWidth: 30.0),
                                      height: double.infinity,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "${value.product![index].number}",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    title: Center(
                                        child: Text(
                                            '${value.product![index].name}')),
                                    subtitle: Center(
                                      child: Wrap(
                                        children: [
                                          Text(
                                              'السعر: ${value.product![index].price}'),
                                          Text(
                                              'الوزن: ${value.product![index].weight}'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    thickness: 1, // thickness of the line
                                    indent:
                                        0, // empty space to the leading edge of divider.
                                    endIndent:
                                        0, // empty space to the trailing edge of the divider.
                                    // The color to use when painting the line.

                                    color: MyColor.primary,
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              insertToDataBase(value.toJson());
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: MyColor.getStarted,
                                  borderRadius: BorderRadius.circular(30)),
                              width: 200,
                              child: Center(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "دفع",
                                  style: TextStyle(
                                      color: MyColor.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSize.subtitleFonts),
                                ),
                              ),
                            ),
                          )),
                      const Spacer(
                        flex: 1,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (context, value, _) {
              return Visibility(
                visible: value,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            })
      ],
    );
  }
}
