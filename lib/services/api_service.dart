import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product_model.dart';

class ApiService {
  final String baseUrl;

  ApiService()
      : baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.infoproduk.id';

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/$barcode'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<bool> checkConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
