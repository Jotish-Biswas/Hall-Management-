import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // only works on web

Future<bool> pickAndUploadProfileImage({
  required String email,
  required String baseUrl,
  required BuildContext context,
  required VoidCallback onSuccess,
  required String userType, // e.g. 'student', 'teacher', 'shopkeeper', 'provost'
}) async {
  if (kIsWeb) {
    // Web picker
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    await uploadInput.onChange.first;

    final file = uploadInput.files?.first;
    if (file == null) return false;

    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    await reader.onLoad.first;

    final encodedImage = reader.result.toString().split(',').last;

    final url = Uri.parse('$baseUrl/users/$userType/${Uri.encodeComponent(email)}/upload-image');

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
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
      return false;
    }
  } else {
    // Mobile picker
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return false;

    final bytes = await File(pickedFile.path).readAsBytes();
    final encodedImage = base64Encode(bytes);

    final url = Uri.parse('$baseUrl/users/$userType/${Uri.encodeComponent(email)}/upload-image');

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
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
      return false;
    }
  }
}
