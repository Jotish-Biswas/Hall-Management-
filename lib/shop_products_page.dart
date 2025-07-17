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
  Set<String> expandedComments = {};

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
          "user_email": "student@example.com"
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
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            if (item['image_base64'] != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.memory(
                  base64Decode(item['image_base64']),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            
            // Product Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Quantity and Price
                  Row(
                    children: [
                      _buildDetailChip(
                        Icons.inventory_2,
                        '${item['quantity'] ?? 'N/A'} in stock',
                        Colors.blue[100]!,
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        Icons.attach_money,
                        '${item['price'] ?? 'N/A'}',
                        Colors.green[100]!,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Reaction Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildReactionButton(
                            Icons.thumb_up,
                            Colors.green,
                            '${item['likes'] ?? 0}',
                            () => reactToProduct('like', item['name']),
                          ),
                          const SizedBox(width: 12),
                          _buildReactionButton(
                            Icons.thumb_down,
                            Colors.red,
                            '${item['dislikes'] ?? 0}',
                            () => reactToProduct('dislike', item['name']),
                          ),
                        ],
                      ),
                      _buildCommentButton(isExpanded, () {
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
                  
                  // Comments Section
                  if (isExpanded) ...[
                    const Divider(height: 24),
                    if (item['comments'] != null && item['comments'].isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Comments:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...item['comments'].map<Widget>((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    "${c['user']}: ${c['text']}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    const SizedBox(height: 8),
                    
                    // Comment Input
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
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
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
      );
    });
  }

  Widget _buildDetailChip(IconData icon, String text, Color backgroundColor) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.black54),
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildReactionButton(
      IconData icon, Color color, String count, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: color.withOpacity(0.1),
      ),
      icon: Icon(icon, size: 18),
      label: Text(count),
    );
  }

  Widget _buildCommentButton(bool isExpanded, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.blue.withOpacity(0.1),
      ),
      icon: Icon(isExpanded ? Icons.comment : Icons.comment_outlined, size: 18),
      label: Text(isExpanded ? 'Hide' : 'Comment'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Products - ${widget.shopName}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) => buildProductCard(products[index]),
                  ),
                ),
    );
  }
}