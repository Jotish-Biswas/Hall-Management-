import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'image_picker_interface.dart';

class WebImagePicker implements ImagePickerInterface {
  @override
  Future<void> pickAndUploadImage({
    required String email,
    required String baseUrl,
    required BuildContext context,
    required VoidCallback onSuccess,
    required String userType,
  }) async {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    await uploadInput.onChange.first;
    final file = uploadInput.files?.first;
    if (file == null) return;

    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    await reader.onLoad.first;

    final encodedImage = (reader.result as String).split(',').last;

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

ImagePickerInterface getPlatformImagePicker() => WebImagePicker();
