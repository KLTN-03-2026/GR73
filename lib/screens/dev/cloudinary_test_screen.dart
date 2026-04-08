import 'package:flutter/material.dart';
import '../../services/cloudinary_service.dart';
import '../../services/image_picker_service.dart';
import '../../widgets/common/wr_logo.dart';
import '../../config/app_router.dart';

class CloudinaryTestScreen extends StatefulWidget {
  const CloudinaryTestScreen({super.key});

  @override
  State<CloudinaryTestScreen> createState() => _CloudinaryTestScreenState();
}

class _CloudinaryTestScreenState extends State<CloudinaryTestScreen> {
  String? _cloudName;
  String? _preset;
  String? _lastUrl;
  String? _status;

  void _showMessage(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color ?? Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)),
          const SizedBox(width: 8),
          const Text('Test Cloudinary'),
        ]),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  final config = CloudinaryService.getConfig();
                  setState(() {
                    _cloudName = config['cloudName'];
                    _preset = config['uploadPreset'];
                    _status = 'Config loaded';
                  });
                  _showMessage('Cloud: $_cloudName • Preset: $_preset');
                },
                child: const Text('Test Config'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    setState(() {
                      _status = 'Picking image...';
                    });
                    final image = await ImagePickerService.pickImageFromGallery();
                    if (image == null) {
                      _showMessage('No image selected', color: Colors.orange);
                      return;
                    }
                    setState(() {
                      _status = 'Uploading...';
                    });
                    final urls = await CloudinaryService.uploadPostImages([image]);
                    if (urls.isNotEmpty) {
                      setState(() {
                        _lastUrl = urls.first;
                        _status = 'Upload successful';
                      });
                      _showMessage('Uploaded: ${urls.first}', color: Colors.green);
                    } else {
                      setState(() {
                        _status = 'Upload returned empty';
                      });
                      _showMessage('Upload failed or empty', color: Colors.red);
                    }
                  } catch (e) {
                    setState(() {
                      _status = 'Error: $e';
                    });
                    _showMessage('Error: $e', color: Colors.red);
                  }
                },
                child: const Text('Pick & Upload Image'),
              ),
              const SizedBox(height: 24),
              if (_cloudName != null && _preset != null)
                Text('Cloud: $_cloudName • Preset: $_preset'),
              const SizedBox(height: 12),
              if (_status != null)
                Text(_status!),
              const SizedBox(height: 12),
              if (_lastUrl != null)
                SizedBox(
                  height: 180,
                  child: Image.network(
                    _lastUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
