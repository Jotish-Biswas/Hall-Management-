import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'image_picker_interface.dart';

class MobileImagePicker implements ImagePickerInterface {
  @override
  Future<void> pickAndUploadImage({
    required String email,
    required String baseUrl,
    required BuildContext context,
    required VoidCallback onSuccess,
    required String userType,
  }) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final bytes = await file.readAsBytes();
    final encodedImage = base64Encode(bytes);

    final url = Uri.parse('$baseUrl/$userType/${Uri.encodeComponent(email)}/upload-image');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image_base64': encodedImage}),
    );

    if (response.statusCode == 200) {
      onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }
}

ImagePickerInterface getPlatformImagePicker() => MobileImagePicker();
