import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/crop_model.dart';
import '../services/crop_service.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _variety = TextEditingController();
  final _area = TextEditingController();
  final _cropService = CropService.instance;
  final _imagePicker = ImagePicker();

  List<File> _selectedImages = [];
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _variety.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    print('🔵 Requesting camera permission...');
    final status = await Permission.camera.request();
    print('Camera permission status: $status');

    if (status.isGranted) {
      print('✅ Camera permission granted');
      return true;
    } else if (status.isDenied) {
      print('❌ Camera permission denied');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to take photos'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return false;
    } else if (status.isPermanentlyDenied) {
      print('❌ Camera permission permanently denied');
      if (mounted) {
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Camera Permission Required'),
            content: const Text(
              'Camera permission is permanently denied. Please enable it in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        if (openSettings == true) {
          await openAppSettings();
        }
      }
      return false;
    }
    return false;
  }

  Future<bool> _requestStoragePermission() async {
    print('🔵 Requesting storage/photos permission...');

    // For Android 13+ (API 33+), use photos permission
    // For older Android, use storage permission
    PermissionStatus status;

    // Try photos permission first (for Android 13+)
    status = await Permission.photos.request();
    print('Photos permission status: $status');

    // If photos permission not available, try storage
    if (status == PermissionStatus.denied) {
      status = await Permission.storage.request();
      print('Storage permission status: $status');
    }

    if (status.isGranted || status.isLimited) {
      print('✅ Storage/Photos permission granted');
      return true;
    } else if (status.isDenied) {
      print('❌ Storage/Photos permission denied');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to access photos'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return false;
    } else if (status.isPermanentlyDenied) {
      print('❌ Storage/Photos permission permanently denied');
      if (mounted) {
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Storage Permission Required'),
            content: const Text(
              'Storage permission is permanently denied. Please enable it in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        if (openSettings == true) {
          await openAppSettings();
        }
      }
      return false;
    }
    return false;
  }

  Future<void> _pickImageFromCamera() async {
    try {
      // Request camera permission first
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        print('❌ Camera permission not granted, aborting');
        return;
      }

      print('🔵 Opening camera...');
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo != null) {
        print('✅ Photo captured: ${photo.path}');
        setState(() {
          _selectedImages.add(File(photo.path));
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('📸 Photo captured!')));
        }
      } else {
        print('ℹ️ Camera cancelled by user');
      }
    } catch (e) {
      print('❌ Error picking image from camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      // Request storage permission first
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        print('❌ Storage permission not granted, aborting');
        return;
      }

      print('🔵 Opening gallery...');
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (images.isNotEmpty) {
        print('✅ ${images.length} image(s) selected');
        setState(() {
          _selectedImages.addAll(images.map((img) => File(img.path)));
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('🖼️ ${images.length} image(s) selected')),
          );
        }
      } else {
        print('ℹ️ Gallery cancelled by user');
      }
    } catch (e) {
      print('❌ Error picking images from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Please sign in first')));
      return;
    }

    setState(() => _loading = true);

    try {
      print('🔵 Starting crop submission...');

      // Create crop model
      final crop = CropModel(
        farmerId: user.uid,
        name: _name.text.trim(),
        variety: _variety.text.trim(),
        area: double.tryParse(_area.text) ?? 0.0,
        status: 'unknown',
      );

      // Add crop to Firestore
      final cropId = await _cropService.addCrop(crop);

      // Save images locally if any
      if (_selectedImages.isNotEmpty) {
        print('🔵 Saving ${_selectedImages.length} image(s) locally...');

        for (int i = 0; i < _selectedImages.length; i++) {
          if (!mounted) break;

          // Show progress
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '� Saving image ${i + 1}/${_selectedImages.length}...',
              ),
              duration: const Duration(seconds: 1),
            ),
          );

          // Save image locally and add path to crop
          final imagePath = await _cropService.saveImageLocally(
            cropId,
            _selectedImages[i],
          );
          await _cropService.addImagePathToCrop(cropId, imagePath);
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Crop added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      print('❌ Error submitting crop: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Crop'), elevation: 0),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving crop...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Crop Name
                    TextFormField(
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: 'Crop Name *',
                        hintText: 'e.g., Grapes, Tomatoes',
                        prefixIcon: const Icon(Icons.eco),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter crop name'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Variety
                    TextFormField(
                      controller: _variety,
                      decoration: InputDecoration(
                        labelText: 'Variety',
                        hintText: 'e.g., Thompson Seedless',
                        prefixIcon: const Icon(Icons.nature),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Area
                    TextFormField(
                      controller: _area,
                      decoration: InputDecoration(
                        labelText: 'Area (in acres)',
                        hintText: 'e.g., 2.5',
                        prefixIcon: const Icon(Icons.straighten),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter area';
                        if (double.tryParse(v) == null)
                          return 'Enter valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Image Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Crop Images',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_selectedImages.length} selected',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Add Image Button
                            OutlinedButton.icon(
                              onPressed: _showImageSourceDialog,
                              icon: const Icon(Icons.add_a_photo),
                              label: const Text('Add Images'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),

                            // Display selected images
                            if (_selectedImages.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              _selectedImages[index],
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () => _removeImage(index),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Save Crop',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
