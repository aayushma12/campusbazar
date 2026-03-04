import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../category/presentation/view_model/category_viewmodel.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_state.dart';
import '../providers/products_providers.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final ProductEntity? existingProduct;

  const ProductFormPage({super.key, this.existingProduct});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _newCategoryController = TextEditingController();
  final _campusController = TextEditingController();

  static const String _otherCategoryValue = '__other__';

  String _condition = 'good';
  bool _negotiable = false;
  String? _selectedCategoryId;
  bool _isOtherCategory = false;
  final List<File> _pickedImages = [];
  final _picker = ImagePicker();

  bool get _isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    if (p != null) {
      _titleController.text = p.title;
      _descController.text = p.description;
      _priceController.text = p.price.toString();
      _selectedCategoryId = p.categoryId;
      _campusController.text = p.campus;
      _condition = p.condition;
      _negotiable = p.negotiable;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryViewModelProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _newCategoryController.dispose();
    _campusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProductState>(productsNotifierProvider, (previous, next) {
      if (!mounted) return;

      if (next.unauthorized) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }

      if (next.status == ProductStatusState.success && next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.successMessage!)));
      }
    });

    final state = ref.watch(productsNotifierProvider);
    final categoryState = ref.watch(categoryViewModelProvider);
    final busy = state.status == ProductStatusState.creating || state.status == ProductStatusState.updating;

    final categoryItems = <DropdownMenuItem<String>>[
      ...categoryState.categories
          .map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name)))
          .toList(),
      const DropdownMenuItem<String>(value: _otherCategoryValue, child: Text('Other (Add New)')),
    ];

    final hasSelectedCategoryInList = _selectedCategoryId != null &&
        categoryItems.any((item) => item.value == _selectedCategoryId);

    if (!_isOtherCategory && _selectedCategoryId != null && !hasSelectedCategoryInList) {
      final fallbackName = (widget.existingProduct?.categoryName.isNotEmpty ?? false)
          ? widget.existingProduct!.categoryName
          : 'Current Category';
      categoryItems.insert(
        0,
        DropdownMenuItem<String>(
          value: _selectedCategoryId,
          child: Text('$fallbackName (current)'),
        ),
      );
    }

    final dropdownValue = _isOtherCategory ? _otherCategoryValue : _selectedCategoryId;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Product' : 'Create Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Price is required';
                  if (double.tryParse(v) == null) return 'Enter a valid price';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: dropdownValue,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: const OutlineInputBorder(),
                  helperText: 'Select a category, or choose Other to add a new one',
                  suffixIcon: categoryState.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          tooltip: 'Refresh categories',
                          onPressed: () => ref.read(categoryViewModelProvider.notifier).loadCategories(),
                          icon: const Icon(Icons.refresh),
                        ),
                ),
                items: categoryItems,
                onChanged: busy
                    ? null
                    : (value) {
                        setState(() {
                          if (value == _otherCategoryValue) {
                            _isOtherCategory = true;
                            _selectedCategoryId = null;
                          } else {
                            _isOtherCategory = false;
                            _selectedCategoryId = value;
                          }
                        });
                      },
                validator: (v) {
                  if (_isOtherCategory) {
                    if (_newCategoryController.text.trim().isEmpty) {
                      return 'Please enter a new category name';
                    }
                    return null;
                  }

                  if (v == null || v.isEmpty) return 'Category is required';
                  return null;
                },
              ),
              if (_isOtherCategory) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'New Category Name',
                    border: OutlineInputBorder(),
                    hintText: 'e.g. Stationery, Lab Equipment',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (!_isOtherCategory) return null;
                    if (v == null || v.trim().isEmpty) return 'Please enter a category name';
                    if (v.trim().length < 2) return 'Category name must be at least 2 characters';
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _condition,
                decoration: const InputDecoration(labelText: 'Condition', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'new', child: Text('New')),
                  DropdownMenuItem(value: 'like_new', child: Text('Like New')),
                  DropdownMenuItem(value: 'good', child: Text('Good')),
                  DropdownMenuItem(value: 'fair', child: Text('Fair')),
                  DropdownMenuItem(value: 'poor', child: Text('Poor')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _condition = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _campusController,
                decoration: const InputDecoration(labelText: 'Campus', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campus is required' : null,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _negotiable,
                title: const Text('Negotiable'),
                onChanged: (value) => setState(() => _negotiable = value),
                contentPadding: EdgeInsets.zero,
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < _pickedImages.length; i++)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_pickedImages[i], width: 84, height: 84, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: IconButton(
                                onPressed: () => setState(() => _pickedImages.removeAt(i)),
                                icon: const Icon(Icons.cancel, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      OutlinedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Add Images'),
                      ),
                    ],
                  ),
                ),
                if (_pickedImages.isEmpty)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('At least one image is required', style: TextStyle(color: Colors.red)),
                    ),
                  ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: busy ? null : _submit,
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Update Product' : 'Create Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final selected = await _picker.pickMultiImage();
    if (selected.isEmpty) return;
    setState(() {
      _pickedImages.addAll(selected.map((e) => File(e.path)));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditing && _pickedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final campus = _campusController.text.trim();

    final notifier = ref.read(productsNotifierProvider.notifier);
    final categoryNotifier = ref.read(categoryViewModelProvider.notifier);

    String? categoryId;
    if (_isOtherCategory) {
      final created = await categoryNotifier.createCategory(_newCategoryController.text.trim());
      if (!mounted) return;
      if (created == null || created.id.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to create category. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _selectedCategoryId = created.id;
        _isOtherCategory = false;
      });
      categoryId = created.id;
    } else {
      categoryId = _selectedCategoryId;
    }

    if (categoryId == null || categoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool ok;
    if (_isEditing) {
      ok = await notifier.updateProduct(
        id: widget.existingProduct!.id,
        title: title,
        description: description,
        price: price,
        categoryId: categoryId,
        condition: _condition,
        campus: campus,
        negotiable: _negotiable,
      );
    } else {
      ok = await notifier.createProduct(
        title: title,
        description: description,
        price: price,
        categoryId: categoryId,
        condition: _condition,
        campus: campus,
        negotiable: _negotiable,
        images: _pickedImages,
      );
    }

    if (!mounted) return;
    if (ok) Navigator.pop(context, true);
  }
}
