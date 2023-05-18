import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_images.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/presentation/event/event_screen.dart';
import 'package:beez/presentation/shared/top_bar_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Carousel extends StatefulWidget {
  final bool isMultipleEvent;
  final EventModel? singleEvent;
  final List<EventModel>? multipleEvents;
  const Carousel(
      {super.key,
      required this.isMultipleEvent,
      this.singleEvent,
      this.multipleEvents})
      : assert(isMultipleEvent ? multipleEvents != null : singleEvent != null);

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  final CarouselController _controller = CarouselController();
  int _carouselCurrentIndex = 0;

  Widget carousel(List<String> photoUrls) {
    return CarouselSlider(
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
      items: (photoUrls.isEmpty ? [''] : photoUrls)
          .take(10)
          .map((url) => Container(
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(4)),
                height: 200,
                child: Image(
                  fit: BoxFit.contain,
                  image: url.isEmpty
                      ? AssetImage(AppImages.placeholderWhite) as ImageProvider
                      : NetworkImage(url),
                ),
              ))
          .toList(),
    );
  }

  Widget dots(int photosLength, Color unselectedColor) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List<Widget>.generate(
            photosLength,
            (index) => SizedBox(
                height: 10,
                width: 27,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: _carouselCurrentIndex == index
                            ? AppColors.darkYellow
                            : unselectedColor),
                    onPressed: () {
                      _controller.animateToPage(index);
                    },
                    child: const Text(""))),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMultipleEvent) {
      return SizedBox(
        height: 200,
        child: GestureDetector(
          onTap: () {
            GoRouter.of(context).pushNamed(EventScreen.name, queryParams: {
              'id': widget.multipleEvents![_carouselCurrentIndex].id
            });
          },
          child: Stack(
            children: [
              carousel(widget.multipleEvents!
                  .map(
                      (event) => event.photos.isEmpty ? '' : event.photos.first)
                  .toList()),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 5, bottom: 5, left: 15, right: 25),
                  decoration: const BoxDecoration(
                      color: AppColors.brown,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(5))),
                  child: Row(children: [
                    Expanded(
                        child: Text(
                      widget.multipleEvents![_carouselCurrentIndex].name,
                      style: const TextStyle(
                          color: AppColors.white, fontWeight: FontWeight.bold),
                    )),
                    const Icon(
                      Icons.person_pin_circle_outlined,
                      color: AppColors.yellow,
                      size: 24,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      widget.multipleEvents![_carouselCurrentIndex].interested
                          .length
                          .toString(),
                      style: const TextStyle(
                          height: 1,
                          fontSize: 16,
                          color: AppColors.yellow,
                          fontWeight: FontWeight.w600),
                    )
                  ]),
                ),
              ),
              if (widget.multipleEvents!.length != 1)
                Align(
                    alignment: const Alignment(0, 1.25),
                    child: dots(widget.multipleEvents!.length, AppColors.black))
            ],
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 230,
        child: Stack(
          children: [
            Align(
                alignment: Alignment.bottomCenter,
                child: carousel(widget.singleEvent!.photos)),
            TopBar(),
            if (widget.singleEvent!.photos.length != 1)
              Align(
                  alignment: Alignment.bottomCenter,
                  child:
                      dots(widget.singleEvent!.photos.length, AppColors.white))
          ],
        ),
      );
    }
  }
}
