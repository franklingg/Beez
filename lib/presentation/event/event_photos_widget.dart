import 'dart:io';

import 'package:beez/constants/app_colors.dart';
import 'package:beez/utils/images_util.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:image_picker/image_picker.dart';

class EventPhotos extends StatelessWidget {
  final List<MultiImage?> photos;
  final Function(List<MultiImage?>) onChanged;
  final ImagePicker picker = ImagePicker();

  EventPhotos({super.key, required this.photos, required this.onChanged});

  Future getImage(int idx) async {
    var img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      onChanged(photos
          .mapIndexed<MultiImage?>((photoIdx, photo) => photoIdx == idx
              ? MultiImage(source: MultiImageSource.UPLOAD, file: img)
              : photo)
          .toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 175,
      child: GridView(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisExtent: 80,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          crossAxisCount: 2,
        ),
        children: photos
            .mapIndexed<Widget>((idx, image) => Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.mediumGrey),
                      borderRadius: BorderRadius.circular(5)),
                  child: image == null
                      ? GestureDetector(
                          onTap: () => getImage(idx),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.brown,
                            size: 40,
                          ),
                        )
                      : Stack(children: [
                          image.source == MultiImageSource.NETWORK
                              ? Image.network(
                                  image.url!,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(image.file!.path),
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                          Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                onChanged(photos
                                    .mapIndexed<MultiImage?>(
                                        (photoIdx, photo) =>
                                            photoIdx == idx ? null : photo)
                                    .toList());
                              },
                              child: const CircleAvatar(
                                backgroundColor: AppColors.black,
                                radius: 13,
                                child: Icon(
                                  Icons.delete_forever,
                                  color: AppColors.yellow,
                                  size: 18,
                                ),
                              ),
                            ),
                          )
                        ]),
                ))
            .toList(),
      ),
    );
  }
}
