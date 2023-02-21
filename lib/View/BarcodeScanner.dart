import 'dart:convert';
import 'dart:core';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:untitled13/Constant/appFonts.dart';
import 'package:untitled13/Constant/myColor.dart';
import 'package:untitled13/Controller/invoiceController.dart';
import 'package:untitled13/Model/Product.dart';
import 'package:untitled13/Networking/Socket-io.dart';
import 'package:untitled13/View/InvoicePage.dart';
import 'package:untitled13/main.dart';
import 'package:socket_io_client/socket_io_client.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({Key? key}) : super(key: key);

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  String scanBarcode = "unknown";
  ProductModel? _productModel;
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    connectedToSocket();
    receiveProduct();
    super.initState();
  }

  void receiveProduct() {
    SocketIO.socket.on("selectedProduct", (data) {
      isLoading.value = false;
      _productModel = ProductModel.fromJson(json.decode(data));
      NotifierSocket.addToStream(_productModel!);
    });
  }

  void connectedToSocket() {
    SocketIO.socket.connect();
    SocketIO.socket.onConnect((data) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.primary,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ValueListenableBuilder(
                          valueListenable: NotifierSocket.socketResponse,
                          builder: (context, value, child) {
                            if (value.product!.length > 0) {
                              return Stack(children: [
                                CircleAvatar(
                                  backgroundColor: MyColor.getStarted,
                                  radius: 25,
                                  child: IconButton(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    disabledColor: Colors.transparent,
                                    color: Colors.transparent,
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const InvoicePage()));
                                    },
                                    icon: Icon(
                                      Icons.shopping_cart,
                                      color: MyColor.primary,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                    child: Center(
                                      child: Text(
                                          "${NotifierSocket.socketResponse.value.product!.length}"),
                                    ),
                                  ),
                                )
                              ]);
                            } else {
                              return CircleAvatar(
                                backgroundColor: MyColor.getStarted,
                                radius: 25,
                                child: IconButton(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  disabledColor: Colors.transparent,
                                  color: Colors.transparent,
                                  onPressed: () {
                                    //not open page
                                  },
                                  icon: Icon(
                                    Icons.shopping_cart,
                                    color: MyColor.primary,
                                  ),
                                ),
                              );
                            }
                          },
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: BarcodeWidget(
                        width: 200,
                        height: 200,
                        barcode: Barcode.qrCode(),
                        data: 'E-Payment Flutter App',
                        errorBuilder: (context, error) =>
                            Center(child: Text(error)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                                child: Text(
                              "اضغط لمسح المنتجات",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSize.subtitleFonts),
                            )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: InkWell(
                              onTap: () async {
                                scanQR();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: MyColor.getStarted,
                                    borderRadius: BorderRadius.circular(30)),
                                width: 250,
                                height: 75,
                                child: Center(
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    "مسح",
                                    style: TextStyle(
                                        color: MyColor.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder(
                valueListenable: isLoading,
                builder: (context, value, _) {
                  return Visibility(
                      visible: value,
                      child: Container(
                        color: Colors.white.withOpacity(0.5),
                        child: Center(child: CircularProgressIndicator()),
                      ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> scanQR() async {
    String barcodeScanRes;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);

      if (barcodeScanRes == "-1") {
      } else {
        if (int.tryParse(barcodeScanRes) != null) {
          var integerBarcodeResult = int.parse(barcodeScanRes);
          print(
              "nnnnnnnnnnnnnnnnnnnnnnnnn$integerBarcodeResult nnnnnnnnnnnnnnnn");
          if (NotifierSocket.socketResponse.value.product!.length != 0) {
            if (NotifierSocket.socketResponse.value.product!
                .any((element) => element.id == integerBarcodeResult)) {
              Fluttertoast.showToast(
                  msg: "المنتج موجود بالفعل",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              print("elrady here");
            } else {
              SocketIO.socket.emit("selectedProduct", integerBarcodeResult);
              isLoading.value = true;
            }
          } else {
            SocketIO.socket.emit("selectedProduct", integerBarcodeResult);
            isLoading.value = true;
          }
        } else {
          Fluttertoast.showToast(
              msg: "لا يمكن قراءة هذا الباركود",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      scanBarcode = barcodeScanRes;
    });
  }
}
