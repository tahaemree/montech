import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class PlatformGoogleMap extends StatefulWidget {
  const PlatformGoogleMap({super.key});

  @override
  State<PlatformGoogleMap> createState() => _PlatformGoogleMapState();
}

class _PlatformGoogleMapState extends State<PlatformGoogleMap> {
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (kIsWeb) {
      return const Center(child: Text('Web harita burada gösterilir'));
    } else {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          // Map controller kullanılmıyor, sadece callback için bırakıldı
        },
        markers: {
          Marker(
            markerId: const MarkerId('konum'),
            position: _currentPosition!,
            infoWindow: const InfoWindow(title: 'Benim Konumum'),
          ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      );
    }
  }
}
