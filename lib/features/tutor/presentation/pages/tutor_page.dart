import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../booking/presentation/providers/booking_providers.dart';
import '../../../booking/presentation/providers/booking_state.dart';
import '../../../chat/presentation/providers/chat_providers.dart';

class TutorPage extends ConsumerStatefulWidget {
  const TutorPage({super.key});

  @override
  ConsumerState<TutorPage> createState() => _TutorPageState();
}

class _TutorPageState extends ConsumerState<TutorPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingViewModelProvider.notifier).loadTutorRequests();
    });
  }

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
      }
    });

    final state = ref.watch(bookingViewModelProvider);
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
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
        title: const Text("Find a Tutor", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/bookings'),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('My Bookings'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/createBooking'),
                    icon: const Icon(Icons.add),
                    label: const Text('Request Tutor'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blueGrey.withValues(alpha: 0.06),
              ),
              child: const Text(
                'Open Tutor Requests',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: state.tutorRequestsStatus == TutorRequestsStatus.loading && state.tutorRequests.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.tutorRequests.isEmpty
                      ? _buildEmptyState()
                      : isTablet
                          ? _buildTutorGrid(state)
                          : _buildTutorList(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorList(BookingState state) {
    return ListView.builder(
      itemCount: state.tutorRequests.length,
      itemBuilder: (context, index) => _buildTutorCard(state, index),
    );
  }

  Widget _buildTutorGrid(BookingState state) {
    return GridView.builder(
      itemCount: state.tutorRequests.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => _buildTutorCard(state, index),
    );
  }

  Widget _buildTutorCard(BookingState state, int index) {
    final request = state.tutorRequests[index];
    final canAccept = request.status.toLowerCase() == 'open';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(request.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${request.studentName} • ${request.schedule}'),
        trailing: canAccept
            ? FilledButton.tonal(
                onPressed: () async {
                  await ref.read(bookingViewModelProvider.notifier).acceptTutorRequest(request.id);
                  if (!mounted) return;

                  final chatId = await ref.read(chatNotifierProvider.notifier).openConversation(
                    tutorRequestId: request.id,
                  ); 

                  if (!mounted) return;
                  if (chatId != null && chatId.isNotEmpty) {
                    Navigator.pushNamed(
                      context,
                      '/chatDetail',
                      arguments: {'conversationId': chatId},
                    );
                  }
                },
                child: const Text('Accept'),
              )
            : Chip(
                label: Text(request.status.toUpperCase()),
                backgroundColor: Colors.green.withValues(alpha: 0.1),
              ),
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(request.subject),
              content: Text(request.description),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.school_outlined, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('No open tutor requests right now.'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => ref.read(bookingViewModelProvider.notifier).loadTutorRequests(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}