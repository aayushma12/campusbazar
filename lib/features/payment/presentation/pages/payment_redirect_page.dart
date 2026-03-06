import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../booking/presentation/providers/booking_providers.dart';
import '../../../booking/presentation/providers/booking_state.dart';
import '../../domain/entities/payment_entity.dart';
import '../providers/payment_providers.dart';
import '../providers/payment_state.dart';
import 'payment_failure_page.dart';
import 'payment_success_page.dart';

class PaymentRedirectPageArgs {
  final Payment payment;
  final PaymentFlowType flowType;
  final String? purchasedProductId;
  final String? bookingId;

  const PaymentRedirectPageArgs({
    required this.payment,
    required this.flowType,
    this.purchasedProductId,
    this.bookingId,
  });
}

class PaymentRedirectPage extends ConsumerStatefulWidget {
  final PaymentRedirectPageArgs args;

  const PaymentRedirectPage({super.key, required this.args});

  @override
  ConsumerState<PaymentRedirectPage> createState() => _PaymentRedirectPageState();
}

class _PaymentRedirectPageState extends ConsumerState<PaymentRedirectPage> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            final url = request.url;

            final successUrl = widget.args.payment.successUrl ?? '';
            final failureUrl = widget.args.payment.failureUrl ?? '';

            if (successUrl.isNotEmpty && url.startsWith(successUrl)) {
              _handleSuccess(url);
              return NavigationDecision.prevent;
            }

            if (failureUrl.isNotEmpty && url.startsWith(failureUrl)) {
              _goFailure('Payment failed or cancelled.');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEsewaForm();
      ref.read(paymentNotifierProvider.notifier).markRedirecting();
    });
  }

  Future<void> _loadEsewaForm() async {
    final payment = widget.args.payment;

    final html = '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  </head>
  <body onload="document.forms[0].submit()">
    <form action="https://rc-epay.esewa.com.np/api/epay/main/v2/form" method="POST">
      <input type="hidden" name="amount" value="${payment.amount.toStringAsFixed(0)}" />
      <input type="hidden" name="tax_amount" value="0" />
      <input type="hidden" name="total_amount" value="${payment.amount.toStringAsFixed(0)}" />
      <input type="hidden" name="transaction_uuid" value="${payment.transactionId}" />
      <input type="hidden" name="product_code" value="${payment.productCode ?? 'EPAYTEST'}" />
      <input type="hidden" name="product_service_charge" value="0" />
      <input type="hidden" name="product_delivery_charge" value="0" />
      <input type="hidden" name="success_url" value="${payment.successUrl ?? ''}" />
      <input type="hidden" name="failure_url" value="${payment.failureUrl ?? ''}" />
      <input type="hidden" name="signed_field_names" value="${payment.signedFieldNames ?? 'total_amount,transaction_uuid,product_code'}" />
      <input type="hidden" name="signature" value="${payment.signature ?? ''}" />
      <noscript>
        <button type="submit">Continue to eSewa</button>
      </noscript>
    </form>
  </body>
</html>
''';

    await _controller.loadHtmlString(html);
  }

  Future<void> _handleSuccess(String callbackUrl) async {
    if (_verifying) return;
    _verifying = true;

    final decoded = _decodeEsewaCallback(callbackUrl);
    if (decoded == null) {
      _goFailure('Could not decode eSewa response. Please try again.');
      return;
    }

    final verified = await ref.read(paymentNotifierProvider.notifier).verifyPayment(
          transactionId: decoded.transactionUuid,
          amount: decoded.amount,
          transactionCode: decoded.transactionCode,
          flowType: widget.args.flowType,
          purchasedProductId: widget.args.purchasedProductId,
        );

    if (!mounted) return;
    if (verified == null) {
      _goFailure('Payment verification failed.');
      return;
    }

    if (widget.args.flowType == PaymentFlowType.booking) {
      final bookingId = widget.args.bookingId;
      if (bookingId == null || bookingId.isEmpty) {
        _goFailure('Booking reference missing for payment confirmation.');
        return;
      }

      await ref.read(bookingViewModelProvider.notifier).confirmBookingPayment(
            bookingId,
            transactionCode: decoded.transactionCode,
            transactionUUID: decoded.transactionUuid,
            amount: decoded.amount,
          );

      if (!mounted) return;
      final bookingState = ref.read(bookingViewModelProvider);
      if (bookingState.paymentStatus == BookingPaymentStatusUi.failure) {
        _goFailure(bookingState.errorMessage ?? 'Booking payment confirmation failed.');
        return;
      }
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PaymentSuccessPage(
          payment: verified,
          flowType: widget.args.flowType,
        ),
      ),
    );
  }

  void _goFailure(String message) {
    if (!mounted) return;
    ref.read(paymentNotifierProvider.notifier).markFailure(message);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PaymentFailurePage(
          flowType: widget.args.flowType,
          message: message,
        ),
      ),
    );
  }

  _EsewaVerificationPayload? _decodeEsewaCallback(String callbackUrl) {
    try {
      final uri = Uri.parse(callbackUrl);

      final encodedData = uri.queryParameters['data'];
      if (encodedData != null && encodedData.isNotEmpty) {
        final normalized = base64.normalize(encodedData);
        final decoded = utf8.decode(base64.decode(normalized));
        final map = jsonDecode(decoded) as Map<String, dynamic>;

        return _EsewaVerificationPayload(
          transactionUuid: (map['transaction_uuid'] ?? map['transactionUUID'] ?? '').toString(),
          amount: (map['total_amount'] ?? map['amount'] ?? '').toString(),
          transactionCode: (map['transaction_code'] ?? map['transactionCode'] ?? '').toString(),
        );
      }

      // Fallback for plain query params.
      return _EsewaVerificationPayload(
        transactionUuid: (uri.queryParameters['transaction_uuid'] ?? '').toString(),
        amount: (uri.queryParameters['total_amount'] ?? uri.queryParameters['amount'] ?? '').toString(),
        transactionCode: (uri.queryParameters['transaction_code'] ?? '').toString(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PaymentState>(paymentNotifierProvider, (previous, next) {
      if (!mounted) return;
      if (next.unauthorized) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(paymentNotifierProvider.notifier).resetFlow(
              infoMessage: 'Payment was cancelled.',
            );
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
            }
          },
        ),
        title: const Text('Secure eSewa Payment'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading || _verifying)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class _EsewaVerificationPayload {
  final String transactionUuid;
  final String amount;
  final String transactionCode;

  const _EsewaVerificationPayload({
    required this.transactionUuid,
    required this.amount,
    required this.transactionCode,
  });
}
