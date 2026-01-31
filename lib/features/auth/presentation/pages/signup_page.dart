import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/state/auth_state.dart';
import '../../presentation/view_model/auth_viewmodel.dart';

//Signup Page
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

//controller
  final _fullNameController = TextEditingController(); //name controller
  final _emailController = TextEditingController(); //email controller
  final _passwordController = TextEditingController(); //password
  final _confirmPasswordController = TextEditingController();//confirm password

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.registered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: isTablet ? 450 : double.infinity,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      "assets/image/logo.png",
                      height: isTablet ? 100 : 70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          "Create Account",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Fill in the details to get started",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // FULL NAME FIELD
                  const Text("Full Name", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      hintText: "Enter your full name",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Full name is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // EMAIL FIELD
                  const Text("Email", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // PASSWORD FIELD
                  const Text("Password", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !passwordVisible,
                    decoration: InputDecoration(
                      hintText: "Create a password",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: IconButton(
                        icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => passwordVisible = !passwordVisible),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // CONFIRM PASSWORD FIELD
                  const Text("Confirm Password", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !confirmPasswordVisible,
                    decoration: InputDecoration(
                      hintText: "Confirm your password",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: IconButton(
                        icon: Icon(confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => confirmPasswordVisible = !confirmPasswordVisible),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm password is required";
                      }
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // SIGN UP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: isTablet ? 56 : 48,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: authState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // LOGIN LINK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, "/login"),
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      ref.read(authViewModelProvider.notifier).register(
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }
}
