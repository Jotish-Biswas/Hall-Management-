import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shop_products_page.dart';

class ShopListPage extends StatefulWidget {
  final String hallname;

  const ShopListPage({super.key, required this.hallname});

  @override
  _ShopListPageState createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  List<dynamic> _shops = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchShopkeepers();
  }

  Future<void> _fetchShopkeepers() async {
    try {
      final url = Uri.parse(
          'http://127.0.0.1:8000/shopkeepers/emails_with_shoptypes?hall_name=${widget.hallname}'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _shops = data['shopkeepers'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load shops: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hallname} Shops'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _shops.isEmpty
          ? const Center(child: Text('No shops available in this hall'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _shops.length,
        itemBuilder: (context, index) {
          final shop = _shops[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.store, size: 40, color: Colors.blue),
              title: Text(
                shop['shop_type'] ?? 'Shop',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Owner: ${shop['full_name'] ?? 'Unknown'}'),
                  Text('Email: ${shop['email']}'),
                  Text('Phone: ${shop['phone'] ?? 'Not provided'}'),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to shop products page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShopProductsPage(
                      email: shop['email'] ?? '',
                      shopName: shop['shop_type'] ?? 'Shop',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}