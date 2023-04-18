import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/filter_model.dart';
import 'package:beez/presentation/feed/feed_screen.dart';
import 'package:beez/presentation/map/map_filters_widget.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/add_event_widget.dart';
import 'package:beez/presentation/shared/hexagon_widget.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  static const name = "map";
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  bool isLoading = true;
  LatLng? _userLocation;
  Map<String, Filter> currentFilters = {};

  @override
  void initState() {
    super.initState();
    getUserCurrentLocation().then((currentLocation) {
      setState(() {
        _userLocation = currentLocation;
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

  void applyFilters(Map<String, Filter> newFilters) {
    setState(() {
      currentFilters = newFilters;
    });
  }

  Future openFilter() {
    return showDialog(
        context: context,
        builder: (dialogCtx) =>
            MapFilters(userFilters: currentFilters, onSave: applyFilters));
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition =
        CameraPosition(target: _userLocation ?? const LatLng(0, 0), zoom: 15);
    return SafeArea(
        child: Loading(
            isLoading: isLoading,
            child: Scaffold(
                body: Stack(
                  children: [
                    GoogleMap(
                        onMapCreated: _onMapCreated,
                        myLocationButtonEnabled: false,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        initialCameraPosition: initialPosition),
                    Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(7),
                                boxShadow: const [
                                  BoxShadow(
                                      color: AppColors.shadow,
                                      blurRadius: 10,
                                      offset: Offset(2, 2))
                                ]),
                            width: 320,
                            height: 45,
                            child: Row(
                              children: const [
                                Expanded(
                                    child: TextField(
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                )),
                                Icon(Icons.search, color: AppColors.mediumGrey)
                              ],
                            ))),
                    Positioned(
                      right: 5,
                      top: 140,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        GestureDetector(
                            onTap: openFilter,
                            child: const Hexagon(
                                child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.filter_alt,
                                  size: 30, color: AppColors.black),
                            ))),
                        const SizedBox(height: 15),
                        GestureDetector(
                            onTap: () {
                              mapController.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                      initialPosition));
                            },
                            child: const Hexagon(
                                child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.my_location_sharp,
                                  size: 26, color: AppColors.black),
                            )))
                      ]),
                    ),
                    const AddEvent()
                  ],
                ),
                bottomNavigationBar: const TabNavigation())));
  }
}
