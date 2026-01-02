import 'package:flutter/material.dart';
import '../../data/datasources/local/auth_local_data_source.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _localDataSource = AuthLocalDatasourceImpl();

  // 1️⃣ Form key
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
              key: _formKey, // 2️⃣ Attach form key
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
                        Text("Fill in the details to get started", style: TextStyle(color: Colors.grey)),
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
                      if (value == null || value.isEmpty) return "Full name is required";
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
                      if (value == null || value.isEmpty) return "Email is required";
                      if (!value.contains("@")) return "Enter a valid email";
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
                      if (value == null || value.isEmpty) return "Password is required";
                      if (value.length < 6) return "Password must be at least 6 characters";
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
                      if (value == null || value.isEmpty) return "Confirm password is required";
                      if (value != _passwordController.text) return "Passwords do not match";
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // SIGN UP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: isTablet ? 56 : 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        // 3️⃣ Validate form before signup
                        if (_formKey.currentState!.validate()) {
                          await _localDataSource.registerUser(
                            _emailController.text.trim(),
                            _passwordController.text,
                            _fullNameController.text.trim(),
                          );

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Registration Successful!")),
                          );

                          Navigator.pushReplacementNamed(context, "/login");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 25),
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
}
