import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController _mapController;
  LatLng _center = const LatLng(-1.2921, 36.8219); // Nairobi default
  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('clinic1'),
      position: LatLng(-1.293, 36.822),
      infoWindow: InfoWindow(title: 'Clinic A'),
    ),
  };

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _locateUser() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng userLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _center = userLocation;
      _markers.add(
        Marker(
          markerId: MarkerId('you'),
          position: userLocation,
          infoWindow: InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    });

    _mapController.animateCamera(CameraUpdate.newLatLng(userLocation));
  }

  @override
  void initState() {
    super.initState();
    _locateUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Clinics')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _center, zoom: 14),
        myLocationEnabled: true,
        markers: _markers,
      ),
    );
  }
}
