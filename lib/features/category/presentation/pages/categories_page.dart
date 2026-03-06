import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/category_viewmodel.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryViewModelProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
            }
          },
        ),
        title: const Text('Categories', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.categories.isEmpty
              ? const Center(child: Text('No categories found'))
              : ListView.builder(
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final c = state.categories[index];
                    return ListTile(
                      title: Text(c.name),
                      subtitle: Text(c.description ?? ''),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/products',
                        arguments: {'category': c.id},
                      ),
                    );
                  },
                ),
    );
  }
}
