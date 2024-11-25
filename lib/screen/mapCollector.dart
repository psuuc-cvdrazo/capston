// import 'dart:math' as math;
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;

// List<LatLng> decodePolyline(String encoded) {
//   List<LatLng> polyline = [];
//   int index = 0;
//   int len = encoded.length;
//   int lat = 0;
//   int lng = 0;

//   while (index < len) {
//     int b;
//     int shift = 0;
//     int result = 0;
//     do {
//       b = encoded.codeUnitAt(index++) - 63;
//       result |= (b & 0x1f) << shift;
//       shift += 5;
//     } while (b >= 0x20);
//     int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//     lat += dlat;
//     shift = 0;
//     result = 0;
//     do {
//       b = encoded.codeUnitAt(index++) - 63;
//       result |= (b & 0x1f) << shift;
//       shift += 5;
//     } while (b >= 0x20);
//     int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//     lng += dlng;
//     polyline.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
//   }
//   return polyline;
// }

// class CollectorCollectorMapScreen extends StatefulWidget {
//   const CollectorCollectorMapScreen({super.key});

//   @override
//   _CollectorCollectorMapScreenState createState() => _CollectorCollectorMapScreenState();
// }

// class _CollectorCollectorMapScreenState extends State<CollectorCollectorMapScreen> {
//   GoogleMapController? mapController;
//   final LatLng _currentLocation = const LatLng(15.992436859512932, 120.58248462748088);
//   final LatLng _anotherLocation = const LatLng(15.984517543933535, 120.57538313686358);
//   LatLng? _userLocation;
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   final double _zoomLevel = 17.0;

//   bool _showCurrentPolylines = false;
//   bool _showAnotherPolylines = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissions();
//   }

//   Future<void> _checkPermissions() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       print('Location services are disabled.');
//       return;
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
//         print('Location permissions are denied.');
//         return;
//       }
//     }

//     _getUserLocation();
//   }

//   Future<void> _getUserLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         _userLocation = LatLng(position.latitude, position.longitude);
//         _addMarker();
//         _updateCamera();
//       });
//     } catch (e) {
//       print('Error getting location: $e');
//     }
//   }

//   Future<List<LatLng>> _getRoutePolyline(LatLng origin, LatLng destination) async {
//     const apiKey = '5b3ce3597851110001cf6248ecbc6d0f1a8d48b59b0a4a1e43531e2b';
//     final url =
//         'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${origin.longitude},${origin.latitude}&end=${destination.longitude},${destination.latitude}';

//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final List<dynamic> coordinates = data['features'][0]['geometry']['coordinates'];

//       final List<LatLng> points = coordinates.map((coord) {
//         return LatLng(coord[1], coord[0]);
//       }).toList();

//       return points;
//     } else {
//       print('Failed to load route: ${response.statusCode}');
//       throw Exception('Failed to load route');
//     }
//   }

//  void _addMarker() async {
//   if (mapController != null) {
//     var markerIcon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'assets/img/binz.png');
//     setState(() {

//       _markers.add(
//         Marker(
//           markerId: const MarkerId('current_location'),
//           position: _currentLocation,
//           icon: markerIcon,
//           onTap: () {
//             _showMarkerInfo(
//               title: 'Barangay Anonas Trashbin',
//               snippet: 'Anonas Road',
//               imagePath: 'assets/img/anonas.png',
//               onGetPressed: () {

//                 _togglePolylinesForCurrentLocation();
//               },
//             );
//           },
//         ),
//       );

//       if (_userLocation != null) {
//         _markers.add(
//           Marker(
//             markerId: const MarkerId('user_location'),
//             position: _userLocation!,
//             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//             onTap: () {
//               _showMarkerInfo(
//                 title: 'Your Location',
//                 snippet: 'You are here',
//                 imagePath: 'assets/img/ROBOT.png',
//                 onGetPressed: () {

//                 },
//               );
//             },
//           ),
//         );
//       }

//       _markers.add(
//         Marker(
//           markerId: const MarkerId('another_location'),
//           position: _anotherLocation,
//           icon: markerIcon,
//           onTap: () {
//             _showMarkerInfo(
//               title: 'San Vicente TrashBin',
//               snippet: 'San Vicente Road',
//               imagePath: 'assets/img/vicente.png',
//               onGetPressed: () {

//                 _togglePolylinesForAnotherLocation();
//               },
//             );
//           },
//         ),
//       );
//     });
//   }
// }

//  void _showMarkerInfo({
//   required String title,
//   required String snippet,
//   required String imagePath,
//   required Function onGetPressed,
// }) {
//   showModalBottomSheet(
//     context: context,
//     builder: (context) {
//       return Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.asset(
//               imagePath,
//               height: 150,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               snippet,
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 onGetPressed();
//               },
//               child: const Text('Get'),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

//   void _togglePolylinesForCurrentLocation() async {

//   if (_showAnotherPolylines) {
//     _removePolylines();
//     _showAnotherPolylines = false;
//   }

//   if (_showCurrentPolylines) {
//     _removePolylines();
//   } else {
//     await _addPolylinesToCurrentLocation();
//   }
//   setState(() {
//     _showCurrentPolylines = !_showCurrentPolylines;
//   });
// }

//  void _togglePolylinesForAnotherLocation() async {

//   if (_showCurrentPolylines) {
//     _removePolylines();
//     _showCurrentPolylines = false;
//   }

//   if (_showAnotherPolylines) {
//     _removePolylines();
//   } else {
//     await _addPolylinesToAnotherLocation();
//   }
//   setState(() {
//     _showAnotherPolylines = !_showAnotherPolylines;
//   });
// }

//   Future<void> _addPolylinesToCurrentLocation() async {
//     if (_userLocation != null) {
//       try {
//         final pointsToCurrent = await _getRoutePolyline(_userLocation!, _currentLocation);
//         if (pointsToCurrent.isNotEmpty) {
//           setState(() {
//             _polylines.add(
//               Polyline(
//                 polylineId: const PolylineId('route_to_current'),
//                 points: pointsToCurrent,
//                 color: Colors.blue,
//                 width: 5,
//               ),
//             );
//           });
//         }
//       } catch (e) {
//         print('Error fetching route: $e');
//       }
//     }
//   }

//   Future<void> _addPolylinesToAnotherLocation() async {
//     if (_userLocation != null) {
//       try {
//         final pointsToAnother = await _getRoutePolyline(_userLocation!, _anotherLocation);
//         if (pointsToAnother.isNotEmpty) {
//           setState(() {
//             _polylines.add(
//               Polyline(
//                 polylineId: const PolylineId('route_to_another'),
//                 points: pointsToAnother,
//                 color: Colors.red,
//                 width: 5,
//               ),
//             );
//           });
//         }
//       } catch (e) {
//         print('Error fetching route: $e');
//       }
//     }
//   }

//   void _removePolylines() {
//     setState(() {
//       _polylines.clear();
//     });
//   }

//   void _updateCamera() {
//     if (mapController != null && _userLocation != null) {
//       LatLngBounds bounds = LatLngBounds(
//         southwest: LatLng(
//           math.min(_userLocation!.latitude, _currentLocation.latitude),
//           math.min(_userLocation!.longitude, _currentLocation.longitude),
//         ),
//         northeast: LatLng(
//           math.max(_userLocation!.latitude, _currentLocation.latitude),
//           math.max(_userLocation!.longitude, _currentLocation.longitude),
//         ),
//       );

//       mapController?.animateCamera(
//         CameraUpdate.newLatLngBounds(bounds, 50),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Solid Waste Management Map',style: TextStyle(color: Colors.white),),
//         centerTitle: true,
//         backgroundColor: Colors.green.shade900,
//       ),
//       body: GoogleMap(
//         onMapCreated: (controller) {
//           mapController = controller;
//         },
//         initialCameraPosition: CameraPosition(
//           target: _currentLocation,
//           zoom: _zoomLevel,
//         ),
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//         markers: _markers,
//         polylines: _polylines,
//         mapType: MapType.normal,
//       ),
//     );
//   }
// }
import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';
import 'package:capstoneapp/screen/collectorside/collectordetailsb.dart';
import 'package:capstoneapp/screen/userside/detail.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

List<LatLng> decodePolyline(String encoded) {
  List<LatLng> polyline = [];
  int index = 0;
  int len = encoded.length;
  int lat = 0;
  int lng = 0;

  while (index < len) {
    int b;
    int shift = 0;
    int result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;
    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    polyline.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
  }
  return polyline;
}

class CollectorMapScreen extends StatefulWidget {
  const CollectorMapScreen({super.key});

  @override
  _CollectorMapScreenState createState() => _CollectorMapScreenState();
}

class _CollectorMapScreenState extends State<CollectorMapScreen> {
  GoogleMapController? mapController;
  final List<LatLng> _collectionPoints =
      []; // Store fetched collection points here

  LatLng? _userLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final double _zoomLevel = 17.0;
  double _distanceToDestination = 0.0;
  String _estimatedTime = '';
  bool routez = false;
  bool _showCurrentPolylines = false;
  bool _showAnotherPolylines = false;
  bool _showPolylines = false;
  bool _hasRoute = false;
  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _fetchCollectionPoints();
  }

  Future<void> _fetchCollectionPoints() async {
    final List<Map<String, dynamic>> response = await Supabase.instance.client
        .from('collection_point')
        .select('cp_name, cp_address, cp_lat, cp_long, image_url');

    for (var point in response) {
      final String cpName = point['cp_name'];
      final String cpAddress = point['cp_address'];
      final double cpLat = point['cp_lat'];
      final double cpLong = point['cp_long'];
      final String imageUrl = point['image_url'];

      // Add each collection point to the list and as a marker
      final LatLng location = LatLng(cpLat, cpLong);
      _collectionPoints.add(location);
      _addMarker(cpName, cpAddress, cpLat, cpLong, imageUrl);
    }
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Location permissions are denied.');
        return;
      }
    }

    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _addUserMarker(); // Add user marker specifically
        _updateCamera();
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<double> _calculateDistance(LatLng origin, LatLng destination) async {
    return Geolocator.distanceBetween(
          origin.latitude,
          origin.longitude,
          destination.latitude,
          destination.longitude,
        ) /
        1000;
  }

  Future<List<LatLng>> _getRoutePolyline(
      LatLng origin, LatLng destination) async {
    const apiKey = '5b3ce3597851110001cf6248ecbc6d0f1a8d48b59b0a4a1e43531e2b';
    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${origin.longitude},${origin.latitude}&end=${destination.longitude},${destination.latitude}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coordinates =
          data['features'][0]['geometry']['coordinates'];

      final List<LatLng> points = coordinates.map((coord) {
        return LatLng(coord[1], coord[0]);
      }).toList();

      return points;
    } else {
      print('Failed to load route: ${response.statusCode}');
      throw Exception('Failed to load route');
    }
  }

  void _addUserMarker() {
    if (_userLocation != null) {
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: _userLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );
      });
    }
  }

  Future<void> _addPolylinesToLocation(LatLng destination) async {
    if (_userLocation != null) {
      try {
        final points = await _getRoutePolyline(_userLocation!, destination);
        if (points.isNotEmpty) {
          double distance =
              await _calculateDistance(_userLocation!, destination);
          double estimatedTimeInHours = distance / 50; // Speed in km/h
          String estimatedTime =
              "${(estimatedTimeInHours * 60).toStringAsFixed(0)} min";

          setState(() {
            _polylines.add(Polyline(
              polylineId: PolylineId(
                  'route_to_${destination.latitude}_${destination.longitude}'),
              points: points,
              color: Colors.blue,
              width: 5,
            ));
            _distanceToDestination = distance;
            _estimatedTime = estimatedTime;
            _hasRoute = true; // Update route status
          });
        } else {
          _hasRoute = false; // No route found
        }
      } catch (e) {
        print('Error fetching route: $e');
        _hasRoute = false; // Error while fetching route
      }
    }
  }

  void _togglePolylinesForLocation(LatLng destination) async {
    // Clear any previous polyline if visible
    if (_showCurrentPolylines) {
      _removePolylines();
    } else {
      // Draw route to the specified destination
      await _addPolylinesToLocation(destination);
    }
    setState(() {
      _showCurrentPolylines = !_showCurrentPolylines;
    });
  }

  void _addMarker(String name, String address, double lat, double long,
      String imageUrl) async {
    if (mapController != null) {
      var markerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        'assets/img/binz.png',
      );

      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(name), // Unique marker ID
            position: LatLng(lat, long), // Use fetched coordinates
            icon: markerIcon,
            onTap: () {
              _showMarkerInfo(
                title: name,
                snippet: address,
                imagePath: imageUrl,
                onGetPressed: () {
                  _togglePolylinesForLocation(
                      LatLng(lat, long)); // Pass destination dynamically
                },
                onGetPressed2: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CollectorPointDetails(
                        collectionPoint: name,
                        collectionAddress: address,
                      ),
                    ),
                  );
                },
                destination: LatLng(lat, long),
              );
            },
          ),
        );
      });
    }
  }

  void _showMarkerInfo({
    required String title,
    required String snippet,
    required String imagePath,
    required Function onGetPressed,
    required Function onGetPressed2,
    LatLng? destination,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(imagePath, height: 150,
                  errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 100);
              }),
              const SizedBox(height: 8),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                snippet,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 40, 59, 23),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close the modal
                        onGetPressed(); // Then call the onGetPressed function
                      },
                      child: _hasRoute
                          ? Text(
                              'Remove Route',
                              style: TextStyle(color: Colors.white),
                            )
                          : Text(
                              'Get Route',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 6, 150, 76),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      onPressed: () => onGetPressed2(),
                      child: const Text(
                        'Details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addPolylinesToAllLocations() async {
    if (_userLocation != null) {
      for (final destination in _collectionPoints) {
        try {
          final points = await _getRoutePolyline(_userLocation!, destination);
          if (points.isNotEmpty) {
            setState(() {
              _polylines.add(
                Polyline(
                  polylineId: PolylineId(
                      'route_to_${destination.latitude}_${destination.longitude}'),
                  points: points,
                  color: Colors.blue,
                  width: 5,
                ),
              );
            });
          }
        } catch (e) {
          print('Error fetching route: $e');
        }
      }
    }
  }

  void _togglePolylines() async {
    if (_showPolylines) {
      _removePolylines();
    } else {
      await _addPolylinesToAllLocations();
    }
    setState(() {
      _showPolylines = !_showPolylines;
    });
  }

  void _removePolylines() {
    setState(() {
      _polylines.clear();
    });
  }

  String _calculateWalkingTime() {
    // Assuming an average walking speed of 5 km/h
    double walkingSpeed = 5.0; // km/h
    double timeInHours = _distanceToDestination / walkingSpeed;

    // Calculate hours and minutes separately
    int hours = timeInHours.floor(); // Get the integer part as hours
    int minutes =
        ((timeInHours - hours) * 60).round(); // Calculate remaining minutes

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  String _calculateDrivingTime() {
    // Assuming an average driving speed of 50 km/h
    double drivingSpeed = 30.0; // km/h
    double timeInHours = _distanceToDestination / drivingSpeed;
    int hours = timeInHours.floor(); // Get the integer part as hours
    int minutes =
        ((timeInHours - hours) * 60).round(); // Calculate remaining minutes

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  Widget _buildRouteInfo(String mode, String time) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            mode,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            'Estimated Time: $time',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _updateCamera() {
    if (mapController != null &&
        _userLocation != null &&
        _collectionPoints.isNotEmpty) {
      LatLngBounds bounds = _calculateBounds();
      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    }
  }

  LatLngBounds _calculateBounds() {
    double minLat = _userLocation!.latitude;
    double maxLat = _userLocation!.latitude;
    double minLng = _userLocation!.longitude;
    double maxLng = _userLocation!.longitude;

    for (LatLng point in _collectionPoints) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solid Waste Management Map',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 47, 61, 2),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
          _updateCamera();
        },
        initialCameraPosition: CameraPosition(
          target: _userLocation ??
              (_collectionPoints.isNotEmpty
                  ? _collectionPoints.first
                  : LatLng(0, 0)),
          zoom: _zoomLevel,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
        polylines: _polylines,
        mapType: MapType.normal,
      ),
      bottomSheet: _hasRoute
          ? Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Route Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _removePolylines(); // Remove the polyline
                          setState(() {
                            _hasRoute =
                                false; // Update state to hide the bottom sheet
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Distance: ${_distanceToDestination.toStringAsFixed(2)} km',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRouteInfo('🚶 Walk', _calculateWalkingTime()),
                      _buildRouteInfo('🚗 Drive', _calculateDrivingTime()),
                    ],
                  ),
                ],
              ),
            )
          : null, // Do not show the bottom sheet if no route is available
    );
  }
}
