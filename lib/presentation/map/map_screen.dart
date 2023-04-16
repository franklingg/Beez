import 'dart:typed_data';

import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_icons.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/models/filter_map_model.dart';
import 'package:beez/presentation/map/map_filters_widget.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/add_event_widget.dart';
import 'package:beez/presentation/shared/hexagon_widget.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:beez/utils/images_util.dart';
import 'package:beez/utils/map_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
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
  Map<String, FilterMap> currentFilters = {};
  List<Event> _nearbyEvents = [];
  late Uint8List _marker;

  @override
  void initState() {
    super.initState();
    getUserCurrentLocation().then((currentLocation) {
      setState(() {
        _userLocation = currentLocation;
      });
    }).whenComplete(() async {
      final markerData =
          await ImagesUtil.getBytesFromAsset(AppIcons.marker, 60);
      final events = await getEvents();
      setState(() {
        _marker = markerData;
        _nearbyEvents = events;
        isLoading = false;
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(MapStyle.data);
  }

  Future<LatLng> getUserCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      final location = await Geolocator.getCurrentPosition();
      return LatLng(location.latitude, location.longitude);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<List<Event>> getEvents() async {
    try {
      final db = FirebaseFirestore.instance;
      final query = await db.collection('events').get();
      final events = query.docs.map((doc) => Event.fromMap(doc)).toList();
      return events;
    } catch (e) {
      return Future.error(e);
    }
  }

  void applyFilters(Map<String, FilterMap> newFilters) {
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
                        markers: Set.from(_nearbyEvents.map((event) {
                          return Marker(
                              markerId: MarkerId(event.id),
                              infoWindow: InfoWindow(title: event.name),
                              icon: BitmapDescriptor.fromBytes(_marker),
                              position: LatLng(event.location.latitude,
                                  event.location.longitude));
                        })),
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
