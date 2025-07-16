import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ServerLink.dart';

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
    final url = Uri.parse('$baseUrl/inventory/products/${widget.email}');
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

  Future<void> reactToProduct(String action, String productName) async {
    final url = Uri.parse('$baseUrl/inventory/$action');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": widget.email,
          "product_name": productName,
          "user_email": "student@example.com" // Replace with logged-in user's email
        }));
    if (response.statusCode == 200) {
      fetchProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonDecode(response.body)['detail'] ?? 'Error')),
      );
    }
  }

  Future<void> commentOnProduct(String productName) async {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Comment"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Write your comment...'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final url = Uri.parse('$baseUrl/inventory/comment');
                await http.post(url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      "email": widget.email,
                      "product_name": productName,
                      "text": text,
                      "user_email": "student@example.com"
                    }));
                Navigator.pop(context);
                fetchProducts();
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Widget buildProductCard(dynamic item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['image_base64'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  base64Decode(item['image_base64']),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            Text(item['name'] ?? 'No Name',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Quantity: ${item['quantity'] ?? 'N/A'}"),
            Text("Price: ${item['price'] ?? 'N/A'}"),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up),
                      onPressed: () => reactToProduct('like', item['name']),
                    ),
                    Text("${item['likes'] ?? 0}"),
                    IconButton(
                      icon: const Icon(Icons.thumb_down),
                      onPressed: () => reactToProduct('dislike', item['name']),
                    ),
                    Text("${item['dislikes'] ?? 0}"),
                  ],
                ),
                TextButton(
                  onPressed: () => commentOnProduct(item['name']),
                  child: const Text("Comment"),
                )
              ],
            ),
            if (item['comments'] != null && item['comments'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Comments:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ...item['comments'].map<Widget>((c) => Text("- ${c['user']}: ${c['text']}"))
                ],
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Products of ${widget.shopName}"),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) => buildProductCard(products[index]),
                ),
    );
  }
}
