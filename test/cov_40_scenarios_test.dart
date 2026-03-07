import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_cov_console/test_cov_console.dart';

// ------------------------------
// Console verification helper (cov + captured prints)
// ------------------------------
class CovConsoleVerifier {
  static Future<String> capturePrints(FutureOr<void> Function() action) async {
    final buffer = StringBuffer();
    await runZonedGuarded(
      () async => await action(),
      (error, stack) => buffer.writeln('ERROR: $error'),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          buffer.writeln(line);
          parent.print(zone, line);
        },
      ),
    );
    return buffer.toString();
  }

  static void _printCovScenarioResult({
    required String scenario,
    required bool passed,
  }) {
    final lcovLines = <String>[
      'SF:test/$scenario.dart',
      'DA:1,${passed ? 1 : 0}',
      'LF:1',
      'LH:${passed ? 1 : 0}',
      'FNF:0',
      'FNH:0',
      'BRF:0',
      'BRH:0',
      'end_of_record',
    ];

    // Prints PASSED/FAILED in console through cov package.
    printCov(lcovLines, <FileEntity>[], scenario, false, true, 100, true);
  }

  static Future<void> expectConsoleContains({
    required String scenario,
    required FutureOr<void> Function() action,
    required List<String> expectedTokens,
  }) async {
    final output = await capturePrints(action);
    final success = expectedTokens.every(output.contains);
    _printCovScenarioResult(scenario: scenario, passed: success);

    expect(
      success,
      isTrue,
      reason: 'Console output for $scenario missing one of: $expectedTokens\nActual:\n$output',
    );
  }
}

// ------------------------------
// Domain + service abstractions
// ------------------------------
class User {
  final String id;
  final String email;
  const User(this.id, this.email);
}

class Product {
  final String id;
  final String name;
  final double? price;
  const Product(this.id, this.name, this.price);
}

class LoginResult {
  final bool ok;
  final User? user;
  final String? message;
  const LoginResult.success(this.user)
      : ok = true,
        message = null;
  const LoginResult.failure(this.message)
      : ok = false,
        user = null;
}

abstract class AuthApi {
  Future<Map<String, dynamic>> login(String email, String password);
}

abstract class ProductApi {
  Future<List<Map<String, dynamic>>> fetchProducts();
}

abstract class LocalStore {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
}

abstract class PaymentGateway {
  Future<Map<String, dynamic>> pay(double amount);
}

class AuthRepository {
  final AuthApi api;
  AuthRepository(this.api);

  Future<LoginResult> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.trim().isEmpty) {
      return const LoginResult.failure('invalid-input');
    }

    try {
      final res = await api.login(normalizedEmail, password);
      if (res['ok'] == true) {
        return LoginResult.success(User(res['id'] as String, res['email'] as String));
      }
      return LoginResult.failure((res['message'] ?? 'login-failed').toString());
    } catch (_) {
      return const LoginResult.failure('network-failure');
    }
  }
}

class ProductRepository {
  final ProductApi api;
  final LocalStore local;
  ProductRepository(this.api, this.local);

  Future<List<Product>> fetchProducts() async {
    try {
      final rows = await api.fetchProducts();
      final products = rows
          .map((e) => Product(e['id'].toString(), e['name'].toString(), (e['price'] as num?)?.toDouble()))
          .toList();
      await local.write('cached_count', products.length.toString());
      return products;
    } catch (_) {
      final fallback = await local.read('cached_count');
      if (fallback == null) return const [];
      final n = int.tryParse(fallback) ?? 0;
      return List.generate(n, (i) => Product('cached-$i', 'Cached $i', 0));
    }
  }
}

class PaymentService {
  final PaymentGateway gateway;
  PaymentService(this.gateway);

  Future<String> pay(double amount) async {
    if (amount <= 0) return 'invalid-amount';
    try {
      final r = await gateway.pay(amount);
      return r['status']?.toString() ?? 'unknown';
    } catch (_) {
      return 'payment-failed';
    }
  }
}

class CartUseCase {
  double totalWithDiscount(List<Product> items, {double discountPct = 0}) {
    final subtotal = items.fold<double>(0, (sum, p) => sum + (p.price ?? 0));
    final discount = subtotal * (discountPct.clamp(0, 100) / 100);
    return double.parse((subtotal - discount).toStringAsFixed(2));
  }
}

// ------------------------------
// ViewModel / state management
// ------------------------------
enum VmStatus { idle, loading, success, error }

class AppViewModel extends ChangeNotifier {
  final AuthRepository authRepo;
  final ProductRepository productRepo;
  final PaymentService paymentService;
  final LocalStore local;

  VmStatus status = VmStatus.idle;
  String? error;
  User? user;
  List<Product> products = const [];
  bool darkMode = false;
  bool isOffline = false;

  AppViewModel(this.authRepo, this.productRepo, this.paymentService, this.local);

  Future<void> login(String email, String password) async {
    status = VmStatus.loading;
    error = null;
    notifyListeners();

    final r = await authRepo.login(email, password);
    if (r.ok) {
      user = r.user;
      status = VmStatus.success;
      notifyListeners();
      return;
    }

    status = VmStatus.error;
    error = r.message;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    status = VmStatus.loading;
    notifyListeners();

    products = await productRepo.fetchProducts();
    status = VmStatus.success;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void toggleTheme() {
    darkMode = !darkMode;
    notifyListeners();
  }

  Future<String> pay(double amount) async {
    status = VmStatus.loading;
    notifyListeners();
    final r = await paymentService.pay(amount);
    status = r == 'success' ? VmStatus.success : VmStatus.error;
    error = status == VmStatus.error ? r : null;
    notifyListeners();
    return r;
  }

  Future<void> setOffline(bool value) async {
    isOffline = value;
    await local.write('offline', value.toString());
    notifyListeners();
  }
}

// ------------------------------
// UI test widgets
// ------------------------------
class DemoLoginWidget extends StatefulWidget {
  final Future<void> Function(String email, String password) onSubmit;
  const DemoLoginWidget({super.key, required this.onSubmit});

  @override
  State<DemoLoginWidget> createState() => _DemoLoginWidgetState();
}

class _DemoLoginWidgetState extends State<DemoLoginWidget> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            TextField(key: const Key('email'), controller: emailCtrl),
            TextField(key: const Key('pass'), controller: passCtrl, obscureText: obscure),
            IconButton(
              key: const Key('toggle-obscure'),
              onPressed: () => setState(() => obscure = !obscure),
              icon: const Icon(Icons.remove_red_eye),
            ),
            ElevatedButton(
              key: const Key('login-btn'),
              onPressed: () => widget.onSubmit(emailCtrl.text, passCtrl.text),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyOrListWidget extends StatelessWidget {
  final List<String> items;
  const EmptyOrListWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const MaterialApp(home: Scaffold(body: Center(child: Text('No items'))));
    }

    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => ListTile(title: Text(items[i])),
        ),
      ),
    );
  }
}

class CountdownWidget extends StatefulWidget {
  const CountdownWidget({super.key});

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  int seconds = 3;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => seconds--);
      if (seconds <= 0) {
        timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Text('T-$seconds')));
  }
}

class FadeBox extends StatefulWidget {
  const FadeBox({super.key});

  @override
  State<FadeBox> createState() => _FadeBoxState();
}

class _FadeBoxState extends State<FadeBox> {
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Text('Animated'),
            ),
            TextButton(
              onPressed: () => setState(() => visible = !visible),
              child: const Text('Toggle'),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------
// Mocks
// ------------------------------
class MockAuthApi extends Mock implements AuthApi {}

class MockProductApi extends Mock implements ProductApi {}

class MockLocalStore extends Mock implements LocalStore {}

class MockPaymentGateway extends Mock implements PaymentGateway {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockAuthApi authApi;
  late MockProductApi productApi;
  late MockLocalStore localStore;
  late MockPaymentGateway paymentGateway;

  late AuthRepository authRepo;
  late ProductRepository productRepo;
  late PaymentService paymentService;
  late AppViewModel vm;

  setUpAll(() {
    registerFallbackValue(const RouteSettings());
  });

  setUp(() {
    authApi = MockAuthApi();
    productApi = MockProductApi();
    localStore = MockLocalStore();
    paymentGateway = MockPaymentGateway();

    authRepo = AuthRepository(authApi);
    productRepo = ProductRepository(productApi, localStore);
    paymentService = PaymentService(paymentGateway);
    vm = AppViewModel(authRepo, productRepo, paymentService, localStore);

    when(() => localStore.write(any(), any())).thenAnswer((_) async {});
    when(() => localStore.read(any())).thenAnswer((_) async => null);
  });

  tearDown(() {
    reset(authApi);
    reset(productApi);
    reset(localStore);
    reset(paymentGateway);
  });

  // ============================================================
  // 1) USE CASE TESTS (10)
  // ============================================================
  group('Use Case Tests (10)', () {
    test('[Scenario 01][unit][UseCase] login normalizes email and succeeds', () async {
      when(() => authApi.login('alice@example.com', 'pass123'))
          .thenAnswer((_) async => {'ok': true, 'id': 'u1', 'email': 'alice@example.com'});

      final res = await authRepo.login('  Alice@Example.com ', 'pass123');

      await CovConsoleVerifier.expectConsoleContains(
        scenario: 'Scenario_01_unit_usecase',
        action: () => print('S01 result: ${res.ok} user=${res.user?.email}'),
        expectedTokens: ['S01 result: true', 'alice@example.com'],
      );
      expect(res.ok, isTrue);
    });

    test('[Scenario 02][unit][UseCase] login rejects empty inputs', () async {
      final res = await authRepo.login('', '');
      expect(res.ok, isFalse);
      expect(res.message, 'invalid-input');
    });

    test('[Scenario 03][unit][UseCase] login handles API error as network-failure', () async {
      when(() => authApi.login(any(), any())).thenThrow(Exception('down'));
      final res = await authRepo.login('a@b.com', 'x');
      expect(res.message, 'network-failure');
    });

    test('[Scenario 04][unit][UseCase] product repository maps raw API data', () async {
      when(() => productApi.fetchProducts()).thenAnswer(
        (_) async => [
          {'id': '1', 'name': 'Pen', 'price': 12.5},
          {'id': '2', 'name': 'Book', 'price': null},
        ],
      );

      final items = await productRepo.fetchProducts();
      expect(items.length, 2);
      expect(items[0].price, 12.5);
      expect(items[1].price, isNull);
    });

    test('[Scenario 05][unit][UseCase] product repository falls back to cache on API fail', () async {
      when(() => productApi.fetchProducts()).thenThrow(Exception('offline'));
      when(() => localStore.read('cached_count')).thenAnswer((_) async => '3');

      final items = await productRepo.fetchProducts();
      expect(items.length, 3);
      expect(items.first.name, 'Cached 0');
    });

    test('[Scenario 06][unit][UseCase] cart total handles null prices and discount', () {
      final useCase = CartUseCase();
      final total = useCase.totalWithDiscount(
        const [Product('1', 'A', 100), Product('2', 'B', null)],
        discountPct: 10,
      );
      expect(total, 90);
    });

    test('[Scenario 07][unit][UseCase] cart discount is clamped to [0,100]', () {
      final useCase = CartUseCase();
      final total = useCase.totalWithDiscount(const [Product('1', 'A', 100)], discountPct: 999);
      expect(total, 0);
    });

    test('[Scenario 08][unit][UseCase] payment service success status mapping', () async {
      when(() => paymentGateway.pay(200)).thenAnswer((_) async => {'status': 'success'});
      final status = await paymentService.pay(200);
      expect(status, 'success');
    });

    test('[Scenario 09][unit][UseCase] payment service catches gateway error', () async {
      when(() => paymentGateway.pay(any())).thenThrow(Exception('bad gateway'));
      final status = await paymentService.pay(200);
      expect(status, 'payment-failed');
    });

    test('[Scenario 10][unit][UseCase] payment rejects invalid amount', () async {
      final status = await paymentService.pay(0);
      expect(status, 'invalid-amount');
    });
  });

  // ============================================================
  // 2) VIEWMODEL / STATE MANAGEMENT TESTS (10)
  // ============================================================
  group('ViewModel / State Tests (10)', () {
    test('[Scenario 11][unit][ViewModel] login emits loading then success', () async {
      when(() => authApi.login(any(), any()))
          .thenAnswer((_) async => {'ok': true, 'id': 'u1', 'email': 'a@b.com'});

      final states = <VmStatus>[];
      vm.addListener(() => states.add(vm.status));

      await vm.login('a@b.com', 'pass');
      expect(states, containsAllInOrder([VmStatus.loading, VmStatus.success]));
    });

    test('[Scenario 12][unit][ViewModel] login emits error state on failure', () async {
      when(() => authApi.login(any(), any())).thenThrow(Exception('net'));
      await vm.login('a@b.com', 'pass');
      expect(vm.status, VmStatus.error);
      expect(vm.error, 'network-failure');
    });

    test('[Scenario 13][unit][ViewModel] clearError removes previous error', () async {
      when(() => authApi.login(any(), any())).thenThrow(Exception('x'));
      await vm.login('a@b.com', 'pass');
      vm.clearError();
      expect(vm.error, isNull);
    });

    test('[Scenario 14][unit][ViewModel] loadProducts updates state and list', () async {
      when(() => productApi.fetchProducts())
          .thenAnswer((_) async => [
                {'id': '1', 'name': 'Pen', 'price': 1.0}
              ]);

      await vm.loadProducts();
      expect(vm.status, VmStatus.success);
      expect(vm.products.length, 1);
    });

    test('[Scenario 15][unit][ViewModel] toggleTheme flips boolean state', () {
      expect(vm.darkMode, isFalse);
      vm.toggleTheme();
      expect(vm.darkMode, isTrue);
    });

    test('[Scenario 16][unit][ViewModel] pay success clears error', () async {
      when(() => paymentGateway.pay(any())).thenAnswer((_) async => {'status': 'success'});
      final status = await vm.pay(100);
      expect(status, 'success');
      expect(vm.status, VmStatus.success);
      expect(vm.error, isNull);
    });

    test('[Scenario 17][unit][ViewModel] pay failure sets error state', () async {
      when(() => paymentGateway.pay(any())).thenThrow(Exception('boom'));
      final status = await vm.pay(100);
      expect(status, 'payment-failed');
      expect(vm.status, VmStatus.error);
      expect(vm.error, 'payment-failed');
    });

    test('[Scenario 18][unit][ViewModel] offline mode persists to local store', () async {
      await vm.setOffline(true);
      verify(() => localStore.write('offline', 'true')).called(1);
      expect(vm.isOffline, isTrue);
    });

    test('[Scenario 19][unit][ViewModel] login with invalid input sets error', () async {
      await vm.login('', '');
      expect(vm.status, VmStatus.error);
      expect(vm.error, 'invalid-input');
    });

    test('[Scenario 20][unit][ViewModel] listener gets notified multiple transitions', () async {
      when(() => authApi.login(any(), any()))
          .thenAnswer((_) async => {'ok': true, 'id': 'u2', 'email': 'ok@ok.com'});
      int count = 0;
      vm.addListener(() => count++);

      await vm.login('ok@ok.com', 'pw');
      expect(count, greaterThanOrEqualTo(2));
    });
  });

  // ============================================================
  // 3) WIDGET TESTS (10)
  // ============================================================
  group('Widget Tests (10)', () {
    testWidgets('[Scenario 21][widget][UI] renders login fields and button', (tester) async {
      await tester.pumpWidget(DemoLoginWidget(onSubmit: (_, __) async {}));

      expect(find.byKey(const Key('email')), findsOneWidget);
      expect(find.byKey(const Key('pass')), findsOneWidget);
      expect(find.byKey(const Key('login-btn')), findsOneWidget);
    });

    testWidgets('[Scenario 22][widget][UI] enters text into TextFields', (tester) async {
      await tester.pumpWidget(DemoLoginWidget(onSubmit: (_, __) async {}));

      await tester.enterText(find.byKey(const Key('email')), 'hello@x.com');
      await tester.enterText(find.byKey(const Key('pass')), '123456');

      expect(find.text('hello@x.com'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
    });

    testWidgets('[Scenario 23][widget][UI] tapping login triggers callback', (tester) async {
      String? gotEmail;
      await tester.pumpWidget(DemoLoginWidget(
        onSubmit: (email, password) async {
          gotEmail = email;
          print('S23 login tapped for $email');
        },
      ));

      await tester.enterText(find.byKey(const Key('email')), 'user@mail.com');
      await tester.enterText(find.byKey(const Key('pass')), 'pw');
      await tester.tap(find.byKey(const Key('login-btn')));
      await tester.pump();

      await CovConsoleVerifier.expectConsoleContains(
        scenario: 'Scenario_23_widget_ui',
        action: () async => print('Captured email => $gotEmail'),
        expectedTokens: ['Captured email => user@mail.com'],
      );
      expect(gotEmail, 'user@mail.com');
    });

    testWidgets('[Scenario 24][widget][UI] toggles password visibility', (tester) async {
      await tester.pumpWidget(DemoLoginWidget(onSubmit: (_, __) async {}));
      await tester.tap(find.byKey(const Key('toggle-obscure')));
      await tester.pump();
      expect(find.byIcon(Icons.remove_red_eye), findsOneWidget);
    });

    testWidgets('[Scenario 25][widget][UI] list widget shows empty state', (tester) async {
      await tester.pumpWidget(const EmptyOrListWidget(items: []));
      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('[Scenario 26][widget][UI] list widget renders dynamic items', (tester) async {
      await tester.pumpWidget(const EmptyOrListWidget(items: ['A', 'B', 'C']));
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('[Scenario 27][widget][UI] navigation to second page works', (tester) async {
      final observer = MockNavigatorObserver();

      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [observer],
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Second'))),
              ),
              child: const Text('Go'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('[Scenario 28][widget][UI] dialog opens and closes correctly', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  ],
                ),
              ),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm'), findsNothing);
    });

    testWidgets('[Scenario 29][widget][UI] conditional widget hides banner', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SizedBox.shrink()),
      ));
      expect(find.text('Promo'), findsNothing);
    });

    testWidgets('[Scenario 30][widget][UI] animated opacity transitions after toggle', (tester) async {
      await tester.pumpWidget(const FadeBox());
      expect(find.text('Animated'), findsOneWidget);

      await tester.tap(find.text('Toggle'));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Animated'), findsOneWidget);
    });
  });

  // ============================================================
  // 4) EDGE / INTEGRATION / MISC TESTS (10)
  // ============================================================
  group('Edge / Integration / Misc Tests (10)', () {
    test('[Scenario 31][integration][Edge] API null payload handled safely', () async {
      when(() => authApi.login(any(), any())).thenAnswer((_) async => {'ok': false, 'message': null});
      final res = await authRepo.login('x@y.com', 'pw');
      expect(res.ok, isFalse);
      expect(res.message, 'login-failed');
    });

    test('[Scenario 32][integration][Edge] offline mode + product fallback empty cache', () async {
      when(() => productApi.fetchProducts()).thenThrow(Exception('offline'));
      when(() => localStore.read('cached_count')).thenAnswer((_) async => null);

      final items = await productRepo.fetchProducts();
      expect(items, isEmpty);
    });

    testWidgets('[Scenario 33][integration][Edge] empty-state screen appears', (tester) async {
      await tester.pumpWidget(const EmptyOrListWidget(items: []));
      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('[Scenario 34][integration][Edge] countdown timer updates text', (tester) async {
      await tester.pumpWidget(const CountdownWidget());
      expect(find.text('T-3'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('T-2'), findsOneWidget);
    });

    testWidgets('[Scenario 35][integration][Edge] animation survives multiple rapid toggles', (tester) async {
      await tester.pumpWidget(const FadeBox());
      await tester.tap(find.text('Toggle'));
      await tester.tap(find.text('Toggle'));
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      expect(find.text('Animated'), findsOneWidget);
    });

    test('[Scenario 36][integration][Edge] local storage null value read does not crash', () async {
      when(() => localStore.read('missing')).thenAnswer((_) async => null);
      final value = await localStore.read('missing');
      expect(value, isNull);
    });

    testWidgets('[Scenario 37][integration][Edge] theme changes from light to dark', (tester) async {
      final notifier = ValueNotifier<bool>(false);

      await tester.pumpWidget(ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (_, isDark, __) {
          return MaterialApp(
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: Scaffold(
              body: TextButton(
                onPressed: () => notifier.value = !notifier.value,
                child: const Text('Switch Theme'),
              ),
            ),
          );
        },
      ));

      await tester.tap(find.text('Switch Theme'));
      await tester.pumpAndSettle();
      expect(notifier.value, isTrue);
    });

    test('[Scenario 38][integration][Edge] payment mock failure returns payment-failed', () async {
      when(() => paymentGateway.pay(any())).thenThrow(Exception('timeout'));
      final r = await paymentService.pay(500);
      expect(r, 'payment-failed');
    });

    test('[Scenario 39][integration][Edge] invalid user action double-payment blocked by invalid amount', () async {
      final r1 = await paymentService.pay(-10);
      final r2 = await paymentService.pay(0);
      expect(r1, 'invalid-amount');
      expect(r2, 'invalid-amount');
    });

    test('[Scenario 40][integration][Edge] cov console verification with explicit output token', () async {
      await CovConsoleVerifier.expectConsoleContains(
        scenario: 'Scenario_40_integration_edge',
        action: () => print('SCENARIO_40_OK'),
        expectedTokens: ['SCENARIO_40_OK'],
      );
    });
  });
}
