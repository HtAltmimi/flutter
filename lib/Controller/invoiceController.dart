import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../Model/InvoiceModel.dart';
import '../Model/Product.dart';

class NotifierSocket {
  static final socketResponse = ValueNotifier<InvoiceModel>(
      InvoiceModel(totalWeight: "0", totalPrice: "0", product: []));

  static var _totalPrice = 0;
  static var _totalWeight = 0;
  static List<ProductModel> _product = [];
  static void addToStream(ProductModel productModel) {
    int price = int.parse(productModel.price!.replaceAll("دينار عراقي", " "));
    int weight = int.parse(productModel.weight!.replaceAll("غرام", ""));
    _totalPrice += price;
    _totalWeight += weight;
    productModel.number = 1;
    _product.add(productModel);
    print(
        "totalPrice: ${_totalPrice} , totalWeight: ${_totalWeight} , product: $_product");
    socketResponse.value = InvoiceModel(
        totalPrice: _totalPrice.toString() + " دينار عراقي ",
        totalWeight: _totalWeight.toString() + " غرام ",
        product: _product);
  }

  static void increaseProduct(ProductModel productModel) {
    int price = int.parse(productModel.price!.replaceAll("دينار عراقي", " "));
    int weight = int.parse(productModel.weight!.replaceAll("غرام", ""));
    _totalPrice += price;
    _totalWeight += weight;

    _product[_product.indexOf(productModel)].number =
        _product[_product.indexOf(productModel)].number! + 1;
    print(
        "totalPrice: ${_totalPrice} , totalWeight: ${_totalWeight} , product: $_product");
    socketResponse.value = InvoiceModel(
        totalPrice: _totalPrice.toString() + " دينار عراقي ",
        totalWeight: _totalWeight.toString() + " غرام ",
        product: _product);
  }

  static void decreaseProduct(ProductModel productModel) {
    if (productModel.number! > 1) {
      _product[_product.indexOf(productModel)].number =
          _product[_product.indexOf(productModel)].number! - 1;
      int price = int.parse(productModel.price!.replaceAll("دينار عراقي", " "));
      int weight = int.parse(productModel.weight!.replaceAll("غرام", ""));
      _totalPrice -= price;
      _totalWeight -= weight;
    } else {
      removeFromValue(productModel);
    }

    print(
        "totalPrice: ${_totalPrice} , totalWeight: ${_totalWeight} , product: $_product");
    socketResponse.value = InvoiceModel(
        totalPrice: _totalPrice.toString() + " دينار عراقي ",
        totalWeight: _totalWeight.toString() + " غرام ",
        product: _product);
  }

  static void removeFromValue(ProductModel productModel) {
    int price = int.parse(productModel.price!.replaceAll("دينار عراقي", " "));
    int weight = int.parse(productModel.weight!.replaceAll("غرام", ""));
    _totalPrice -= price * productModel.number!;
    _totalWeight -= weight * productModel.number!;
    productModel.number = 0;
    _product.removeWhere((element) => element == productModel);
    print(
        "totalPrice: ${_totalPrice} , totalWeight: ${_totalWeight} , product: $_product");
    socketResponse.value = InvoiceModel(
        totalPrice: _totalPrice.toString() + " دينار عراقي ",
        totalWeight: _totalWeight.toString() + " غرام ",
        product: _product);
  }

  static void removeAll() {
    _totalPrice = 0;
    _totalWeight = 0;
    _product = [];

    socketResponse.value = InvoiceModel(
        totalPrice: _totalPrice.toString() + " دينار عراقي ",
        totalWeight: _totalWeight.toString() + " غرام ",
        product: _product);
  }
}
