import 'image_picker_interface.dart';
import 'image_picker_mobile.dart'
if (dart.library.html) 'image_picker_web.dart';

ImagePickerInterface getImagePicker() => getPlatformImagePicker();
