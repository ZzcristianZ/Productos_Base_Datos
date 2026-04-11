import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:segundoparcial/config/const/product_const.dart';
import 'package:segundoparcial/domain/model/product_model.dart';

class ProductDatasource {
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final url = Uri.parse(ApiConstants.addProduct);

    final response = await http.post(
      url,
      headers: ApiConstants.headers,
      body: jsonEncode({
        "title":       data["title"],
        "description": data["description"],
        "price":       data["price"],
        "brand":       data["brand"],
        "category":    data["category"],
        "stock":       data["stock"],
        "rating":      data["rating"],
        "is_available": data["availabilityStatus"] == "In Stock",
        "tags":        data["tags"],
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear: ${response.statusCode} ${response.body}');
    }

    final List json = jsonDecode(response.body);
    return ProductModel.fromJson(json.first as Map<String, dynamic>);
  }

  Future<List<ProductModel>> getProducts({int limit = 5, int skip = 0}) async {
    final url = Uri.parse(
      '${ApiConstants.products}?order=id.desc&limit=$limit&offset=$skip',
    );

    final response = await http.get(url, headers: ApiConstants.headers);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener: ${response.statusCode}');
    }

    final List data = jsonDecode(response.body);
    return data
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}