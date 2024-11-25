import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealTimeVideoContainer extends StatefulWidget {
  const RealTimeVideoContainer({super.key});

  @override
  _RealTimeVideoContainerState createState() => _RealTimeVideoContainerState();
}

class _RealTimeVideoContainerState extends State<RealTimeVideoContainer> {
  late SupabaseClient _supabaseClient;
  late List<String> _collectionPoints;
  String _selectedCollectionPoint = '';
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    _supabaseClient = Supabase.instance.client;
    _collectionPoints = [];
    _fetchCollectionPoints();
  }

  // Fetch collection points from Supabase
  Future<void> _fetchCollectionPoints() async {
    final response = await _supabaseClient
        .from('collection_point')
        .select('cp_name, cp_address')
        .eq('cp_add_state', 'yes')
        .order('cp_name', ascending: true);

    // Handle empty or error response
    if (response.isEmpty) {
      print('No collection points found');
      return;
    }

    List<String> collectionPoints = [];
    for (var item in response) {
      final cpName = item['cp_name'] as String;
      final cpAddress = item['cp_address'] as String;
      collectionPoints.add('$cpName ($cpAddress)');
    }

    setState(() {
      _collectionPoints = collectionPoints;
      if (_collectionPoints.isNotEmpty) {
        _selectedCollectionPoint = _collectionPoints[0];
        _loadLatestImage(_selectedCollectionPoint);
      }
    });
  }

  // Load the latest image for the selected collection point
  Future<void> _loadLatestImage(String collectionPoint) async {
    final response = await _supabaseClient
        .from('images')
        .select('image_url')
        .eq('cp_name', collectionPoint)
        .order('created_at', ascending: false)
        .limit(1)
        .single();

    // Check if the response has valid data
    if (response == null || response.isEmpty) {
      print('No images found for the selected collection point');
      return;
    }

    setState(() {
      _imageUrl = response[0]['image_url']; // Assuming the response is a list
    });
  }

  // Upload a request to capture an image
  Future<void> _uploadRequest() async {
    final response = await _supabaseClient
        .from('controls')
        .insert([
          {'who': 'live request $_selectedCollectionPoint'}
        ]);

    // Handle response
    if (response.isEmpty) {
      print('Error uploading request');
    } else {
      print('Request uploaded successfully');
      _loadLatestImage(_selectedCollectionPoint);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Realtime Status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: DropdownButtonFormField<String>(
                    hint: const Text("Select Collection Point"),
                    value: _selectedCollectionPoint.isNotEmpty
                        ? _selectedCollectionPoint
                        : null,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _collectionPoints
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 14),
                              ),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCollectionPoint = newValue ?? '';
                        _loadLatestImage(_selectedCollectionPoint);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 23, 123, 14),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _uploadRequest,
                    child: const Text(
                      "Check",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.width * 0.75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromARGB(255, 23, 123, 14),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _imageUrl.isEmpty
                      ? Image.asset(
                          'assets/img/logspin.gif',
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          _imageUrl,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Live Video Feed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  // color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
