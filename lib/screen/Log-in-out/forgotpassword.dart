import 'package:capstoneapp/screen/Log-in-out/userLogin.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }


Future<void> passReset() async {
  try {
    String email = emailController.text.trim();

    // Send the password reset email using Supabase
    await Supabase.instance.client.auth.resetPasswordForEmail(email);

    // Show success alert using QuickAlert
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'Password reset email sent! Check your inbox.',
    );
  } on AuthException catch (e) {
    // Handle Supabase-specific errors
    String errorMessage;

    switch (e.message) {
      case 'user-not-found':
        errorMessage = 'Email not found. Please check and try again.';
        break;
      case 'invalid-email':
        errorMessage = 'The email address is not valid.';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many requests. Please try again later.';
        break;
      case 'network-request-failed':
        errorMessage = 'Network error. Please check your internet connection.';
        break;
      default:
        errorMessage = 'An error occurred. Please try again.';
    }

    // Show error alert using QuickAlert
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: errorMessage,
    );
  } catch (e) {
    // Show unexpected error alert using QuickAlert
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: 'An unexpected error occurred: ${e.toString()}',
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 47, 61, 2),
        title: Text(
          'Change Your Password',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen(onTap: () {})),
                (route) => false);
          },
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 100,
                color: Color.fromARGB(255, 47, 61, 2),
              ),
              const SizedBox(height: 20),
              const Text(
                'Forgot password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 47, 61, 2),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your email address to receive a link to change your pass',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 47, 61, 2),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                style: TextStyle(color: Colors.black),
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  labelText: 'E-mail',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: passReset,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Color.fromARGB(255, 47, 61, 2),
                  ),
                  child: const Text(
                    'Send',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
