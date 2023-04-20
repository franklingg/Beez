import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_icons.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/models/filter_map_model.dart';
import 'package:beez/presentation/feed/feed_screen.dart';
import 'package:beez/presentation/map/map_filters_widget.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/hexagon_widget.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:beez/services/event_service.dart';
import 'package:beez/services/user_service.dart';
import 'package:beez/utils/images_util.dart';
import 'package:beez/utils/map_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Map<String, FilterMap> currentFilters = {};
  List<EventModel> _nearbyEvents = [];
  late Uint8List _marker;

  @override
  void initState() {
    super.initState();
    UserService.getUserCurrentLocation().then((currentLocation) {
      setState(() {
        _userLocation =
            LatLng(currentLocation.latitude, currentLocation.longitude);
      });
    }).whenComplete(() async {
      final markerData =
          await ImagesUtil.getBytesFromAsset(AppIcons.marker, 60);
      final events = await EventService.getEvents();
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

  void saveFilters(Map<String, FilterMap> newFilters) {
    setState(() {
      currentFilters = newFilters;
    });
  }

  List<EventModel> get filteredEvents {
    List<EventModel> shownEvents = [..._nearbyEvents];
    for (final key in currentFilters.keys) {
      shownEvents = currentFilters[key]!.filter(shownEvents);
    }
    return shownEvents;
  }

  Future openFilter() {
    return showDialog(
        context: context,
        builder: (dialogCtx) =>
            MapFilters(userFilters: currentFilters, onSave: saveFilters));
  }

  // TODO: ADD INFO WINDOW AND TEXT TO MARKER
  @override
  Widget build(BuildContext context) {
    final initialPosition = CameraPosition(
        target: _userLocation ?? const LatLng(-12.508085, -45.065073),
        zoom: _userLocation == null ? 4 : 15);
    return SafeArea(
        child: Loading(
            isLoading: isLoading,
            child: Scaffold(
                body: Stack(
                  children: [
                    GoogleMap(
                        markers: Set.from(filteredEvents.map((event) {
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
                    Positioned(
                      right: 5,
                      bottom: 20,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        GestureDetector(
                            onTap: () {
                              if (UserService.currentUser == null) {
                                AppAlerts.login(alertContext: context);
                              } else {
                                GoRouter.of(context).pushNamed(FeedScreen.name);
                              }
                            },
                            child: const Hexagon(
                                child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.add_rounded,
                                  size: 30, color: AppColors.black),
                            )))
                      ]),
                    )
                  ],
                ),
                bottomNavigationBar: const TabNavigation())));
  }
}
