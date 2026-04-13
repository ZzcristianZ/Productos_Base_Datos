import 'package:flutter/material.dart';
import 'package:segundoparcial/domain/model/product_model.dart';


class ProductsNotifier extends ChangeNotifier {
  ProductsNotifier._();
  static final ProductsNotifier instance = ProductsNotifier._();

  ProductModel? _latest;
  ProductModel? get latest => _latest;

  void addProduct(ProductModel product) {
    _latest = product;
    notifyListeners();
  }

  void consume() {
    _latest = null;
  }
}