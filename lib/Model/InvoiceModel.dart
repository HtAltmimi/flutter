import 'dart:convert';

import 'package:untitled13/Model/Product.dart';

class InvoiceModel {
  String? totalWeight;
  String? totalPrice;
  List<ProductModel>? product;

  InvoiceModel({this.totalWeight, this.totalPrice, this.product});

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      totalWeight: json["totalWeight"],
      totalPrice: json["totalPrice"],
      product: json["product"].map((i) => ProductModel.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "totalWeight": this.totalWeight,
      "totalPrice": this.totalPrice,
      "product": this.product!.map((e) => e.toJson()).toList(),
    };
  }
// End Of FromJson
}
