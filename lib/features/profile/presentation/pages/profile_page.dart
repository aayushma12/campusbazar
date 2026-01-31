import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/profile_entity.dart';
import '../view_model/profile_viewmodel.dart';
import '../state/profile_state.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _batchController = TextEditingController();
  final _collegeIdController = TextEditingController();
  
  bool _isEditing = false;
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Fetch profile on init
    Future.microtask(() => ref.read(profileViewModelProvider.notifier).getProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    _batchController.dispose();
    _collegeIdController.dispose();
    super.dispose();
  }

  void _initControllers(Profile profile) {
    _nameController.text = profile.name;
    _phoneController.text = profile.phoneNumber ?? '';
    _studentIdController.text = profile.studentId ?? '';
    _batchController.text = profile.batch ?? '';
    _collegeIdController.text = profile.collegeId ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    ref.read(profileViewModelProvider.notifier).updateProfile(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      studentId: _studentIdController.text.trim(),
      batch: _batchController.text.trim(),
      collegeId: _collegeIdController.text.trim(),
      imageFile: _imageFile,
    );
    setState(() {
      _isEditing = false;
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final profile = state.profile;

    ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: Colors.green),
        );
        ref.read(profileViewModelProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(profileViewModelProvider.notifier).clearMessages();
      }
    });

    if (state.isLoading && profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: const Center(child: Text("Failed to load profile")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.green),
              onPressed: () {
                _initControllers(profile);
                setState(() => _isEditing = true);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // PROFILE PICTURE
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (profile.profilePicture != null && profile.profilePicture!.isNotEmpty
                            ? NetworkImage(profile.profilePicture!)
                            : null) as ImageProvider?,
                    child: _imageFile == null && (profile.profilePicture == null || profile.profilePicture!.isEmpty)
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              
              if (!_isEditing) ...[
                // VIEW MODE
                _buildInfoTile(Icons.person, "Full Name", profile.name),
                _buildInfoTile(Icons.email, "Email", profile.email),
                _buildInfoTile(Icons.phone, "Phone", profile.phoneNumber ?? "Not set"),
                _buildInfoTile(Icons.badge, "Student ID", profile.studentId ?? "Not set"),
                _buildInfoTile(Icons.group, "Batch", profile.batch ?? "Not set"),
                _buildInfoTile(Icons.school, "College ID", profile.collegeId ?? "Not set"),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text("Logout", style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                  ),
                ),
              ] else ...[
                // EDIT MODE
                _buildTextField(Icons.person, "Name", _nameController),
                _buildTextField(Icons.phone, "Phone", _phoneController),
                _buildTextField(Icons.badge, "Student ID", _studentIdController),
                _buildTextField(Icons.group, "Batch", _batchController),
                _buildTextField(Icons.school, "College ID", _collegeIdController),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}