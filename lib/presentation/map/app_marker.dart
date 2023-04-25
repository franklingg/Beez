import 'dart:typed_data';

import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/presentation/event/event_screen.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class AppMarker {
  static Marker element(EventModel event, Uint8List? marker,
      CustomInfoWindowController infoController, BuildContext context) {
    final markerPosition =
        LatLng(event.location.latitude, event.location.longitude);
    return Marker(
        markerId: MarkerId(event.id),
        icon: marker == null
            ? BitmapDescriptor.defaultMarker
            : BitmapDescriptor.fromBytes(marker),
        position: markerPosition,
        onTap: () {
          infoController.addInfoWindow!(
            Container(
              padding: const EdgeInsets.only(top: 2, bottom: 2, left: 6),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: Offset(-2, 3))
                  ]),
              child: GestureDetector(
                onTap: () {
                  GoRouter.of(context).pushNamed(EventScreen.name,
                      queryParams: {'id': event.id});
                },
                child: Column(
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Text(
                            event.name,
                            maxLines: 2,
                            style: const TextStyle(
                                color: AppColors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          )),
                          GestureDetector(
                            onTap: () {
                              infoController.hideInfoWindow!();
                            },
                            child: const Icon(Icons.close_rounded,
                                size: 16, color: AppColors.mediumGrey),
                          )
                        ]),
                    const SizedBox(height: 3),
                    Row(children: [
                      Text(
                          "${DateFormat("d/M - H").format(event.date.toDate())}h",
                          style: const TextStyle(
                              color: AppColors.brown, fontSize: 12)),
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_pin_circle_outlined,
                              color: AppColors.darkYellow, size: 17),
                          Text("${event.interested.length}",
                              style: const TextStyle(
                                  color: AppColors.darkYellow,
                                  fontSize: 12,
                                  height: 1.2))
                        ],
                      ))
                    ]),
                    const SizedBox(height: 5),
                    Row(
                        children: event.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.grey),
                        child: Text(tag, style: const TextStyle(fontSize: 11)),
                      );
                    }).toList())
                  ],
                ),
              ),
            ),
            markerPosition,
          );
        });
  }

  static CustomInfoWindow infoWindow(
      CustomInfoWindowController infoController) {
    return CustomInfoWindow(
      controller: infoController,
      height: 85,
      width: 120,
      offset: 40,
    );
  }
}
