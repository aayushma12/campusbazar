import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../category/presentation/view_model/category_viewmodel.dart';
import '../../domain/entities/product_entity.dart';
import '../view_model/product_viewmodel.dart';

class CreateProductPage extends ConsumerStatefulWidget {
  const CreateProductPage({super.key});

  @override
  ConsumerState<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends ConsumerState<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _campusController = TextEditingController();
  
  bool _negotiable = false;
  String _condition = 'good';
  String? _selectedCategoryId;
  List<File> _imageFiles = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoryViewModelProvider.notifier).loadCategories();
    });
  }

  // Fallback categories if backend doesn't have categories endpoint
  final List<Map<String, String>> _fallbackCategories = [
    {'id': 'electronics', 'name': 'Electronics'},
    {'id': 'books', 'name': 'Books & Stationery'},
    {'id': 'fashion', 'name': 'Fashion & Clothing'},
    {'id': 'furniture', 'name': 'Furniture'},
    {'id': 'sports', 'name': 'Sports & Fitness'},
    {'id': 'vehicles', 'name': 'Vehicles'},
    {'id': 'services', 'name': 'Services'},
    {'id': 'other', 'name': 'Other'},
  ];

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(pickedFiles.map((f) => File(f.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productViewModelProvider);
    final categoryState = ref.watch(categoryViewModelProvider);
    
    // Use backend categories if available, otherwise use fallback
    final categories = categoryState.categories.isEmpty 
        ? _fallbackCategories 
        : categoryState.categories.map((c) => {'id': c.id, 'name': c.name}).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Post Product', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Images Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.photo_library, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        const Text('Product Images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_imageFiles.isEmpty)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text('Tap to add images', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _imageFiles.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(_imageFiles[index], width: 120, height: 120, fit: BoxFit.cover),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => _removeImage(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.add),
                            label: const Text('Add More Images'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        const Text('Product Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Product Title *',
                        hintText: 'e.g., iPhone 13 Pro Max',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        hintText: 'Describe your item in detail',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 4,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      hint: const Text('Select a category'),
                      items: categories.map<DropdownMenuItem<String>>((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['id'],
                          child: Text(cat['name']!),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                      validator: (v) => v == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _condition,
                      decoration: InputDecoration(
                        labelText: 'Condition *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.verified),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'new', child: Text('New')),
                        DropdownMenuItem(value: 'like-new', child: Text('Like New')),
                        DropdownMenuItem(value: 'good', child: Text('Good')),
                        DropdownMenuItem(value: 'fair', child: Text('Fair')),
                        DropdownMenuItem(value: 'poor', child: Text('Poor')),
                      ],
                      onChanged: (val) => setState(() => _condition = val!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Price & Location
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payment, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        const Text('Price & Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price *',
                        hintText: '0.00',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.attach_money),
                        suffixText: 'USD',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Price is required';
                        if (double.tryParse(v) == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Price is negotiable'),
                      subtitle: const Text('Buyers can offer their price'),
                      value: _negotiable,
                      activeColor: Colors.green,
                      onChanged: (val) => setState(() => _negotiable = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _campusController,
                      decoration: InputDecoration(
                        labelText: 'Campus/Location *',
                        hintText: 'e.g., Main Campus, North Campus',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Location is required' : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: productState.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: productState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Post Product', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one image'), backgroundColor: Colors.red),
        );
        return;
      }

      final product = Product(
        id: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text),
        negotiable: _negotiable,
        condition: _condition,
        categoryId: _selectedCategoryId!,
        campus: _campusController.text.trim(),
        images: [],
        status: 'available',
        ownerId: '',
        views: 0,
        createdAt: DateTime.now(),
      );
      
      await ref.read(productViewModelProvider.notifier).createProduct(product);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product posted successfully!'), backgroundColor: Colors.green),
      );
      
      // Return true to signal successful creation
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _campusController.dispose();
    super.dispose();
  }
}
