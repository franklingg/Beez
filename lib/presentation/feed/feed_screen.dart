import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/presentation/event/create_event_screen.dart';
import 'package:beez/presentation/feed/feed_card_widget.dart';
import 'package:beez/presentation/feed/order_feed_widget.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:beez/presentation/shared/top_bar_widget.dart';
import 'package:beez/presentation/shared/hexagon_widget.dart';
import 'package:beez/providers/event_provider.dart';
import 'package:beez/providers/notification_provider.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:beez/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  static const name = "feed";
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool isLoading = true;
  Position? userLocation;
  OrderOption? order;

  @override
  void initState() {
    super.initState();
    // TODO: Test
    Provider.of<NotificationProvider>(context, listen: false).debug(
        Provider.of<EventProvider>(context, listen: false).nextEvents[0]);
    UserService.getUserCurrentLocation().then((location) {
      setState(() {
        Provider.of<EventProvider>(context, listen: false).addListener(() {
          setState(() {});
        });
        Provider.of<UserProvider>(context, listen: false).addListener(() {
          setState(() {});
        });
        userLocation = location;
        isLoading = false;
      });
    });
  }

  List<EventModel> reorderEvents(
      List<EventModel> events, List<String> following) {
    List<EventModel> reorderedEvents = [...events];
    if (order == OrderOption.NEAREST_DISTANT ||
        order == OrderOption.FARTHEST_DISTANT) {
      reorderedEvents.sort((e1, e2) => Geolocator.distanceBetween(
              e1.location.latitude,
              e1.location.longitude,
              e2.location.latitude,
              e2.location.longitude)
          .toInt());
      if (order == OrderOption.NEAREST_DISTANT) {
        reorderedEvents = [...reorderedEvents.reversed];
      }
    } else if (order == OrderOption.CLOSEST_DATE ||
        order == OrderOption.FURTHEST_DATE) {
      reorderedEvents.sort((e1, e2) => e1.date.compareTo(e2.date));
      if (order == OrderOption.FURTHEST_DATE) {
        reorderedEvents = [...reorderedEvents.reversed];
      }
    } else if (order == OrderOption.LESS_COMMON_FOLLOWERS ||
        order == OrderOption.MORE_COMMON_FOLLOWERS) {
      reorderedEvents.sort((e1, e2) =>
          following.toSet().intersection(e1.interested.toSet()).length -
          following.toSet().intersection(e2.interested.toSet()).length);
      if (order == OrderOption.MORE_COMMON_FOLLOWERS) {
        reorderedEvents.sort((e1, e2) =>
            following.toSet().intersection(e2.interested.toSet()).length -
            following.toSet().intersection(e1.interested.toSet()).length);
      }
    }
    return reorderedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Loading(
        isLoading: isLoading,
        child: Consumer<UserProvider>(
            builder: (_, userProvider, __) => Scaffold(
                  appBar: TopBar(
                      customAction: OrderFeed(
                          selectedOption: order,
                          showFollowersOption:
                              userProvider.currentUserId != null,
                          changeOrder: (newOrder) {
                            setState(() {
                              order = newOrder;
                            });
                          })),
                  body: Stack(
                    children: [
                      Consumer<EventProvider>(builder: (_, eventProvider, __) {
                        List<String> userFollowers =
                            userProvider.currentUserId != null
                                ? userProvider.allUsers
                                    .where((user) => user.followers
                                        .contains(userProvider.currentUserId))
                                    .map((user) => user.id)
                                    .toList()
                                : [];
                        final shownEvents = reorderEvents(
                            eventProvider.nextEvents, userFollowers);
                        return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            itemCount: shownEvents.length,
                            itemBuilder: ((context, index) {
                              final eventData = shownEvents[index];
                              double? distanceUserEvent;
                              if (userLocation != null) {
                                distanceUserEvent = Geolocator.distanceBetween(
                                        userLocation!.latitude,
                                        userLocation!.longitude,
                                        eventData.location.latitude,
                                        eventData.location.longitude) /
                                    1000;
                              }
                              return FeedCard(
                                data: eventData,
                                distanceFromUser: distanceUserEvent,
                              );
                            }));
                      }),
                      Positioned(
                        right: 5,
                        bottom: 20,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          GestureDetector(
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
                        ]),
                      )
                    ],
                  ),
                  bottomNavigationBar: const TabNavigation(),
                )),
      ),
    );
  }
}
