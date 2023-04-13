import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:overlay_builder/overlay_builder.dart';

class MapScreen extends StatefulWidget {
  static const name = "map";
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  bool isLoading = true;
  late LatLng _userLocation = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    getUserCurrentLocation().then((currentLocation) {
      setState(() {
        if (currentLocation != null) _userLocation = currentLocation;
        isLoading = false;
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<LatLng?> getUserCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      final location = await Geolocator.getCurrentPosition();
      return LatLng(location.latitude, location.longitude);
    } catch (e) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Loading(
            isLoading: isLoading,
            child: Scaffold(
                body: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition:
                      CameraPosition(target: _userLocation, zoom: 8),
                ),
                bottomNavigationBar: const TabNavigation())));
  }
}
