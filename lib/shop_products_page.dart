import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopProductsPage extends StatefulWidget {
  final String email;
  final String shopName;

  const ShopProductsPage({
    super.key,
    required this.email,
    required this.shopName,
  });

  @override
  State<ShopProductsPage> createState() => _ShopProductsPageState();
}

class _ShopProductsPageState extends State<ShopProductsPage> {
  List<dynamic> products = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('http://127.0.0.1:8000/inventory/products/${widget.email}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          products = data['products'] ?? [];
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = 'Still no products have been added.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // ✅ Soft background
      appBar: AppBar(
        title: Text("Products of ${widget.shopName}"),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(fontSize: 16, color: Colors.redAccent),
                  ),
                )
              : products.isEmpty
                  ? const Center(child: Text("No products have been added."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final item = products[index];
                        return Card(
                          elevation: 3,
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? 'No Name',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Quantity: ${item['quantity'] ?? 'N/A'}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "Price: ${item['price'] ?? 'N/A'}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
