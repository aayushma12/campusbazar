import 'package:campus_bazar/features/auth/presentation/pages/login_page.dart';
import 'package:campus_bazar/features/auth/presentation/state/auth_state.dart';
import 'package:campus_bazar/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAuthViewModel extends AuthViewModel {
  TestAuthViewModel(this.initialState);

  final AuthState initialState;
  String? lastEmail;
  String? lastPassword;
  bool? lastRememberMe;

  @override
  AuthState build() => initialState;

  @override
  Future<void> login({required String email, required String password, required bool rememberMe}) async {
    lastEmail = email;
    lastPassword = password;
    lastRememberMe = rememberMe;
  }
}

void main() {
  Widget createWidgetUnderTest(TestAuthViewModel testViewModel) {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => testViewModel),
      ],
      child: const MaterialApp(home: LoginPage()),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('renders key login UI', (WidgetTester tester) async {
      final vm = TestAuthViewModel(const AuthState());
      await tester.pumpWidget(createWidgetUnderTest(vm));
      await tester.pumpAndSettle();

      expect(find.text('Hi, Welcome Back!'), findsOneWidget);
      expect(find.text("Hello again, you've been missed!"), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password'), findsOneWidget);
    });

    testWidgets('validates required fields', (WidgetTester tester) async {
      final vm = TestAuthViewModel(const AuthState());
      await tester.pumpWidget(createWidgetUnderTest(vm));
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('calls login when form is valid', (WidgetTester tester) async {
      final vm = TestAuthViewModel(const AuthState());
      await tester.pumpWidget(createWidgetUnderTest(vm));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(vm.lastEmail, 'test@example.com');
      expect(vm.lastPassword, 'password123');
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      final vm = TestAuthViewModel(const AuthState());
      await tester.pumpWidget(createWidgetUnderTest(vm));
      await tester.pumpAndSettle();

      final passwordFieldFinder = find.byType(TextFormField).last;
      final firstEditable = find.descendant(
        of: passwordFieldFinder,
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(firstEditable).obscureText, true);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      final updatedEditable = find.descendant(
        of: passwordFieldFinder,
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(updatedEditable).obscureText, false);
    });
  });
}
