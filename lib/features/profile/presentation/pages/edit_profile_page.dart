import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/profile_entity.dart';
import '../state/profile_state.dart';
import '../view_model/profile_viewmodel.dart';

/// Edit profile screen with pre-filled fields and form validation.
class EditProfilePage extends ConsumerStatefulWidget {
  final Profile initialProfile;

  const EditProfilePage({super.key, required this.initialProfile});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _batchController = TextEditingController();
  final _collegeIdController = TextEditingController();
  final _universityController = TextEditingController();
  final _campusController = TextEditingController();
  final _bioController = TextEditingController();

  final _picker = ImagePicker();
  File? _imageFile;
  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _nameController.text = p.name;
    _phoneController.text = p.phoneNumber ?? '';
    _studentIdController.text = p.studentId ?? '';
    _batchController.text = p.batch ?? '';
    _collegeIdController.text = p.collegeId ?? '';
    _universityController.text = p.university ?? '';
    _campusController.text = p.campus ?? '';
    _bioController.text = p.bio ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    _batchController.dispose();
    _collegeIdController.dispose();
    _universityController.dispose();
    _campusController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    final permission = await Permission.camera.status;

    if (permission.isDenied || permission.isRestricted) {
      final requested = await Permission.camera.request();
      if (!requested.isGranted) {
        await _showPermissionDialog(permanentlyDenied: requested.isPermanentlyDenied);
        return;
      }
    } else if (permission.isPermanentlyDenied) {
      await _showPermissionDialog(permanentlyDenied: true);
      return;
    }

    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    final capturedFile = File(picked.path);
    final confirmed = await _showCapturedPreview(capturedFile);

    if (confirmed == true) {
      await _processAndSetImage(capturedFile);
    } else if (confirmed == false) {
      await _pickFromCamera();
    }
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    await _processAndSetImage(File(picked.path));
  }

  Future<void> _processAndSetImage(File sourceFile) async {
    if (_isProcessingImage) return;

    setState(() => _isProcessingImage = true);
    try {
      final extension = sourceFile.path.split('.').last.toLowerCase();
      const allowed = {'jpg', 'jpeg', 'png'};
      if (!allowed.contains(extension)) {
        _showError('Only JPG and PNG files are supported.');
        return;
      }

      final cropped = await ImageCropper().cropImage(
        sourcePath: sourceFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 95,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Photo',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop Profile Photo',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (cropped == null) return;

      final targetPath = '${cropped.path}_optimized.jpg';
      final compressed = await FlutterImageCompress.compressAndGetFile(
        cropped.path,
        targetPath,
        quality: 80,
        minWidth: 512,
        minHeight: 512,
        format: CompressFormat.jpeg,
      );

      if (compressed == null) {
        _showError('Failed to process image. Please try again.');
        return;
      }

      final compressedFile = File(compressed.path);
      final size = await compressedFile.length();
      const maxSize = 5 * 1024 * 1024;
      if (size > maxSize) {
        _showError('Image is too large. Please select an image under 5MB.');
        return;
      }

      if (!mounted) return;
      setState(() => _imageFile = compressedFile);
    } catch (_) {
      _showError('Unable to process image. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isProcessingImage = false);
      }
    }
  }

  Future<bool?> _showCapturedPreview(File imageFile) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Preview Photo'),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(imageFile, fit: BoxFit.cover),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Retake'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm & Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionDialog({required bool permanentlyDenied}) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: Text(
          permanentlyDenied
              ? 'Camera access is permanently denied. Please enable it from Settings to take profile photos.'
              : 'Camera access is required to take a profile photo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (permanentlyDenied)
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
      if (!mounted) return;

      if (next.status == ProfileStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage ?? 'Profile updated successfully')),
        );
        Navigator.of(context).pop();
      }

      if (next.status == ProfileStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    final state = ref.watch(profileViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (widget.initialProfile.profilePicture != null &&
                                  widget.initialProfile.profilePicture!.isNotEmpty)
                              ? NetworkImage(widget.initialProfile.profilePicture!)
                              : null as ImageProvider?,
                      child: _imageFile == null &&
                              (widget.initialProfile.profilePicture == null ||
                                  widget.initialProfile.profilePicture!.isEmpty)
                          ? const Icon(Icons.person, size: 44)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton.filled(
                        onPressed: _isProcessingImage ? null : _showImageSourceOptions,
                        icon: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isProcessingImage)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Processing image...'),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              _field(_nameController, 'Name', requiredField: true),
              _field(_phoneController, 'Phone Number'),
              _field(_studentIdController, 'Student ID'),
              _field(_batchController, 'Batch'),
              _field(_collegeIdController, 'College ID'),
              _field(_universityController, 'University'),
              _field(_campusController, 'Campus'),
              _field(_bioController, 'Bio', maxLines: 3),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.status == ProfileStatus.updating
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;

                        await ref.read(profileViewModelProvider.notifier).updateProfile(
                              name: _nameController.text,
                              phoneNumber: _phoneController.text,
                              studentId: _studentIdController.text,
                              batch: _batchController.text,
                              collegeId: _collegeIdController.text,
                              university: _universityController.text,
                              campus: _campusController.text,
                              bio: _bioController.text,
                              imageFile: _imageFile,
                            );
                      },
                child: state.status == ProfileStatus.updating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool requiredField = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (!requiredField) return null;
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}
