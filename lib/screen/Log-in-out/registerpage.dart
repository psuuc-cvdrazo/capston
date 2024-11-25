import 'package:capstoneapp/components/customtextfield.dart';
import 'package:capstoneapp/screen/collectorside/collectorHome.dart';
import 'package:capstoneapp/screen/userside/userHome.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../services/auth/authservice.dart';

class RegisterScreen extends StatefulWidget {
  final void Function()? onTap;

  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final firstname = TextEditingController();
  final lastname = TextEditingController();
  final emailto = TextEditingController();
  final phonenumber = TextEditingController();
  final pass = TextEditingController();
  final confirmpass = TextEditingController();

  bool _isAgree = false;
  bool _isFormFilled = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    firstname.addListener(_checkFormFilled);
    lastname.addListener(_checkFormFilled);
    emailto.addListener(_checkFormFilled);
    phonenumber.addListener(_checkFormFilled);
    pass.addListener(_checkFormFilled);
    confirmpass.addListener(_checkFormFilled);
  }

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    emailto.dispose();
    phonenumber.dispose();
    pass.dispose();
    confirmpass.dispose();
    super.dispose();
  }

  void _checkFormFilled() {
    setState(() {
      _isFormFilled = firstname.text.isNotEmpty &&
          lastname.text.isNotEmpty &&
          emailto.text.isNotEmpty &&
          phonenumber.text.isNotEmpty &&
          pass.text.isNotEmpty &&
          confirmpass.text.isNotEmpty;
    });
  }
void signUp() async {
  List<String> emptyFields = [];

  if (firstname.text.isEmpty) emptyFields.add("first name");
  if (lastname.text.isEmpty) emptyFields.add("last name");
  if (phonenumber.text.isEmpty) emptyFields.add("contact number");
  if (emailto.text.isEmpty) emptyFields.add("email");
  if (pass.text.isEmpty) emptyFields.add("password");
  if (confirmpass.text.isEmpty) emptyFields.add("confirm password");

  if (emailto.text.isNotEmpty && !emailto.text.contains('@gmail.com')) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oh no!',
      text: 'Please provide a proper email address (must include "@gmail.com" or "@email.com" ).',
    );
    return;
  }

    String phonePattern = r'^09\d{9}$';
  RegExp regExp = RegExp(phonePattern);
  if (!regExp.hasMatch(phonenumber.text)) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Invalid Contact Number',
      text: 'Please enter a valid phone number (11 digits, starting with 09).',
    );
    return;
  }

  if (emptyFields.isNotEmpty) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oh no!',
      text: 'Please fill in your ${emptyFields.join(", ")}.',
    );
    return;
  }

  if (pass.text != confirmpass.text) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oh no!',
      text: 'Passwords do not match. Please ensure both passwords are the same.',
    );
    return;
  }

  if (!_isAgree) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oh no!',
      text: 'Please agree to the Terms and Conditions to proceed.',
    );
    return;
  }

  final authService = Provider.of<AuthService>(context, listen: false);
  try {
    await authService.signUpWithEmailPassword(
      emailto.text,
      pass.text,
      firstName: firstname.text,
      lastName: lastname.text,
      phoneNumber: phonenumber.text,
    );

    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Yehey!',
      text: 'Your account has been created successfully!',
      onConfirmBtnTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => UserHomeScreen()),
          (route) => false,
        );
      },
    );
  } catch (e) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oh no!',
      text: 'The email address you entered is already associated with an account. Please use a different email or try logging in.',
    );
  }
}


  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = _isFormFilled && _isAgree;

  return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // First Name field
                  TextFormField(
                    controller: firstname,
                    decoration: InputDecoration(
                      hintText: "First Name",
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Last Name field
                  TextFormField(
                    controller: lastname,
                    decoration: InputDecoration(
                      hintText: "Last Name",
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Number field
                  TextFormField(
                    controller: phonenumber,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Contact Number",
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: emailto,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email",
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field with eye icon
                  TextFormField(
                    controller: pass,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      hintText: "Password",
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password field with eye icon
                  TextFormField(
                    controller: confirmpass,
                    obscureText: !_showConfirmPassword,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Checkbox(
                        value: _isAgree,
                        onChanged: (bool? value) {
                          setState(() {
                            _isAgree = value ?? false;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                      const Expanded(
                        child: Text(
                          "I agree to the Terms and Conditions",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: isButtonEnabled ? signUp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonEnabled
                          ? const Color(0xFF587F38)
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 14),
                    ),
                    child: const Text(
                      'CREATE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
