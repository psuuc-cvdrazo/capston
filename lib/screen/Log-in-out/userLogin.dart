import 'package:capstoneapp/components/customtextfield.dart';
import 'package:capstoneapp/screen/Log-in-out/forgotpassword.dart';
import 'package:capstoneapp/screen/collectorside/collectorHome.dart';
import 'package:capstoneapp/screen/Log-in-out/registerpage.dart';
import 'package:capstoneapp/screen/userside/userHome.dart';
import 'package:capstoneapp/services/auth/authservice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class LoginScreen extends StatefulWidget {
  final void Function()? onTap;

  const LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;

  void signIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty && password.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: "Validation Error",
        text: "Please enter all fields.",
        confirmBtnText: "OK",
      );
      return;
    }

    if (email.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: "Validation Error",
        text: "Please enter your email.",
        confirmBtnText: "OK",
      );
      return;
    }

    if (password.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: "Validation Error",
        text: "Please enter your password.",
        confirmBtnText: "OK",
      );
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: "Validation Error",
        text: "Please enter a valid email address.",
        confirmBtnText: "OK",
      );
      return;
    }

    if (password.length < 8) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: "Validation Error",
        text: "Password must be at least 8 characters long.",
        confirmBtnText: "OK",
      );
      return;
    }

    try {
      await authService.signInWithEmailPassword(email, password);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Signed in successfully!",
        text: "Tap OK to proceed to the home screen",
        confirmBtnText: "OK",
        onConfirmBtnTap: () {
         
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const UserHomeScreen()),
            (route) => false,

          );
          
        },
        barrierDismissible: false
      );
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Invalid Login Credentials!",
        text: "Please try again",
        confirmBtnText: "OK",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 10,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome User!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.green.shade300,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.green.shade300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 16),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RegisterScreen(onTap: () {}),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Create New Account',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ForgotPasswordScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
