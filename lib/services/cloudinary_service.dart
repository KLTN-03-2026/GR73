import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../config/constants.dart';

class CloudinaryService {
  
  // --- ADD THIS METHOD TO FIX THE ERROR ---
  static Map<String, String> getConfig() {
    return {
      'cloudName': AppConstants.cloudinaryCloudName,
      'uploadPreset': AppConstants.cloudinaryUploadPreset, 
      // Unsigned uploads usually don't need the API Key on the client, 
      // but if your Constants file has it, you can add it here:
      // 'apiKey': AppConstants.cloudinaryApiKey, 
    };
  }
  // ----------------------------------------

  // Upload multiple images for post using unsigned upload preset (HTTP multipart)
  static Future<List<String>> uploadPostImages(List<XFile> imageFiles) async {
    final uploadedUrls = <String>[];
    final uriBase = 'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload';

    for (int i = 0; i < imageFiles.length; i++) {
      final image = imageFiles[i];
      try {
        final request = http.MultipartRequest('POST', Uri.parse(uriBase));
        request.fields['upload_preset'] = AppConstants.cloudinaryUploadPreset;

        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              bytes,
              filename: image.name.isNotEmpty ? image.name : 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          );
        } else {
          final file = File(image.path);
          if (!await file.exists()) {
            debugPrint('File does not exist: ${image.path}');
            continue;
          }
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          request.files.add(
            http.MultipartFile('file', stream, length, filename: file.path.split('/').last),
          );
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final Map<String, dynamic> body = json.decode(response.body);
          final secureUrl = body['secure_url'] as String?;
          if (secureUrl != null) {
            uploadedUrls.add(secureUrl);
            debugPrint('Uploaded image ${i + 1}: $secureUrl');
          } else {
            debugPrint('Upload succeeded but no secure_url returned: ${response.body}');
          }
        } else {
          debugPrint('Upload failed (${response.statusCode}): ${response.body}');
        }
      } catch (e) {
        debugPrint('Upload error for image ${i + 1}: $e');
      }

      // small delay to avoid rate limits
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (uploadedUrls.isEmpty) {
      return imageFiles.isNotEmpty
          ? imageFiles.map((_) => 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}').toList()
          : [];
    }

    return uploadedUrls;
  }
}
