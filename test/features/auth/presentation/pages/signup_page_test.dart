import 'package:campus_bazar/features/auth/presentation/pages/signup_page.dart';
import 'package:campus_bazar/features/auth/presentation/state/auth_state.dart';
import 'package:campus_bazar/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAuthViewModel extends AuthViewModel {
  TestAuthViewModel(this.initialState);

  final AuthState initialState;
  String? lastName;
  String? lastEmail;
  String? lastPassword;

  @override
  AuthState build() => initialState;

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? university,
    String? campus,
  }) async {
    lastName = name;
    lastEmail = email;
    lastPassword = password;
  }
}

void main() {
  Widget createWidgetUnderTest(TestAuthViewModel testViewModel) {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => testViewModel),
      ],
      child: const MaterialApp(home: SignupPage()),
    );
  }

  group('SignupPage Widget Tests', () {
    testWidgets('renders key signup UI', (WidgetTester tester) async {
      final vm = TestAuthViewModel(const AuthState());
      await tester.pumpWidget(createWidgetUnderTest(vm));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Fill in the details to get started'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(6));
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('validates required fields', (WidgetTester tester) async {
      final vm = TestAuthViewModel(const AuthState());
      await tester.pumpWidget(createWidgetUnderTest(vm));
      await tester.pumpAndSettle();

      final signupButton = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.ensureVisible(signupButton);
      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      expect(find.text('Full name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('University is required'), findsOneWidget);
      expect(find.text('Campus is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Confirm password is required'), findsOneWidget);
    });

    testWidgets('calls register for valid form', (WidgetTester tester) async {
      final vm = TestAuthViewModel(const AuthState());
      await tester.pumpWidget(createWidgetUnderTest(vm));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'QCS University');
      await tester.enterText(find.byType(TextFormField).at(2), 'Main Campus');
      await tester.enterText(find.byType(TextFormField).at(3), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      await tester.enterText(find.byType(TextFormField).at(5), 'password123');
      final signupButton = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.ensureVisible(signupButton);
      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      expect(vm.lastName, 'Test User');
      expect(vm.lastEmail, 'test@example.com');
      expect(vm.lastPassword, 'password123');
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      final vm = TestAuthViewModel(const AuthState());
      await tester.pumpWidget(createWidgetUnderTest(vm));
      await tester.pumpAndSettle();

      final passwordFieldFinder = find.byType(TextFormField).at(4);
      final firstEditable = find.descendant(
        of: passwordFieldFinder,
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(firstEditable).obscureText, true);

      final visibilityIcon = find.byIcon(Icons.visibility_off).first;
      await tester.ensureVisible(visibilityIcon);
      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      final updatedEditable = find.descendant(
        of: passwordFieldFinder,
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(updatedEditable).obscureText, false);
    });
  });
}
