import 'package:flutter/material.dart';
import 'services/cloudinary_service.dart';
import 'services/image_picker_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // No dotenv.load() needed because you are using AppConstants

  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Test Cloudinary')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                debugPrint('Testing Cloudinary config...');
                
                final config = CloudinaryService.getConfig();
                
                // Print the config values to debug console
                debugPrint('Cloud Name: ${config['dhf4h81ab']}');
                debugPrint('Upload Preset: ${config['mobile_unsigned']}');
              },
              child: const Text('Test Config'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 1. Pick Image
                final image = await ImagePickerService.pickImageFromGallery();
                
                if (image != null) {
                  debugPrint('Image picked: ${image.path}');
                  
                  // 2. Upload Image
                  // We wrap the single image in a list [] because the service expects a list
                  final urls = await CloudinaryService.uploadPostImages([image]);
                  
                  if (urls.isNotEmpty) {
                    debugPrint('Upload successful: ${urls.first}');
                  } else {
                    debugPrint('Upload failed or returned empty list');
                  }
                } else {
                  debugPrint('No image selected');
                }
              },
              child: const Text('Pick & Upload Image'),
            ),
          ],
        ),
      ),
    ),
  ));
}
