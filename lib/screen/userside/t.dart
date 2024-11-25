import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'dart:async'; // Import the dart:async library for Timer

void main() {
  runApp(MaterialApp(
    home: RealtimeStatusPage(),
  ));
}

class RealtimeStatusPage extends StatefulWidget {
  @override
  _RealtimeStatusPageState createState() => _RealtimeStatusPageState();
}

class _RealtimeStatusPageState extends State<RealtimeStatusPage> {
  final _supabase = SupabaseClient(
    'https://uiciowpyxfawjvaddivu.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpY2lvd3B5eGZhd2p2YWRkaXZ1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNzE0MDQyMCwiZXhwIjoyMDQyNzE2NDIwfQ.kR8PsVyqtW0QTJoFjFq6aiXU-iq0y3alXfJQIRMVgBw',
  );
  List<Map<String, dynamic>> _collectionPoints = [];
  String _selectedCollectionPoint = '';
  String _latestImageUrl = '';
  bool _loadingImage = false;

  @override
  void initState() {
    super.initState();
    _populateDropdown();
  }

  Future<void> _populateDropdown() async {
    // Initial loading of collection points
    final collectionPointsResponse = await _supabase
        .from('collection_point')
        .select('cp_name, cp_address')
        .eq('cp_add_state', 'yes')
        .order('cp_name', ascending: true);

    if (collectionPointsResponse.isNotEmpty) {
      setState(() {
        _collectionPoints = List<Map<String, dynamic>>.from(collectionPointsResponse);
        _selectedCollectionPoint = _collectionPoints.isNotEmpty
            ? _collectionPoints[0]['cp_name']
            : '';
      });
      _loadLatestImage(_selectedCollectionPoint);
    } else {
      print('No collection points found.');
    }
  }

  Future<void> _loadLatestImage(String cpName) async {
    setState(() {
      _loadingImage = true; // Show loading GIF
    });

    final latestImageResponse = await _supabase
        .from('images')
        .select('image_url')
        .eq('cp_id', cpName)
        .order('created_at', ascending: false)
        .limit(1);

    if (latestImageResponse.isNotEmpty) {
      setState(() {
        _latestImageUrl = latestImageResponse[0]['image_url'];
      });
    } else {
      print('No image found for this collection point.');
    }

    setState(() {
      _loadingImage = false; // Hide loading GIF and display the latest image
    });
  }

  Future<void> _uploadRequest() async {
    setState(() {
      _loadingImage = true; // Show loading GIF while processing the request
    });

    final response = await _supabase.from('controls').insert([
      {'who': 'live request $_selectedCollectionPoint'}
    ]);

    if (response.isNotEmpty) {
      print('Request uploaded successfully');
      _loadLatestImage(_selectedCollectionPoint); // Reload the latest image
    } else {
      print('Error uploading request');
    }

    setState(() {
      _loadingImage = false; // Hide loading GIF after the request
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Realtime Status')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _loadingImage
                ? Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(
                      child: Image.asset('assets/img/logspin.gif'), // Show the GIF during loading
                    ),
                  )
                : _latestImageUrl.isEmpty
                    ? Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(child: Text('No Image Available')),
                      )
                    : Container(
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(_latestImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedCollectionPoint.isEmpty
                  ? null
                  : _selectedCollectionPoint,
              onChanged: (value) {
                setState(() {
                  _selectedCollectionPoint = value!;
                  _loadLatestImage(value);
                });
              },
              items: _collectionPoints.map((point) {
                return DropdownMenuItem<String>(
                  value: point['cp_name'],
                  child: Text('${point['cp_name']} (${point['cp_address']})'),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadRequest,
              child: Text('Check'),
            ),
          ],
        ),
      ),
    );
  }
}