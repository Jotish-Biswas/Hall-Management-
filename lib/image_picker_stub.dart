import 'package:flutter/material.dart';
import 'image_picker_interface.dart';

class StubImagePicker implements ImagePickerInterface {
  @override
  Future<void> pickAndUploadImage({
    required String email,
    required String baseUrl,
    required BuildContext context,
    required VoidCallback onSuccess,
    required String userType,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Platform not supported for image upload.')),
    );
  }
}
