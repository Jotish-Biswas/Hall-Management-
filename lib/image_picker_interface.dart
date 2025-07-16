import 'package:flutter/material.dart';

abstract class ImagePickerInterface {
  Future<void> pickAndUploadImage({
    required String email,
    required String baseUrl,
    required BuildContext context,
    required VoidCallback onSuccess,
    required String userType,
  });
}
