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
  Set<String> expandedComments = {}; // to manage comment expansion

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

  Future<void> submitComment(String productName, String text) async {
    final url = Uri.parse('$baseUrl/inventory/comment');
    await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": widget.email,
          "product_name": productName,
          "text": text,
          "user_email": "student@example.com"
        }));
    fetchProducts();
  }

  Widget buildProductCard(dynamic item) {
    final TextEditingController commentController = TextEditingController();
    final isExpanded = expandedComments.contains(item['name']);

    return StatefulBuilder(builder: (context, setCardState) {
      return MouseRegion(
        onEnter: (_) => setCardState(() {}),
        onExit: (_) => setCardState(() {}),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (item['image_base64'] != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.memory(
                    base64Decode(item['image_base64']),
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'] ?? 'No Name',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("Quantity: ${item['quantity'] ?? 'N/A'}"),
                    Text("Price: ${item['price'] ?? 'N/A'}"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            buildReactionButton(Icons.thumb_up, Colors.green,
                                () => reactToProduct('like', item['name'])),
                            Text("${item['likes'] ?? 0}"),
                            const SizedBox(width: 10),
                            buildReactionButton(Icons.thumb_down, Colors.red,
                                () => reactToProduct('dislike', item['name'])),
                            Text("${item['dislikes'] ?? 0}"),
                          ],
                        ),
                        buildCommentButton(() {
                          setState(() {
                            if (isExpanded) {
                              expandedComments.remove(item['name']);
                            } else {
                              expandedComments.add(item['name']);
                            }
                          });
                        }),
                      ],
                    ),
                    if (isExpanded) ...[
                      const Divider(),
                      if (item['comments'] != null && item['comments'].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Comments:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 6),
                            ...item['comments'].map<Widget>((c) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Text("- ${c['user']}: ${c['text']}"),
                                  ),
                                )),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: "Write a comment...",
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.lightBlue),
                            onPressed: () {
                              final text = commentController.text.trim();
                              if (text.isNotEmpty) {
                                submitComment(item['name'], text);
                                commentController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildReactionButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.2),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget buildCommentButton(VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.lightBlue, width: 1.2),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.comment, color: Colors.lightBlue),
        label: const Text("Comment", style: TextStyle(color: Colors.lightBlue)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FA),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 154, 151, 151),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.arrow_back, color: Colors.lightBlue, size: 24),
            ),
          ),
        ),
        title: Text("Products of ${widget.shopName}", style: const TextStyle(color: Colors.white)),
        centerTitle: true,
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
