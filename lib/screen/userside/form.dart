import 'dart:io';
import 'package:capstoneapp/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickalert/quickalert.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  String email = "";
  String firstname = "";
  File? _imageFile;
  final emailController = TextEditingController();
  final firstnameController = TextEditingController();
  final collectionPointController = TextEditingController();
  final feedbackController = TextEditingController();
  String? selectedCollectionPoint;
  final ImagePicker _picker = ImagePicker();
  final List<String> collectionPoints = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchCollectionPoints(); // Fetch collection points on init
  }

  final Map<String, String> collectionPointsMap =
      {}; // Map to hold cp_name and cp_address

 Future<void> fetchCollectionPoints() async {
  try {
    final supabase = Supabase.instance.client;
    final response =
        await supabase.from('collection_point').select('cp_name, cp_address');
    if (response != null && mounted) {
      setState(() {
        collectionPointsMap.addAll(
          Map.fromIterable(response,
              key: (point) => point['cp_name'], // cp_name as key
              value: (point) => point['cp_address'] // cp_address as value
              ),
        );
      });
    }
  } catch (e) {
    if (mounted) {
      QuickAlert.show(
        context: navigatorKey.currentContext!,
        type: QuickAlertType.error,
        title: "Error",
        text: "Failed to load collection points: $e",
        confirmBtnText: "OK",
      );
    }
  }
}


  @override
  void dispose() {
    emailController.dispose();
    collectionPointController.dispose();
    feedbackController.dispose();
    super.dispose();
  }
Future<void> fetchUserData() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user != null) {
    final response = await supabase
        .from('useraccount')
        .select()
        .eq('uid', user.id)
        .single();
    if (response != null && mounted) {
      setState(() {
        email = response['email'] ?? '';
        firstname = response['firstname'] ?? '';
        emailController.text = email;
        firstnameController.text = firstname;
      });
    }
  }
}


  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      } else {
        QuickAlert.show(
          context: navigatorKey.currentContext!,
          type: QuickAlertType.info,
          title: "No Image Captured",
          text: "Please click the camera icon to capture an image.",
          confirmBtnText: "OK",
          barrierDismissible: false,
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: navigatorKey.currentContext!,
        type: QuickAlertType.error,
        title: "Error",
        text: "Failed to pick image: $e",
        confirmBtnText: "OK",
        barrierDismissible: false,
      );
    }
  }

  bool _isUploading = false;

  Future<void> uploadImage(File file, {VoidCallback? onSuccess}) async {
  try {
    if (!(file.path.endsWith('.jpg') || file.path.endsWith('.png'))) {
      if (mounted) {
        QuickAlert.show(
          context: navigatorKey.currentContext!,
          type: QuickAlertType.error,
          title: "Invalid Image",
          text: "Please select a JPG or PNG image.",
          confirmBtnText: "OK",
          barrierDismissible: false,
        );
      }
      return;
    }

    final supabase = Supabase.instance.client;
    final fileName = basename(file.path);
    final fileBytes = await file.readAsBytes();

    _isUploading = true;
    if (mounted) {
      QuickAlert.show(
        context: navigatorKey.currentContext!,
        type: QuickAlertType.loading,
        text: "Uploading image...",
        barrierDismissible: false,
      );
    }

    await supabase.storage
        .from('img')
        .uploadBinary('feedback_img/$fileName', fileBytes);

    _isUploading = false;
    if (mounted) {
      Navigator.pop(navigatorKey.currentContext!);
    }

    if (mounted) {
      QuickAlert.show(
        context: navigatorKey.currentContext!,
        type: QuickAlertType.success,
        title: "Upload Successful",
        text: "Image uploaded successfully!",
        confirmBtnText: "OK",
        barrierDismissible: false,
        onConfirmBtnTap: () {
          Navigator.pop(navigatorKey.currentContext!);
          if (onSuccess != null) {
            onSuccess();
          }
        },
      );
    }
  } catch (e) {
    if (_isUploading) {
      _isUploading = false;
      if (mounted) {
        Navigator.pop(navigatorKey.currentContext!);
      }
    }

    if (mounted) {
      QuickAlert.show(
        context: navigatorKey.currentContext!,
        type: QuickAlertType.error,
        title: "Upload Failed",
        text: "Failed to upload image: $e",
        confirmBtnText: "OK",
        barrierDismissible: false,
      );
    }
  }
}


  Future<void> submitForm() async {
  String firstnameto = firstnameController.text.trim();
  String userEmail = emailController.text.trim();
  String collectionPoint = selectedCollectionPoint ?? '';
  String userFeedback = feedbackController.text.trim();
  
  // Get the cp_address for the selected collection point
  String? cpAddress = collectionPointsMap[selectedCollectionPoint];

  if (userEmail.isEmpty ||
      collectionPoint.isEmpty ||
      userFeedback.isEmpty ||
      _imageFile == null) {
    QuickAlert.show(
      context: navigatorKey.currentContext!,
      type: QuickAlertType.warning,
      title: "Incomplete Form",
      text: "Please fill in all fields and upload an image.",
      confirmBtnText: "OK",
      barrierDismissible: false,
    );
    return;
  }

  if (_imageFile != null) {
    await uploadImage(_imageFile!, onSuccess: () async {
      try {
        final supabase = Supabase.instance.client;
        final fileName = basename(_imageFile!.path);
        String? imageUrl = supabase.storage
            .from('img')
            .getPublicUrl('feedback_img/$fileName');

        await supabase.from('userfeedback').insert({
          "username": firstnameto,
          "email": userEmail,
          "cp_name": collectionPoint, // cp_name
          "cp_address": cpAddress, // cp_address
          "feedback": userFeedback,
          "img_fb": imageUrl,
          "created_at": DateTime.now().toIso8601String(),
        });

        QuickAlert.show(
          context: navigatorKey.currentContext!,
          type: QuickAlertType.success,
          title: "Feedback Submitted",
          text: "Feedback submitted successfully!",
          confirmBtnText: "OK",
          barrierDismissible: false,
          onConfirmBtnTap: () {
            Navigator.pop(navigatorKey.currentContext!);
            collectionPointController.clear();
            feedbackController.clear();
            selectedCollectionPoint = null;
            _imageFile = null;
            setState(() {});
          },
        );
      } catch (e) {
        QuickAlert.show(
          context: navigatorKey.currentContext!,
          type: QuickAlertType.error,
          title: "Submission Failed",
          text: "Failed to submit feedback: $e",
          confirmBtnText: "OK",
          barrierDismissible: false,
        );
      }
    });
  } else {
    QuickAlert.show(
      context: navigatorKey.currentContext!,
      type: QuickAlertType.warning,
      title: "No Image",
      text: "Please upload an image first.",
      confirmBtnText: "OK",
      barrierDismissible: true,
    );
  }
}

  void viewImage() {
    if (_imageFile == null) {
      QuickAlert.show(
        context: navigatorKey.currentContext!,
        type: QuickAlertType.info,
        title: "No Image",
        text: "Please capture an image first.",
        confirmBtnText: "OK",
      );
    } else {
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => ImageViewerScreen(imageFile: _imageFile!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'REPORT FORM',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Text("COLLECTION POINT",
                      style: TextStyle(color: Colors.black)),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: Colors.teal),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    items: collectionPointsMap.keys.map((cpName) {
                      return DropdownMenuItem(
                        value: cpName, // Set the value to cp_name
                        child: Text("$cpName (${collectionPointsMap[cpName]})",
                            style: const TextStyle(
                                color: Colors
                                    .black)), // Display cp_name (cp_address)
                      );
                    }).toList(),
                    value: selectedCollectionPoint,
                    onChanged: (value) {
                      setState(() {
                        selectedCollectionPoint = value;
                      });
                    },
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 24),
                  const Text("FEEDBACK", style: TextStyle(color: Colors.black)),
                  TextField(
                    controller: feedbackController,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                      hintText: 'Type here...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    maxLines: 4,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: viewImage,
                          child: Text(
                            _imageFile != null
                                ? 'View Image'
                                : 'No Image Captured',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: pickImage,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF587F38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text(
                        'Send',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageViewerScreen extends StatelessWidget {
  final File imageFile;

  const ImageViewerScreen({Key? key, required this.imageFile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Image'),
      ),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}
