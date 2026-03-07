import 'package:campus_bazar/features/auth/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import your Models
import 'features/auth/data/models/auth_user_model.dart';
import 'features/profile/data/models/profile_model.dart';
import 'features/authentication/data/models/auth_user_model.dart' as auth_v2;

// Import service locator
import 'core/services/service_locator.dart';
import 'core/theme/app_button_theme.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/widgets/app_lock_guard.dart';

// Import other pages
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/auth/presentation/pages/welcome_view.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/dashboard/presentation/pages/create_product_page.dart';
import 'features/product/presentation/pages/search_products_page.dart';
import 'features/cart/presentation/pages/cart_page.dart';
import 'features/chat/presentation/pages/conversations_page.dart';
import 'features/chat/presentation/pages/chat_page.dart';
import 'features/order/presentation/pages/orders_page.dart';
import 'features/order/presentation/pages/order_detail_page.dart';
import 'features/payment/presentation/pages/payment_history_page.dart';
import 'features/booking/presentation/pages/bookings_page.dart';
import 'features/booking/presentation/pages/create_booking_page.dart';
import 'features/category/presentation/pages/categories_page.dart';
import 'features/wishlist/presentation/pages/wishlist_page.dart';
import 'features/products/presentation/pages/products_dashboard_page.dart';
import 'features/products/presentation/pages/product_form_page.dart';
import 'features/products/presentation/pages/product_detail_route_page.dart';
import 'features/tutor/presentation/pages/tutor_page.dart';
import 'features/notification/presentation/pages/notifications_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/settings/presentation/widgets/shake_theme_listener.dart';
import 'features/dashboard/presentation/pages/home_page.dart';
import 'features/onboarding/presentation/pages/onboarding1_view.dart';
import 'features/onboarding/presentation/pages/onboarding2_view.dart';
import 'features/onboarding/presentation/pages/onboarding3_view.dart';
import 'features/splash/presentation/pages/splash_view.dart';
import 'features/authentication/presentation/pages/auth_gate_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(AuthUserModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ProfileModelAdapter());
  if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(auth_v2.AuthUserModelAdapter());

  // Setup dependency injection
  await setupLocator();

  // Run the app with top-level wrappers
  runApp(
    ProviderScope(
      child: ShakeThemeListener(
        child: AppLockGuard(
          child: const CampusBazarAppWrapper(),
        ),
      ),
    ),
  );
}

// Wrapper to safely use Consumer for MaterialApp
class CampusBazarAppWrapper extends ConsumerWidget {
  const CampusBazarAppWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "CampusBazar",
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        useMaterial3: true,
        elevatedButtonTheme: AppButtonTheme.elevatedButtonTheme,
        filledButtonTheme: AppButtonTheme.filledButtonTheme,
        outlinedButtonTheme: AppButtonTheme.outlinedButtonTheme,
        textButtonTheme: AppButtonTheme.textButtonTheme,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        fontFamily: 'Poppins',
        useMaterial3: true,
        elevatedButtonTheme: AppButtonTheme.elevatedButtonTheme,
        filledButtonTheme: AppButtonTheme.filledButtonTheme,
        outlinedButtonTheme: AppButtonTheme.outlinedButtonTheme,
        textButtonTheme: AppButtonTheme.textButtonTheme,
      ),
      themeMode: themeMode,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashView(),
        '/onboarding1': (_) => const Onboarding1View(),
        '/onboarding2': (_) => const Onboarding2View(),
        '/onboarding3': (_) => const Onboarding3View(),
        '/welcome': (_) => const WelcomeView(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const SignupPage(),
        '/signup': (_) => const SignupPage(),
        '/forgot': (_) => const ForgotPasswordPage(),
        '/resetPassword': (_) => const ResetPasswordPage(),
        '/auth-gate-v2': (_) => const AuthenticationGatePage(),
        '/dashboard': (_) => const DashboardPage(),
        '/home': (_) => const HomePage(),
        '/products': (_) => const ProductsDashboardPage(),
        '/searchProducts': (_) => const SearchProductsPage(),
        '/productDetail': (_) => const ProductDetailRoutePage(),
        '/product/create': (_) => const ProductFormPage(),
        '/dashboard/create-product': (_) => const DashboardCreateProductPage(),
        '/products/create': (_) => const ProductFormPage(),
        '/cart': (_) => const CartPage(),
        '/chats': (_) => const ConversationsPage(),
        '/chatDetail': (_) => const ChatPage(),
        '/orders': (_) => const OrdersPage(),
        '/orderDetail': (_) => const OrderDetailPage(),
        '/payments/history': (_) => const PaymentHistoryPage(),
        '/bookings': (_) => const BookingsPage(),
        '/createBooking': (_) => const CreateBookingPage(),
        '/categories': (_) => const CategoriesPage(),
        '/wishlist': (_) => const WishlistPage(),
        '/tutors': (_) => const TutorPage(),
        '/notifications': (_) => const NotificationsPage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}
