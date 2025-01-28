import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;
  LocationData? _currentLocation;
  final Location _location = Location();

// Default map location (Hong Kong)
  static const LatLng _initialPosition = LatLng(22.3193, 114.1694); // Latitude and longitude of Hong Kong


  // Marked location
  final List<Marker> _markers = [
    const Marker(
      markerId: MarkerId("CityU Veterinary Medical Centre"),
      position: LatLng(22.3374, 114.1571),
      infoWindow: InfoWindow(title: "CityU Veterinary Medical Centre"),
    ),
    const Marker(
      markerId: MarkerId("Arca Veterinary Hospital"),
      position: LatLng(22.3192, 114.1685),
      infoWindow: InfoWindow(title: "Arca Veterinary Hospital"),
    ),
    const Marker(
      markerId: MarkerId("Peticare Kowloon East Animal Hospital"),
      position: LatLng(22.3267, 114.2148),
      infoWindow: InfoWindow(title: "Peticare Kowloon East Animal Hospital"),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      // Check whether the service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          print('Location services are disabled.');
          return;
        }
      }

      // Check permissions
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          print('Location permission denied.');
          return;
        }
      }

      // Get current location
      final LocationData locationData = await _location.getLocation();
      setState(() {
        _currentLocation = locationData;
      });
    } catch (e) {
      print('Error initializing location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map Page"),
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator()) // Displays a loading indicator until the positioning data is loaded
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentLocation?.latitude ?? _initialPosition.latitude, // If there is no location information, the default Shanghai location is used
            _currentLocation?.longitude ?? _initialPosition.longitude,
          ),
          zoom: 15,
        ),
        markers: Set.from(_markers),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          print("Google Map created successfully");
        },
      ),
    );
  }
}
