import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Back Button
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Make sure there's a screen to go back to
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Or do nothing / navigate to home
            }
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // align all content to start
          children: [

            const SizedBox(height: 10),

            // LOGO
            Center(
              child: Image.asset(
                "assets/logo.png",
                height: 80,
              ),
            ),

            const SizedBox(height: 25),

            // TITLE
            Center(
              child: Column(
                children: const [
                  Text(
                    "Hi, Welcome Back!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Hello again, you've been missed!",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // EMAIL FIELD
            const Text("Email", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: "Enter your email",
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PASSWORD FIELD
            const Text("Password", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              obscureText: !passwordVisible,
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: "Enter your password",
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // REMEMBER ME + FORGOT PASSWORD
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value!;
                    });
                  },
                ),
                const Text("Remember Me"),

                const Spacer(),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/forgot");
                  },
                  child: const Text(
                    "Forgot Password",
                    style: TextStyle(color: Colors.green),
                  ),
                )
              ],
            ),

            const SizedBox(height: 25),

            // LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/dashboard");},

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // OR DIVIDER
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Or With"),
                ),
                Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 20),

            // SOCIAL BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _socialButton("Facebook", Icons.facebook),
                _socialButton("Google", Icons.g_mobiledata),
              ],
            ),

            const SizedBox(height: 25),

            // SIGN UP NAVIGATION
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/signup");
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.green),
                  ),
                )
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(String name, IconData icon) {
    return Container(
      width: 130,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: Colors.black54),
          const SizedBox(width: 8),
          Text(name),
        ],
      ),
    );
  }
}
