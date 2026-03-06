import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking_entity.dart';
import '../../../payment/presentation/pages/booking_payment_page.dart';
import '../providers/booking_providers.dart';
import '../providers/booking_state.dart';

class BookingsPage extends ConsumerStatefulWidget {
  const BookingsPage({super.key});

  @override
  ConsumerState<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends ConsumerState<BookingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingViewModelProvider.notifier).loadBookings(role: 'student');
      ref.read(bookingViewModelProvider.notifier).loadWalletBalance();
    });
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      ref.read(bookingViewModelProvider.notifier).loadBookings(
            role: _tabController.index == 0 ? 'student' : 'tutor',
          );
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
    final isBusy = state.bookingStatus == BookingStatusUi.loading ||
        state.bookingStatus == BookingStatusUi.updating;

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
        title: const Text('Tutor Bookings', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          tabs: const [
            Tab(text: 'As Student'),
            Tab(text: 'As Tutor'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(bookingViewModelProvider.notifier).loadBookings(
                role: _tabController.index == 0 ? 'student' : 'tutor',
              );
          await ref.read(bookingViewModelProvider.notifier).loadWalletBalance();
        },
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Wallet Balance: Rs ${state.walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isBusy && state.bookings.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.bookings.isEmpty
                      ? const Center(child: Text('No bookings yet'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                          itemCount: state.bookings.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final booking = state.bookings[index];
                            final canPay = _tabController.index == 0 && booking.canPay;
                            final canCancel = booking.canCancel;

                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                                title: Text(booking.subject.isEmpty ? 'Tutoring Session' : booking.subject),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Status: ${booking.status}  •  Payment: ${booking.paymentStatus}\n'
                                    'Amount: Rs ${booking.totalAmount.toStringAsFixed(2)}  •  ${booking.sessionType}',
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'view') {
                                      _showBookingDetail(context, booking);
                                      return;
                                    }

                                    if (value == 'pay') {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => BookingPaymentPage(booking: booking),
                                        ),
                                      );
                                      if (!mounted) return;
                                      await ref.read(bookingViewModelProvider.notifier).loadBookings(
                                            role: _tabController.index == 0 ? 'student' : 'tutor',
                                          );
                                      return;
                                    }

                                    if (value == 'cancel') {
                                      await ref.read(bookingViewModelProvider.notifier).cancelBooking(booking.id);
                                      return;
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(value: 'view', child: Text('View')),
                                    if (canPay) const PopupMenuItem(value: 'pay', child: Text('Pay Now')),
                                    if (canCancel) const PopupMenuItem(value: 'cancel', child: Text('Cancel Booking')),
                                  ],
                                ),
                                onTap: () => _showBookingDetail(context, booking),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/createBooking'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBookingDetail(BuildContext context, BookingEntity booking) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.subject.isEmpty ? 'Tutoring Session' : booking.subject,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Tutor: ${booking.tutorName}'),
              Text('Student: ${booking.studentName}'),
              Text('Status: ${booking.status}'),
              Text('Payment: ${booking.paymentStatus}'),
              Text('Session Type: ${booking.sessionType}'),
              Text('Hours: ${booking.hours.toStringAsFixed(1)}'),
              Text('Rate/Hour: Rs ${booking.ratePerHour.toStringAsFixed(2)}'),
              Text('Total: Rs ${booking.totalAmount.toStringAsFixed(2)}'),
              if ((booking.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Description: ${booking.description}'),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
