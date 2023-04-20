import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:beez/presentation/shared/profile_item_widget.dart';
import 'package:beez/presentation/shared/top_bar_widget.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:beez/services/event_service.dart';
import 'package:beez/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventScreen extends StatefulWidget {
  static const String name = 'event';
  final String? id;
  const EventScreen({super.key, this.id});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  bool isLoading = true;
  late EventModel _event;
  final CarouselController _controller = CarouselController();
  int _carouselCurrentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      EventService.getEvent(widget.id!).then((event) {
        setState(() {
          _event = event;
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Loading(
        isLoading: isLoading,
        child: Consumer<UserProvider>(builder: (_, userProvider, __) {
          return Scaffold(
            body: Column(children: [
              SizedBox(
                height: 230,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CarouselSlider(
                        carouselController: _controller,
                        options: CarouselOptions(
                            onPageChanged: (index, reason) {
                              setState(() {
                                _carouselCurrentIndex = index;
                              });
                            },
                            enableInfiniteScroll: false,
                            padEnds: false,
                            viewportFraction: 1),
                        items: _event.photos
                            .map((url) => SizedBox(
                                  height: 200,
                                  child: Image(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(url),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    TopBar(),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: AppColors.white),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List<Widget>.generate(
                              _event.photos.length,
                              (index) => SizedBox(
                                  height: 12,
                                  width: 30,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                          backgroundColor:
                                              _carouselCurrentIndex == index
                                                  ? AppColors.darkYellow
                                                  : AppColors.black),
                                      onPressed: () {
                                        _controller.animateToPage(index);
                                      },
                                      child: const Text(""))),
                            )),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 12, left: 15, right: 15),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(_event.name,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                              text:
                                  "${DateFormat("dd/MM/yyyy").format(_event.date.toDate())} - ${_event.date.toDate().hour}h - ",
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                    text: _event.isFree
                                        ? "Gratuito"
                                        : "Evento Pago",
                                    style: TextStyle(
                                        color: _event.isFree
                                            ? AppColors.green
                                            : AppColors.blue))
                              ]),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _event.description,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _event.address,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 7),
                        Row(children: [
                          GestureDetector(
                            onTap: () {
                              // TODO: CURRENT USER LIKE
                              if (UserService.currentUser == null)
                                AppAlerts.login(alertContext: context);
                            },
                            // TODO: Verify currentUser liked
                            child: false
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                        Icon(
                                          Icons.person_pin_circle_rounded,
                                          size: 30,
                                          color: AppColors.darkYellow,
                                        ),
                                        Text("Tenho Interesse",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.darkYellow))
                                      ])
                                : Row(children: const [
                                    Icon(
                                      Icons.person_pin_circle_outlined,
                                      size: 30,
                                      color: AppColors.darkYellow,
                                    ),
                                    Text(
                                      "Tenho Interesse",
                                      style: TextStyle(
                                          fontSize: 14, color: AppColors.black),
                                    )
                                  ]),
                          ),
                          Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  // TODO: DEEP LINK SHARE
                                },
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.ios_share_outlined,
                                        size: 23,
                                        color: AppColors.black,
                                      ),
                                      Text(
                                        "Compartilhar",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.black),
                                      )
                                    ])),
                          )
                        ]),
                        const SizedBox(height: 10),
                        Text("Lista de Interessados",
                            style: Theme.of(context).textTheme.displayMedium),
                        const SizedBox(height: 7),
                        SizedBox(
                          height: 75,
                          child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisExtent: 40,
                                mainAxisSpacing: 10,
                                crossAxisCount: 2,
                              ),
                              itemCount: _event.interested.length,
                              itemBuilder: (context, index) {
                                return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ProfileItem(
                                          user: userProvider.getUser(
                                              _event.interested[index]))
                                    ]);
                              }),
                        )
                      ]))
            ]),
            bottomNavigationBar: const TabNavigation(),
          );
        }),
      ),
    );
  }
}
