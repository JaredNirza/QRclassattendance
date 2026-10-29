import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiController {
  static const String apiUrl = 'https://fakestoreapi.com/products';

  // Stores the raw JSON response string for emulated JSON display
  String rawJsonResponse = '';

  /// Executes HTTP GET request and maps the JSON array to a List of Products
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        rawJsonResponse = response.body;

        // Requirement: JSON Array to Product Mapping
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load catalog. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Offline fallback: CITE Department Merchandise & Student Services
      final fallbackData = [
        {
          "id": 1,
          "title": "CITE Department Official Lanyard & ID Holder",
          "price": 150.0,
          "description": "Official sublimation lanyard with quick-release buckle and card case.",
          "category": "Merchandise",
          "image": "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg"
        },
        {
          "id": 2,
          "title": "AITES College Polo Shirt (BSIT Edition)",
          "price": 450.0,
          "description": "High-quality honeycomb cotton polo shirt with embroidered CITE emblem.",
          "category": "Apparel",
          "image": "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg"
        },
        {
          "id": 3,
          "title": "JMCFI RFID Student Card Replacement Service",
          "price": 200.0,
          "description": "Fast-track digital smart card issuance for laboratory and library access.",
          "category": "Student Services",
          "image": "https://fakestoreapi.com/img/71li-ujtlUL._AC_UX679_.jpg"
        },
        {
          "id": 4,
          "title": "CITE Tech Lab Attendance Pass & Locker Rental",
          "price": 300.0,
          "description": "One semester secured locker subscription for IT laboratory students.",
          "category": "Student Services",
          "image": "https://fakestoreapi.com/img/71pWzhdJNwL._AC_UL640_QL65_ML3_.jpg"
        }
      ];
      rawJsonResponse = const JsonEncoder.withIndent('  ').convert(fallbackData);
      return fallbackData.map((item) => Product.fromJson(item)).toList();
    }
  }
}
