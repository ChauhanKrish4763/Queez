import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();

  factory ImagePickerService() {
    return _instance;
  }

  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the gallery
  /// Returns the file path if successful, null otherwise
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      return image?.path;
    } catch (e) {
      rethrow;
    }
  }

  /// Picks an image from the camera
  /// Returns the file path if successful, null otherwise
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
      );
      return image?.path;
    } catch (e) {
      rethrow;
    }
  }
}
