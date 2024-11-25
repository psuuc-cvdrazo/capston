import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CollectionPointsScreen extends StatefulWidget {
  final String collectionPoint;
  final String collectionAddress;

  CollectionPointsScreen({
    Key? key,
    required this.collectionPoint,
    required this.collectionAddress,
  }) : super(key: key);

  @override
  _CollectionPointsScreenState createState() => _CollectionPointsScreenState();
}

class _CollectionPointsScreenState extends State<CollectionPointsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  File? _capturedImage;
  String? _uploadedImageUrl;
  List<dynamic> feedbackList = [];
  final collectionPointController = TextEditingController();
  final String supabaseUrl = "https://uiciowpyxfawjvaddivu.supabase.co";
  final String supabaseKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpY2lvd3B5eGZhd2p2YWRkaXZ1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNzE0MDQyMCwiZXhwIjoyMDQyNzE2NDIwfQ.kR8PsVyqtW0QTJoFjFq6aiXU-iq0y3alXfJQIRMVgBw";
  final String storageBucket = "images/public";
  Map<String, dynamic>? historyData;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchFeedback().then((data) {
      setState(() {
        feedbackList = data;
      });
    }).catchError((e) {
      print('Failed to load feedback: $e');
    });
    collectionPointController.text = widget.collectionAddress;
    fetchHistoryData();
  }

  Future<void> fetchHistoryData() async {
    final data = await fetchLatestHistory(widget.collectionPoint);
    setState(() {
      historyData = data;
    });
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  Future<void> _uploadImage() async {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image captured")),
      );
      return;
    }

    String imageName =
        "cp_approval-${DateTime.now().millisecondsSinceEpoch}.png";
    Uri uploadUrl =
        Uri.parse("$supabaseUrl/storage/v1/object/$storageBucket/$imageName");

    try {
      final response = await http.post(
        uploadUrl,
        headers: {
          "Authorization": "Bearer $supabaseKey",
          "Content-Type": "image/png",
        },
        body: _capturedImage!.readAsBytesSync(),
      );

      if (response.statusCode == 200) {
        String imageUrl =
            "$supabaseUrl/storage/v1/object/public/$storageBucket/$imageName";
        setState(() {
          _uploadedImageUrl = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully!")),
        );
      } else {
        print("Failed to upload image: ${response.body}");
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> _sendApprovalRecord() async {
    if (_uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No uploaded image URL available")),
      );
      return;
    }

    Uri approvalUrl = Uri.parse("$supabaseUrl/rest/v1/cp_approval");

    Map<String, dynamic> payload = {
      "image_url": _uploadedImageUrl,
      "status": "full",
      "cp_name": widget.collectionPoint,
    };

    try {
      final response = await http.post(
        approvalUrl,
        headers: {
          "Authorization": "Bearer $supabaseKey",
          "Content-Type": "application/json",
          "apikey": supabaseKey,
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        print("Failed to send approval record: ${response.body}");
      }
    } catch (e) {
      print("Error sending approval record: $e");
    }
  }

  Future<Map<String, dynamic>?> fetchLatestHistory(
      String collectionPoint) async {
    try {
      final response = await supabase
          .from('history')
          .select()
          .eq('cp_name', collectionPoint)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      if (response != null) {
        return response as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching history: $e');
    }
    return null;
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text("Success"),
          ],
        ),
        content: const Text(
          "Your image has been successfully uploaded and sent for approval!",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> fetchFeedback() async {
    try {
      final response = await supabase
          .from('history')
          .select('created_at, image_url, status')
          .eq(
              'cp_name',
              widget
                  .collectionPoint) // Use 'cp_name' instead of 'collection_point'
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        print('No history found.');
        return [];
      } else {
        print('Fetched feedback: $response'); // Debugging log
        return response; // Already a List<Map<String, dynamic>>
      }
    } catch (e) {
      print('Error fetching history: $e');
      return [];
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              // Image content
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.maxFinite,
                  height: 300, // adjust height as needed
                ),
              ),
              // Close button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.black54,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> captureAndUploadImage() async {
    const supabaseUrl = "https://uiciowpyxfawjvaddivu.supabase.co";
    const supabaseKey =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpY2lvd3B5eGZhd2p2YWRkaXZ1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNzE0MDQyMCwiZXhwIjoyMDQyNzE2NDIwfQ.kR8PsVyqtW0QTJoFjFq6aiXU-iq0y3alXfJQIRMVgBw";
    const storageBucket = "images/public";
    const cpApprovalTableUrl = "$supabaseUrl/rest/v1/cp_approval";

    try {
      // Simulate capturing an image (You should integrate ESP32 camera capture logic here).
      final byteData =
          await DefaultAssetBundle.of(context).load('assets/img/def.jpg');
      final List<int> imageBytes = byteData.buffer.asUint8List();

      // Generate unique image name.
      final imageName =
          "cp_approval-${DateTime.now().millisecondsSinceEpoch}.png";

      // Upload image to Supabase storage.
      final storageUrl =
          "$supabaseUrl/storage/v1/object/$storageBucket/$imageName";
      final storageResponse = await http.post(
        Uri.parse(storageUrl),
        headers: {
          "Authorization": "Bearer $supabaseKey",
          "Content-Type": "image/png",
        },
        body: imageBytes,
      );

      if (storageResponse.statusCode == 200) {
        print("Image uploaded successfully!");
      } else {
        print("Error uploading image: ${storageResponse.statusCode}");
        print(
            "Response body: ${storageResponse.body}"); // Debugging the response
      }

      if (storageResponse.statusCode == 200) {
        // Image upload successful.
        final imageUrl =
            "$supabaseUrl/storage/v1/object/public/$storageBucket/$imageName";

        // Add record to `cp_approval` table in Supabase.
        final payload = {
          "image_url": imageUrl,
          "status": "full",
          "cp_name": widget.collectionPoint,
        };

        final approvalResponse = await http.post(
          Uri.parse(cpApprovalTableUrl),
          headers: {
            "Authorization": "Bearer $supabaseKey",
            "Content-Type": "application/json",
            "apikey": supabaseKey,
          },
          body: jsonEncode(payload), // jsonEncode serializes the payload.
        );

        if (approvalResponse.statusCode == 201) {
          print("Record added successfully to cp_approval table!");
        } else {
          print("Error adding record: ${approvalResponse.statusCode}");
        }
      } else {
        print("Error uploading image: ${storageResponse.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  void _showReportForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.0,
              right: 16.0,
              top: 16.0),
          child: _buildReportForm(),
        );
      },
    );
  }

  Widget _buildReportForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(
          child: Text(
            'REQUEST',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 36),
        const Text("COLLECTION POINT", style: TextStyle(color: Colors.black)),
        TextField(
          readOnly: true,
          controller: collectionPointController,
          decoration: InputDecoration(
            labelStyle: const TextStyle(color: Colors.black),
            hintText: widget.collectionAddress,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: _capturedImage != null
                ? Image.file(
                    _capturedImage!,
                    width: 400,
                    height: 320,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/img/def.jpg',
                    width: 400,
                    height: 320,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _captureImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF587F38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Request',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () async {
                await _uploadImage();
                await _sendApprovalRecord();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D9E73),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                'Send',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _capitalizeStatus(String? status) {
    if (status == null) {
      return 'UNKNOWN';
    }
    if (status.toLowerCase() == 'full') {
      return 'FULL';
    } else if (status.toLowerCase() == 'available') {
      return 'AVAILABLE';
    }
    return status.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (historyData == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    final status = historyData!['status'] ?? 'Unknown';
    final createdAt = historyData!['created_at'] ?? 'Unknown date';
    final imageUrl = historyData!['image_url'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.collectionPoint} - ${widget.collectionAddress}',
          style: TextStyle(color: Colors.black),
        ),

        centerTitle: true,
        // backgroundColor: Color.fromARGB(255, 47, 61, 2),
        // titleTextStyle: TextStyle(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF1B3313),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  height: 150,
                                  width: 120,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 120,
                                  color: Colors.grey,
                                  child: Center(
                                    child: Text(
                                      'No Image',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Garbage Status:',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              // Display dynamic status
                              Text(
                                _capitalizeStatus(historyData?['status']),
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: (historyData?['status'] == 'full')
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 25.0),
                              // Display dynamic message based on status
                              Text(
                                (historyData?['status'] == 'full')
                                    ? 'NEEDS TO BE EMPTIED'
                                    : 'IT IS READY TO BE FILLED',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: (historyData?['status'] == 'full')
                                      ? Colors.redAccent
                                      : Colors.greenAccent,
                                ),
                              ),
                             
                              // Format and display dynamic date
                              Text(
                                _formatDateTime(historyData?['created_at']),
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _showReportForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .white, // Button background color
                                        foregroundColor:
                                            Colors.green, // Text and icon color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.0), // Smaller rounded corners
                                        ),
                                        elevation:
                                            3, // Slightly reduced shadow effect
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 8.0), // Reduced padding
                                        minimumSize: Size(100,
                                            36), // Smaller overall button size
                                      ),
                                      child: Text(
                                        'Request',
                                        style: TextStyle(
                                          fontSize:
                                              14.0, // Slightly smaller font size
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.0),
              Text(
                'Logs',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFEDF0DC),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'DATE AND TIME',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'IMAGE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'STATUS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: feedbackList.map((feedback) {
                        return _buildLogRow(
                          feedback['created_at'] ?? 'Unknown date',
                          'View',
                          feedback['status'] ?? 'Unknown status',
                          feedback['is_full'] ?? false,
                          feedback,
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getImagePath(String collectionPoint) {
    switch (collectionPoint) {
      case 'Point 1':
        return 'assets/img/anonas.png';
      case 'Point 2':
        return 'assets/img/vicente.png';
      default:
        return 'assets/img/def.jpg';
    }
  }

  String _formatDateTime(String dateTimeStr) {
    final DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
    final hongKongTime =
        dateTime.add(Duration(hours: 8)); // Convert to Hong Kong time (UTC+8)
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(hongKongTime);
  }

  Widget _buildLogRow(String dateTime, String imageSource, String status,
      bool isFull, Map<String, dynamic> feedback) {
    IconData icon;
    Color iconColor;

    // Map the `status` value from Supabase to uppercase "FULL" for display
    String displayStatus =
        status.toLowerCase() == 'full' ? 'FULL' : status.toUpperCase();
    status.toLowerCase() == 'emptied' ? 'EMPTIED' : status.toUpperCase();

    // Set icon and color based on status
    if (status == 'full') {
      icon = Icons.warning;
      iconColor = Colors.red;
    } else if (status == 'emptied') {
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else {
      icon = Icons.error;
      iconColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Date and time column
            Expanded(
              flex: 3,
              child: Text(
                _formatDateTime(dateTime),
                style: TextStyle(color: Colors.black, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            // Image column
            Expanded(
              flex: 2,
              child: TextButton(
                onPressed: () {
                  if (feedback['image_url'] != null) {
                    _showImageDialog(feedback['image_url']);
                  } else {
                    print('No image available');
                  }
                },
                child: Text(
                  imageSource,
                  style:
                      TextStyle(color: const Color.fromARGB(255, 23, 123, 14)),
                ),
              ),
            ),
            // Status column
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 18),
                  SizedBox(width: 4.0),
                  Text(
                    displayStatus,
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
