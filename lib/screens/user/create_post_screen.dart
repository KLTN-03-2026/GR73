import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../models/post.dart';
import 'package:App_WRStudios/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../services/cloudinary_service.dart';
import '../../services/image_picker_service.dart';
import '../../services/location_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../config/app_router.dart';
import '../../config/constants.dart';
import '../../widgets/common/wr_logo.dart';

import '../../services/ai_service.dart';
import '../../widgets/custom_image_picker.dart'; // Import custom picker

class CreatePostScreen extends StatefulWidget {
  final Post? postToEdit;

  const CreatePostScreen({super.key, this.postToEdit});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  final List<XFile> _selectedImages = [];
  List<String> _existingImages = []; // Store existing image URLs when editing
  bool _isUploading = false;
  
  int _bedrooms = 1;
  int _bathrooms = 1;
  double _area = 30.0;
  List<String> _selectedAmenities = [];
  double? _lat;
  double? _lng;
  String _type = 'Căn hộ';
  final List<String> _types = const ['Căn hộ','Nhà riêng','Phòng trọ','Văn phòng','Penthouse'];
  
  final List<String> _amenities = [
    'Nội thất đầy đủ', // Added for AI
    'Máy lạnh',
    'Máy giặt',
    'Tủ bếp',
    'Internet',
    'Truyền hình cáp',
    'Chỗ đậu xe',
    'Bảo vệ 24/7',
    'Hồ bơi',
    'Phòng gym',
    'Khu vui chơi trẻ em',
    'Ban công/sân thượng',
    'Hệ thống an ninh',
    'Thang máy',
    'Nhà để xe',
    'Cửa sổ lớn',
  ];

  String _getLocalizedAmenity(BuildContext context, String amenity) {
    final loc = AppLocalizations.of(context)!;
    switch (amenity) {
      case 'Máy lạnh': return loc.amenityAC;
      case 'Máy giặt': return loc.amenityWashingMachine;
      case 'Tủ bếp': return loc.amenityKitchen;
      case 'Internet': return loc.amenityInternet;
      case 'Truyền hình cáp': return loc.amenityCableTV;
      case 'Chỗ đậu xe': return loc.amenityParking;
      case 'Bảo vệ 24/7': return loc.amenitySecurity;
      case 'Hồ bơi': return loc.amenityPool;
      case 'Phòng gym': return loc.amenityGym;
      case 'Khu vui chơi trẻ em': return loc.amenityPlayground;
      case 'Ban công/sân thượng': return loc.amenityBalcony;
      case 'Hệ thống an ninh': return loc.amenitySecuritySystem;
      case 'Thang máy': return loc.amenityElevator;
      case 'Nhà để xe': return loc.amenityGarage;
      case 'Cửa sổ lớn': return loc.amenityLargeWindows;
      case 'Nội thất đầy đủ': return loc.amenityFurnished;
      default: return amenity;
    }
  }

  String _getLocalizedType(BuildContext context, String type) {
    final loc = AppLocalizations.of(context)!;
    switch (type) {
      case 'Căn hộ': return loc.apartment;
      case 'Nhà riêng': return loc.house;
      case 'Phòng trọ': return loc.room;
      case 'Văn phòng': return loc.office;
      case 'Penthouse': return loc.penthouse;
      default: return type;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.postToEdit != null) {
      _loadPostData();
    } else {
      _loadUserData();
    }
  }

  void _loadPostData() {
    final post = widget.postToEdit!;
    _titleController.text = post.title;
    _descriptionController.text = post.description;
    _priceController.text = post.price.toStringAsFixed(0);
    _addressController.text = post.address;
    _cityController.text = post.city;
    _areaController.text = post.area.toStringAsFixed(0);
    _contactPhoneController.text = post.contactPhone ?? '';
    _contactEmailController.text = post.contactEmail ?? '';
    _bedrooms = post.bedrooms;
    _bathrooms = post.bathrooms;
    _area = post.area;
    _selectedAmenities = List.from(post.amenities);
    _type = post.type;
    _existingImages = List.from(post.images);
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user != null) {
      _contactPhoneController.text = user.phone ?? '';
      _contactEmailController.text = user.email;
    }
  }

  Future<void> _captureLocation() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.locationError), backgroundColor: Colors.red));
      return;
    }
    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.locationSuccess), backgroundColor: Colors.green));
  }

  // ============ AI FEATURES ============

  Future<void> _suggestPrice() async {
    if (_area <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterAreaForPrice), backgroundColor: Colors.orange),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.analyzingMarket), backgroundColor: Colors.blue),
    );

    // Use default city if not provided to fetch general market data
    final searchCity = _cityController.text.isNotEmpty ? _cityController.text : 'Hồ Chí Minh';

    final suggestedPrice = await AIService.predictPrice(
      city: searchCity,
      type: _type,
      area: _area,
      bedrooms: _bedrooms,
      amenities: _selectedAmenities,
    );

    if (!mounted) return;

    if (suggestedPrice != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.aiPriceSuggestion),
          content: Text('${AppLocalizations.of(context)!.basedOn(_area.toStringAsFixed(0), _getLocalizedType(context, _type), _selectedAmenities.length)}\n\n${(suggestedPrice).toStringAsFixed(0)} VNĐ'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.close),
            ),
            ElevatedButton(
              onPressed: () {
                _priceController.text = suggestedPrice.toStringAsFixed(0);
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.apply),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa đủ dữ liệu để gợi ý giá'), backgroundColor: Colors.orange),
      );
    }
  }

  Future<void> _analyzeImages(List<File> images) async {
    if (images.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.aiAnalyzingImages), 
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );
    
    final Set<String> suggestedAmenities = {};
    
    for (final image in images) {
      final suggestions = await AIService.analyzeImage(image);
      suggestedAmenities.addAll(suggestions);
    }
    
    if (suggestedAmenities.isNotEmpty) {
      setState(() {
        for (final amenity in suggestedAmenities) {
          if (!_selectedAmenities.contains(amenity)) {
             _selectedAmenities.add(amenity);
          }
        }
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.autoAdded(suggestedAmenities.map((e) => _getLocalizedAmenity(context, e)).join(", "))), 
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _pickImages() async {
    // Sử dụng CustomImagePicker để tránh lỗi Native Picker trên Simulator
    if (Platform.isIOS) {
      final List<File>? files = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomImagePicker(maxImages: 5),
        ),
      );

      if (files != null && files.isNotEmpty) {
        if (!mounted) return;
        
        // Manual limit check
        if (_selectedImages.length + files.length > 5) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.maxImagesLimit(5)),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _selectedImages.addAll(files.map((f) => XFile(f.path)));
        });

        // AI Analyze
        _analyzeImages(files);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.addedNImages(files.length)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Android/Web vẫn dùng logic cũ
    try {
      final images = await ImagePickerService.pickMultipleImages();
      
      if (images.isNotEmpty) {
        if (!mounted) return;
        
        // Manual limit check in UI
        if (_selectedImages.length + images.length > 5) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.maxImagesLimit(5)),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _selectedImages.addAll(images);
        });

        // AI Analyze (skip on web due to File API not available)
        if (!kIsWeb) {
          _analyzeImages(images.map((x) => File(x.path)).toList());
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.addedNImages(images.length)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.photoPickError(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Files picker helper removed (handled in Service)


  Future<void> _takePhoto() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.maxImagesLimit(5)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final image = await ImagePickerService.takePhotoWithCamera();
      if (image != null) {
        if (!mounted) return;
        setState(() { _selectedImages.add(image); });
        
        // AI Analyze
        _analyzeImages([File(image.path)]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.photoAdded),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.photoCaptureError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    // If we have existing images and no new images, just return existing
    if (_selectedImages.isEmpty && _existingImages.isNotEmpty) {
      return _existingImages;
    }

    // If both empty, return fallback
    if (_selectedImages.isEmpty && _existingImages.isEmpty) {
      return [
        'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}',
        'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch + 1}',
      ];
    }
    
    setState(() { _isUploading = true; });
    try {
      // Upload new images
      List<String> newUploadedUrls = [];
      if (_selectedImages.isNotEmpty) {
        newUploadedUrls = await CloudinaryService.uploadPostImages(_selectedImages);
      }
      
      // Combine existing + new
      List<String> finalUrls = [..._existingImages, ...newUploadedUrls];

      if (finalUrls.isEmpty) {
         return [
          'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}',
        ];
      }
      return finalUrls;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.uploadError(e.toString())), backgroundColor: Colors.red),
      );
      }
      // Return existing images if upload fails, or random if nothing
      if (_existingImages.isNotEmpty) return _existingImages;
      return [
        'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}',
      ];
    } finally {
      if (mounted) {
        setState(() { _isUploading = false; });
      }
    }
  }

  Widget _buildImageGrid() {
    final totalImages = _existingImages.length + _selectedImages.length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.propertyImages,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.imageUploadHint,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        
        if (totalImages == 0)
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.addPhoto,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: totalImages + 1,
              itemBuilder: (context, index) {
                if (index == totalImages) {
                  return GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 32, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.add,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Display logic: Existing images first, then new images
                Widget imageWidget;
                VoidCallback onRemove;
                
                if (index < _existingImages.length) {
                  // Existing image (URL)
                  final url = _existingImages[index];
                  final isHttp = url.startsWith('http://') || url.startsWith('https://');
                  imageWidget = isHttp
                      ? Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, loading) {
                            if (loading == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (_, __, ___) => const Icon(Icons.error),
                        )
                      : const Icon(Icons.image_not_supported);
                  onRemove = () {
                    setState(() {
                      _existingImages.removeAt(index);
                    });
                  };
                } else {
                  // New image (File)
                  final newIndex = index - _existingImages.length;
                  final file = File(_selectedImages[newIndex].path);
                  imageWidget = Image.file(
                    file,
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                  );
                  onRemove = () {
                    setState(() {
                      _selectedImages.removeAt(newIndex);
                    });
                  };
                }

                return Stack(
                  children: [
                    Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageWidget,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.54),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.library),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.camera),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }



  // ============ TEMPLATE HANDLING ============

  void _showTemplates() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.postTemplates,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildTemplateItem(
                      'Căn hộ Studio tiện nghi',
                      'Cho thuê căn hộ Studio full nội thất, vị trí trung tâm, giờ giấc tự do, an ninh 24/7.',
                      '6000000',
                      ['Máy lạnh', 'Tủ bếp', 'Internet', 'Bảo vệ 24/7'],
                    ),
                    _buildTemplateItem(
                      'Căn hộ 2 phòng ngủ cao cấp',
                      'Căn hộ 2PN, 2WC view đẹp, nội thất sang trọng, tiện ích hồ bơi, gym. Thích hợp gia đình.',
                      '12000000',
                      ['Máy lạnh', 'Máy giặt', 'Hồ bơi', 'Phòng gym', 'Thang máy'],
                    ),
                    _buildTemplateItem(
                      'Phòng trọ giá rẻ sinh viên',
                      'Phòng trọ sạch sẽ, thoáng mát, gần các trường đại học, khu vực an ninh, không chung chủ.',
                      '3000000',
                      ['Internet', 'Chỗ đậu xe', 'Nhà để xe'],
                    ),
                    _buildTemplateItem(
                      'Văn phòng cho thuê',
                      'Văn phòng diện tích lớn, ánh sáng tự nhiên, vị trí mặt tiền, thuận tiện giao thông.',
                      '20000000',
                      ['Máy lạnh', 'Thang máy', 'Bảo vệ 24/7', 'Chỗ đậu xe'],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemplateItem(String title, String desc, String price, List<String> amenities) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _titleController.text = title;
          _descriptionController.text = desc;
          _priceController.text = price;
          setState(() {
            _selectedAmenities = List.from(amenities);
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.applyTemplate), backgroundColor: Colors.green),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  // ============ FORM SUBMISSION ============

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final postProvider = context.read<PostProvider>();
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseLoginToPost),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.login,
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ),
      );
      return;
    }

    // Show loading
    setState(() {
      _isUploading = true;
    });

    try {
      // Upload images to Cloudinary
      final imageUrls = await _uploadImages();

      // Create post object
      final post = Post(
        id: widget.postToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        type: _type,
        lat: _lat,
        lng: _lng,
        area: _area,
        bedrooms: _bedrooms,
        bathrooms: _bathrooms,
        images: imageUrls,
        owner: user,
        isAvailable: true,
        isApproved: widget.postToEdit?.isApproved ?? false,
        createdAt: widget.postToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        amenities: _selectedAmenities,
        contactPhone: _contactPhoneController.text.trim().isNotEmpty
            ? _contactPhoneController.text.trim()
            : null,
        contactEmail: _contactEmailController.text.trim().isNotEmpty
            ? _contactEmailController.text.trim()
            : null,
      );

      // Save to Firestore
      if (widget.postToEdit != null) {
        await postProvider.updatePost(post.id, post);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.updatePostSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        await postProvider.createPost(post);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.createPostSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Navigate back
      if (!mounted) return;
      Navigator.pop(context);
      if (widget.postToEdit != null) {
        Navigator.pushReplacementNamed(context, AppRouter.myPosts);
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.error}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // ============ UI BUILD ============

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)),
          const SizedBox(width: 8),
          Text(widget.postToEdit != null ? AppLocalizations.of(context)!.editPost : AppLocalizations.of(context)!.createPost),
        ]),
        actions: [
          IconButton(
            onPressed: _showTemplates,
            icon: const Icon(Icons.description_outlined),
            tooltip: AppLocalizations.of(context)!.postTemplates,
          ),
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              _buildImageGrid(),
              const SizedBox(height: 32),

              // Basic Information
              Text(
                AppLocalizations.of(context)!.basicInfo,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _titleController,
                labelText: AppLocalizations.of(context)!.titleLabel,
                hintText: AppLocalizations.of(context)!.titleHint,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.titleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                labelText: AppLocalizations.of(context)!.descLabel,
                hintText: AppLocalizations.of(context)!.descHint,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.descriptionRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final text = await AIService.generateDescription(
                      type: _type,
                      area: _area,
                      bedrooms: _bedrooms,
                      bathrooms: _bathrooms,
                      city: _cityController.text.trim().isEmpty ? 'Hồ Chí Minh' : _cityController.text.trim(),
                      amenities: _selectedAmenities,
                    );
                    setState(() {
                      _descriptionController.text = text;
                    });
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.aiDescSuccess), backgroundColor: Colors.green),
                    );
                  },
                  icon: const Icon(Icons.auto_fix_high),
                  label: Text(AppLocalizations.of(context)!.aiDesc),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      labelText: AppLocalizations.of(context)!.priceLabel,
                      hintText: '5000000',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppConstants.priceRequired;
                        }
                        if (double.tryParse(value) == null) {
                          return AppLocalizations.of(context)!.enterValidNumber;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _areaController,
                      labelText: AppLocalizations.of(context)!.areaLabel,
                      hintText: '30',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _area = double.tryParse(value) ?? 30.0;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.enterArea;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _suggestPrice,
                      icon: const Icon(Icons.psychology, color: Colors.blue),
                      tooltip: AppLocalizations.of(context)!.aiPrice,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: ElevatedButton.icon(onPressed: _captureLocation, icon: const Icon(Icons.my_location), label: Text(AppLocalizations.of(context)!.getCurrentLocation))),
                const SizedBox(width: 12),
                Expanded(child: Text(_lat != null ? 'Lat: ${_lat!.toStringAsFixed(5)} • Lng: ${_lng!.toStringAsFixed(5)}' : AppLocalizations.of(context)!.noLocation)), 
              ]),

              CustomTextField(
                controller: _addressController,
                labelText: AppLocalizations.of(context)!.addressLabel,
                hintText: AppLocalizations.of(context)!.addressHint,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.addressRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _cityController,
                labelText: AppLocalizations.of(context)!.cityLabel,
                hintText: AppLocalizations.of(context)!.cityHint,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.cityRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Property Type
              Text(
                AppLocalizations.of(context)!.propertyType,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _types.map((t) {
                  final selected = _type == t;
                  return ChoiceChip(
                    label: Text(_getLocalizedType(context, t)),
                    selected: selected,
                    onSelected: (_) => setState(() => _type = t),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    labelStyle: TextStyle(color: selected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Property Specifications
              Text(
                AppLocalizations.of(context)!.propertySpecs,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.bedrooms}: $_bedrooms',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Slider(
                          value: _bedrooms.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: _bedrooms.toString(),
                          onChanged: (value) {
                          setState(() {
                            _bedrooms = value.round();
                          });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.bathrooms}: $_bathrooms',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Slider(
                          value: _bathrooms.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: _bathrooms.toString(),
                          onChanged: (value) {
                          setState(() {
                            _bathrooms = value.round();
                          });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Amenities
              Text(
                AppLocalizations.of(context)!.amenities,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.selectAmenities,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _amenities.map((amenity) {
                  final isSelected = _selectedAmenities.contains(amenity);
                  return ChoiceChip(
                    label: Text(_getLocalizedAmenity(context, amenity)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAmenities.add(amenity);
                        } else {
                          _selectedAmenities.remove(amenity);
                        }
                      });
                    },
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Contact Information
              Text(
                'Thông tin liên hệ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _contactPhoneController,
                labelText: 'Số điện thoại liên hệ',
                hintText: '0987654321',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.phoneRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _contactEmailController,
                labelText: 'Email liên hệ',
                hintText: 'email@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),

              // Submit Button
              if (_isUploading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                CustomButton(
                  onPressed: _submitForm,
                  text: widget.postToEdit != null ? 'Cập nhật tin đăng' : 'Đăng tin',
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }
}
