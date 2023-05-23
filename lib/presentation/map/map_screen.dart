import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_icons.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/models/filter_map_model.dart';
import 'package:beez/presentation/event/create_event_screen.dart';
import 'package:beez/presentation/event/event_screen.dart';
import 'package:beez/presentation/map/app_marker.dart';
import 'package:beez/presentation/map/map_filters_widget.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/hexagon_widget.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:beez/providers/event_provider.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:beez/services/notification_service.dart';
import 'package:beez/services/user_service.dart';
import 'package:beez/utils/images_util.dart';
import 'package:beez/utils/map_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:custom_info_window/custom_info_window.dart';

LatLng defaultPosition = const LatLng(-12.508085, -45.065073);

class MapScreen extends StatefulWidget {
  static const name = "map";
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final CustomInfoWindowController _infoWindowController =
      CustomInfoWindowController();
  bool isLoading = true;
  LatLng? _userGps;
  LatLng _userLocation = defaultPosition;
  Map<String, FilterMap> currentFilters = {};
  Map<EventModel, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    UserService.getUserCurrentLocation()
        .then((currentLocation) {
          setState(() {
            _userGps =
                LatLng(currentLocation.latitude, currentLocation.longitude);
            _userLocation =
                LatLng(currentLocation.latitude, currentLocation.longitude);
          });
        })
        .catchError((e) {})
        .whenComplete(() async {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          setState(() {
            currentFilters['distance'] =
                RangeFilter(title: "Distância", currentPosition: _userLocation);
            if (userProvider.currentUserId != null) {
              currentFilters['interest'] = MultiSelectFilter(
                  title: "Interesses")
                ..currentValue =
                    userProvider.getUser(userProvider.currentUserId!).interests;
            }
          });
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            final eventProvider =
                Provider.of<EventProvider>(context, listen: false);
            Future.wait(eventProvider.nextEvents.map((event) async =>
                await ImagesUtil.getMarkerBytesEvent(
                    AppIcons.marker, 60, event))).then((markerBytes) {
              setState(() {
                _markers = Map.fromEntries(markerBytes.map((m) => MapEntry(
                    m.key,
                    AppMarker.element(
                        m.key, m.value, _infoWindowController, context))));
                isLoading = false;
              });
            });
            eventProvider.addListener(() {
              setState(() {});
            });
          });
        });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController.setMapStyle(MapStyle.data);
    _infoWindowController.googleMapController = controller;
  }

  void changeUserLocation(Location? newLocation) {
    if (newLocation != null) {
      setState(() {
        _userLocation = LatLng(newLocation.lat, newLocation.lng);
        currentFilters['distance'] = (currentFilters['distance'] as RangeFilter)
            .copyNewLoc(_userLocation);
      });
      var newlatlang = LatLng(_userLocation.latitude, _userLocation.longitude);
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: newlatlang, zoom: 15)));
    }
  }

  Set<Marker> filteredMarkers() {
    Map<EventModel, Marker> shownMarkers =
        Map.from(_markers.map((key, value) => MapEntry(key, value)));
    for (final key in currentFilters.keys) {
      final remainingEvents =
          currentFilters[key]!.filter(shownMarkers.keys.toList());
      shownMarkers
          .removeWhere((event, marker) => !remainingEvents.contains(event));
    }
    Set<Marker> markers = shownMarkers.values.toSet();
    if (_userLocation != _userGps) {
      markers.add(Marker(
          markerId: const MarkerId('location'),
          onTap: () {
            setState(() {
              _userLocation = _userGps != null
                  ? LatLng(_userGps!.latitude, _userGps!.longitude)
                  : defaultPosition;
              currentFilters['distance'] =
                  (currentFilters['distance'] as RangeFilter)
                      .copyNewLoc(_userLocation);
            });
          },
          position: LatLng(_userLocation.latitude, _userLocation.longitude)));
    }
    return markers;
  }

  Future openFilter() {
    return showDialog(
      context: context,
      builder: (dialogCtx) => MapFilters(
          userFilters: currentFilters,
          onSave: (newFilters) {
            setState(() {
              currentFilters = newFilters;
            });
          },
          userLocation: _userLocation),
    );
  }

  @override
  void dispose() {
    _infoWindowController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = CameraPosition(
        target: _userLocation, zoom: _userLocation == defaultPosition ? 4 : 15);
    return SafeArea(
        child: Loading(
            isLoading: isLoading,
            child: Scaffold(
                body: Stack(
                  children: [
                    GoogleMap(
                        markers: filteredMarkers(),
                        onMapCreated: _onMapCreated,
                        onTap: (position) {
                          _infoWindowController.hideInfoWindow!();
                          changeUserLocation(Location(
                              lat: position.latitude, lng: position.longitude));
                        },
                        onCameraMove: (position) {
                          _infoWindowController.onCameraMove!();
                        },
                        myLocationButtonEnabled: false,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        initialCameraPosition: initialPosition),
                    AppMarker.infoWindow(_infoWindowController),
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
                              children: [
                                Expanded(
                                    child: TextButton(
                                  onPressed: () async {
                                    var place = await PlacesAutocomplete.show(
                                        context: context,
                                        apiKey:
                                            dotenv.env['GOOGLE_MAPS_API_KEY']!,
                                        mode: Mode.overlay,
                                        types: [],
                                        strictbounds: false,
                                        language: 'pt-BR',
                                        components: [
                                          Component(Component.country, 'br')
                                        ],
                                        onError: (err) {
                                          AppAlerts.error(
                                              alertContext: context,
                                              errorMessage: err.toString());
                                        });

                                    if (place != null) {
                                      final plist = GoogleMapsPlaces(
                                        apiKey:
                                            dotenv.env['GOOGLE_MAPS_API_KEY']!,
                                        apiHeaders:
                                            await const GoogleApiHeaders()
                                                .getHeaders(),
                                      );
                                      String placeid = place.placeId ?? "0";
                                      final detail = await plist
                                          .getDetailsByPlaceId(placeid);

                                      changeUserLocation(
                                          detail.result.geometry?.location);
                                    }
                                  },
                                  child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Pesquisar...",
                                      style: TextStyle(
                                          color: AppColors.mediumGrey),
                                    ),
                                  ),
                                )),
                                const Icon(Icons.search,
                                    color: AppColors.mediumGrey)
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
                              _mapController.animateCamera(
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
                        Consumer<UserProvider>(
                          builder: (_, userProvider, __) => GestureDetector(
                              onTap: () {
                                if (userProvider.currentUserId == null) {
                                  AppAlerts.login(alertContext: context);
                                } else {
                                  GoRouter.of(context)
                                      .pushNamed(CreateEventScreen.name);
                                }
                              },
                              child: const Hexagon(
                                  child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.add_rounded,
                                    size: 30, color: AppColors.black),
                              ))),
                        )
                      ]),
                    )
                  ],
                ),
                bottomNavigationBar: const TabNavigation())));
  }
}
