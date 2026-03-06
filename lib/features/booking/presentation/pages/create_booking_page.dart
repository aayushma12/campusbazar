import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_providers.dart';
import '../providers/booking_state.dart';

class CreateBookingPage extends ConsumerStatefulWidget {
  const CreateBookingPage({super.key});

  @override
  ConsumerState<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends ConsumerState<CreateBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();
  final _scheduleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.listen<BookingState>(bookingViewModelProvider, (previous, next) {
      if (!mounted) return;

      if (next.unauthorized) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }

      if (next.successMessage != null && next.successMessage!.isNotEmpty &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    });

    final state = ref.watch(bookingViewModelProvider);
    final isLoading = state.tutorRequestsStatus == TutorRequestsStatus.loading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/bookings', (route) => false);
            }
          },
        ),
        title: const Text('Request a Tutor', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              TextFormField(
                controller: _scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Preferred Schedule',
                  hintText: 'e.g. Mon-Fri 5 PM to 7 PM',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Tutor Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(bookingViewModelProvider.notifier).createTutorRequest(
            subject: _subjectController.text.trim(),
            description: _descController.text.trim(),
            schedule: _scheduleController.text.trim(),
          );
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }
}
