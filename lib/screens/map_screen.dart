import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndFetch();
  }

  Future<void> _checkLocationPermissionAndFetch() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Konum servisleri kapalı');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      _showSnackBar('Konum izni verilmedi');
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _updateCurrentLocation(position);
  }

  void _updateCurrentLocation(Position position) {
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'Benim Konumum'),
        ),
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 15),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition ??
              const LatLng(41.015137, 28.979530), // İstanbul varsayılan
          zoom: 15,
        ),
        onMapCreated: (controller) => _mapController = controller,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
        compassEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
}


// esgi god
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? _mapController;
//   final Set<Marker> _markers = {};
//   LatLng? _currentPosition;

//   @override
//   void initState() {
//     super.initState();
//     _determinePosition();
//   }

//   Future<void> _determinePosition() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Konum servisleri kapalı')),
//       );
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.deniedForever ||
//           permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Konum izni verilmedi')),
//         );
//         return;
//       }
//     }

//     Position position = await Geolocator.getCurrentPosition();
//     setState(() {
//       _currentPosition = LatLng(position.latitude, position.longitude);
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('current_location'),
//           position: _currentPosition!,
//           infoWindow: const InfoWindow(title: 'Benim Konumum'),
//         ),
//       );
//     });

//     _mapController?.animateCamera(
//       CameraUpdate.newLatLngZoom(_currentPosition!, 15),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Canlı Konum")),
//       body: _currentPosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: _currentPosition!,
//                 zoom: 14,
//               ),
//               onMapCreated: (controller) => _mapController = controller,
//               markers: _markers,
//               compassEnabled: true,
//               zoomControlsEnabled: true,
//             ),
//     );
//   }
// }
// eski god son




// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? _mapController;
//   LatLng _currentPosition = const LatLng(41.015137, 28.979530); // Varsayılan: İstanbul
//   final Set<Marker> _markers = {};

//   @override
//   void initState() {
//     super.initState();
//     _determinePosition();
//   }

//   Future<void> _determinePosition() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
//       permission = await Geolocator.requestPermission();
//       if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
//         return;
//       }
//     }

//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

//     setState(() {
//       _currentPosition = LatLng(position.latitude, position.longitude);
//       _markers.clear();
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('current_location'),
//           position: _currentPosition,
//           infoWindow: const InfoWindow(title: 'Şu Anki Konum'),
//         ),
//       );
//     });

//     _mapController?.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: _currentPosition, zoom: 15),
//       ),
//     );
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     // Harita ilk oluşturulduğunda da işaretçiyi koy
//     setState(() {
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('current_location'),
//           position: _currentPosition,
//           infoWindow: const InfoWindow(title: 'Başlangıç Noktası'),
//         ),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Canlı Konum")),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: _currentPosition,
//           zoom: 14,
//         ),
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//         zoomControlsEnabled: true,
//         compassEnabled: true,
//         markers: _markers,
//       ),
//     );
//   }
// }







// import 'dart:html' as html; // sadece web için
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import '../widgets/google_map_widget.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   double? _latitude;
//   double? _longitude;
//   bool _locationAccessDenied = false;

//   @override
//   void initState() {
//     super.initState();
//     if (kIsWeb) {
//       _getLocationForWeb();
//     } else {
//       // Mobilde GoogleMap widget'ı kullanılabilir
//     }
//   }

//   void _getLocationForWeb() {
//     try {
//       html.window.navigator.geolocation.getCurrentPosition().then((position) {
//         setState(() {
//           _latitude = position.coords?.latitude;
//           _longitude = position.coords?.longitude;
//         });
//       }).catchError((error) {
//         setState(() {
//           _locationAccessDenied = true;
//         });
//       });
//     } catch (e) {
//       setState(() {
//         _locationAccessDenied = true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Canlı Konum')),
//       body: Center(
//         child: _locationAccessDenied
//             ? const Text("Konum bilgisine erişilemedi.")
//             : (_latitude != null && _longitude != null)
//                 ? SizedBox(
//                     width: double.infinity,
//                     height: 500,
//                     child: GoogleMapWidget(
//                       latitude: _latitude!,
//                       longitude: _longitude!,
//                     ),
//                   )
//                 : const CircularProgressIndicator(),
//       ),
//     );
//   }
// }








// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../widgets/google_map_widget.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   // Harita konumu örneği
//   final LatLng _initialPosition = const LatLng(41.015137, 28.979530); // İstanbul

//   // Yalnızca mobil için: GoogleMapController
//   late GoogleMapController _mapController;
//   final Set<Marker> _markers = {};

//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     setState(() {
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('current_location'),
//           position: _initialPosition,
//           infoWindow: const InfoWindow(title: 'Konum'),
//         ),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Canlı Konum")),
//       body: kIsWeb
//           ? GoogleMapWidget(
//               latitude: _initialPosition.latitude,
//               longitude: _initialPosition.longitude,
//             )
//           : GoogleMap(
//               onMapCreated: _onMapCreated,
//               initialCameraPosition: CameraPosition(
//                 target: _initialPosition,
//                 zoom: 14.0,
//               ),
//               markers: _markers,
//               myLocationEnabled: true,
//               compassEnabled: true,
//             ),
//     );
//   }
// }










// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController _mapController;
//   final Set<Marker> _markers = {};
//   final LatLng _initialPosition = const LatLng(41.015137, 28.979530); // İstanbul örnek

//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     setState(() {
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('current_location'),
//           position: _initialPosition,
//           infoWindow: const InfoWindow(title: 'Konum'),
//         ),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Canlı Konum")),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: _initialPosition,
//           zoom: 14.0,
//         ),
//         markers: _markers,
//         myLocationEnabled: true,
//         compassEnabled: true,
//       ),
//     );
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/sensor_data_provider.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController _mapController;
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};

//   @override
//   Widget build(BuildContext context) {
//     final sensorData = Provider.of<SensorDataProvider>(context);
//     final latLng = LatLng(
//       double.parse(sensorData.currentData.latitude),
//       double.parse(sensorData.currentData.longitude),
//     );
    
//     // Marker oluştur
//     _markers.clear();
//     _markers.add(
//       Marker(
//         markerId: const MarkerId('current_location'),
//         position: latLng,
//         infoWindow: const InfoWindow(title: 'Mevcut Konum'),
//       ),
//     );
    
//     // Geçmiş konumları polyline olarak göster
//     if (sensorData.historicalData.length > 1) {
//       final List<LatLng> polylineCoordinates = [];
      
//       // Son 20 veriyi al
//       final dataPoints = sensorData.historicalData.length > 20 
//           ? sensorData.historicalData.sublist(sensorData.historicalData.length - 20) 
//           : sensorData.historicalData;
          
//       for (var data in dataPoints) {
//         polylineCoordinates.add(LatLng(
//           double.parse(data.latitude),
//           double.parse(data.longitude),
//         ));
//       }
      
//       _polylines.clear();
//       _polylines.add(Polyline(
//         polylineId: const PolylineId('route'),
//         color: Colors.blue,
//         points: polylineCoordinates,
//         width: 5,
//       ));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Konum Takibi'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: latLng,
//                 zoom: 16,
//               ),
//               markers: _markers,
//               polylines: _polylines,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: true,
//               onMapCreated: (controller) {
//                 _mapController = controller;
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16),
//             color: Colors.white,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Konum Bilgileri',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Text('Enlem: ${sensorData.currentData.latitude}'),
//                 Text('Boylam: ${sensorData.currentData.longitude}'),
//                 Text('Son Güncelleme: ${_formatTime(sensorData.currentData.timestamp)}'),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           _mapController.animateCamera(CameraUpdate.newLatLngZoom(
//                             latLng,
//                             18,
//                           ));
//                         },
//                         icon: const Icon(Icons.my_location),
//                         label: const Text('Konuma Git'),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           // Konum paylaşımı simüle ediliyor
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Konum paylaşıldı')),
//                           );
//                         },
//                         icon: const Icon(Icons.share_location),
//                         label: const Text('Konumu Paylaş'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   String _formatTime(DateTime dateTime) {
//     return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
//   }
// }
