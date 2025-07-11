import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InventoryPage extends StatefulWidget {
  final String email;

  const InventoryPage({
    super.key,
    required this.email,
  });

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Map<String, dynamic>> _products = [];
  String shopName = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _fetchShopkeeperInfo();
    await _fetchProducts();
  }

  Future<void> _fetchShopkeeperInfo() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/inventory/shopkeeper/profile/${widget.email}"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          shopName = (data['shop_name'] != null && data['shop_name'].toString().isNotEmpty)
              ? data['shop_name']
              : ((data['shop_type'] != null && data['shop_type'].toString().isNotEmpty)
                  ? data['shop_type']
                  : "Shop");
        });
      } else {
        setState(() {
          shopName = "Unknown Shop";
        });
      }
    } catch (e) {
      setState(() {
        shopName = "Unknown Shop";
      });
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/inventory/${widget.email}"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _products = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          _products = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _products = [];
        isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(String productName) async {
    try {
      final response = await http.delete(
        Uri.parse("http://127.0.0.1:8000/inventory/remove"), // Correct endpoint here
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": widget.email,
          "name": productName,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product removed successfully")),
        );
        await _fetchProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to remove product")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while removing the product")),
      );
    }
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Product"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Product Name"),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price per unit"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final quantity = int.tryParse(quantityController.text.trim());
              final price = double.tryParse(priceController.text.trim());

              if (name.isNotEmpty && quantity != null && price != null) {
                final response = await http.post(
                  Uri.parse("http://127.0.0.1:8000/inventory/add"),
                  headers: {"Content-Type": "application/json"},
                  body: json.encode({
                    "email": widget.email,
                    "name": name,
                    "quantity": quantity,
                    "price": price,
                  }),
                );

                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Product added successfully")),
                  );
                  await _fetchProducts();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to add product")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields properly")),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showUpdateProductDialog(int index) {
    final product = _products[index];
    final nameController = TextEditingController(text: product['name']);
    final quantityController = TextEditingController(text: product['quantity'].toString());
    final priceController = TextEditingController(text: product['price'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Product"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Product Name"),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price per unit"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              final newQuantity = int.tryParse(quantityController.text.trim());
              final newPrice = double.tryParse(priceController.text.trim());

              if (newName.isNotEmpty && newQuantity != null && newPrice != null) {
                final response = await http.put(
                  Uri.parse("http://127.0.0.1:8000/inventory/update"),
                  headers: {"Content-Type": "application/json"},
                  body: json.encode({
                    "email": widget.email,
                    "old_name": product['name'],
                    "name": newName,
                    "quantity": newQuantity,
                    "price": newPrice,
                  }),
                );

                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Product updated successfully")),
                  );
                  await _fetchProducts();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to update product")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields properly")),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoading ? "Inventory" : shopName),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      backgroundColor: Colors.orange[50],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "Email: ${widget.email}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Products",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _products.isEmpty
                        ? const Center(child: Text("No products added yet."))
                        : ListView.builder(
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: const Icon(Icons.shopping_bag),
                                  title: Text(product['name']),
                                  subtitle: Text(
                                    "Quantity: ${product['quantity']} | Price: ৳${product['price'].toStringAsFixed(2)}",
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _showUpdateProductDialog(index),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                        child: const Text("Update"),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text("Confirm reomve"),
                                              content: Text("Are you sure you want to delete '${product['name']}'?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text("Cancel"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    await _deleteProduct(product['name']);
                                                  },
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  child: const Text("Remove"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        child: const Text("Remove"),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
