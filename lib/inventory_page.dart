import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class InventoryPage extends StatefulWidget {
  final String email;
  const InventoryPage({Key? key, required this.email}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _products = [];
  String shopName = "";
  bool isLoading = true;
  XFile? selectedImage;

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
      final resp = await http.get(Uri.parse("http://127.0.0.1:8000/inventory/shopkeeper/profile/${widget.email}"));
      final data = json.decode(resp.body);
      setState(() {
        shopName = data['shop_name'] ?? data['shop_type'] ?? 'Shop';
      });
    } catch (e) {
      setState(() {
        shopName = 'Unknown Shop';
      });
    }
  }

  Future<void> _fetchProducts() async {
    setState(() => isLoading = true);
    final resp = await http.get(Uri.parse("http://127.0.0.1:8000/inventory/${widget.email}"));
    setState(() {
      _products = resp.statusCode == 200
          ? List<Map<String, dynamic>>.from(json.decode(resp.body))
          : [];
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (img != null) setState(() => selectedImage = img);
  }

  void _showAddDialog() => showDialog(
        context: context,
        builder: (c) {
          final n = TextEditingController(), q = TextEditingController(), prc = TextEditingController();
          return AlertDialog(
            title: Text("Add Product"),
            content: SingleChildScrollView(
              child: Column(children: [
                TextField(controller: n..text = '', decoration: InputDecoration(labelText: "Name")),
                TextField(controller: q..text = '', decoration: InputDecoration(labelText: "Quantity"), keyboardType: TextInputType.number),
                TextField(controller: prc..text = '', decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
                ElevatedButton.icon(onPressed: _pickImage, icon: Icon(Icons.image), label: Text("Pick Image")),
                if (selectedImage != null) Text(p.basename(selectedImage!.path)),
              ]),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    selectedImage = null;
                    Navigator.of(c).pop();
                  },
                  child: Text("Cancel")),
              ElevatedButton(
                  onPressed: () async {
                    final name = n.text.trim();
                    final qty = int.tryParse(q.text.trim());
                    final price = double.tryParse(prc.text.trim());

                    if (name.isEmpty || qty == null || price == null) return;

                    Map<String, dynamic> body = {
                      "email": widget.email,
                      "name": name,
                      "quantity": qty,
                      "price": price
                    };

                    if (selectedImage != null) {
                      final bytes = await selectedImage!.readAsBytes();
                      final base64Str = base64Encode(bytes);
                      final fname = p.basename(selectedImage!.path);

                      body["image_base64"] = base64Str;
                      body["image_filename"] = fname;
                    }

                    final resp = await http.post(
                      Uri.parse("http://127.0.0.1:8000/inventory/add"),
                      headers: {"Content-Type": "application/json"},
                      body: json.encode(body),
                    );

                    if (resp.statusCode == 200) {
                      Navigator.of(c).pop();
                      selectedImage = null;
                      _fetchProducts();
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Error: ${resp.body}")));
                    }
                  },
                  child: Text("Add"))
            ],
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLoading ? "Loading..." : shopName)),
      floatingActionButton: FloatingActionButton(onPressed: _showAddDialog, child: Icon(Icons.add)),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (_, i) {
                final p = _products[i];
                final imgBytes = p['image_base64'] != null ? base64Decode(p['image_base64']) : null;
                return ListTile(
                  leading: imgBytes != null
                      ? Image.memory(imgBytes, width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.image),
                  title: Text(p['name']),
                  subtitle: Text("Qty: ${p['quantity']} | ৳${p['price']}"),
                );
              }),
    );
  }
}
