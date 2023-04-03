import 'dart:io';

import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_images.dart';
import 'package:beez/models/filter_map_model.dart';
import 'package:beez/models/user_model.dart';
import 'package:beez/presentation/map/filter_item/bool_filter_item.dart';
import 'package:beez/presentation/map/filter_item/interest_filter_item.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/profile/profile_screen.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/app_field_widget.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:beez/presentation/shared/top_bar_widget.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:beez/services/user_service.dart';
import 'package:beez/utils/extensions.dart';
import 'package:beez/utils/images_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  static const String name = 'edit_profile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  bool _visiblePassword = false;
  bool processingForm = false;
  final TextEditingController _birthTextController = TextEditingController();
  CountryCode currentCountryCode = CountryCode.fromDialCode('+55');
  String? currentPassword;
  UserModel? currentUser;
  MultiImage? currentPhoto;
  String? originalPhone;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      currentUser = provider.getUser(provider.currentUserId!).copyWith();
      currentPhoto = currentUser!.profilePic.isNotEmpty
          ? MultiImage(
              source: MultiImageSource.NETWORK, url: currentUser!.profilePic)
          : null;
      _birthTextController.text =
          DateFormat('dd/MM/yyyy').format(currentUser!.birthDate.toDate());
      originalPhone = currentUser!.phone;
    });
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        processingForm = true;
      });
      _formKey.currentState!.save();
      UserService.uploadUserPhoto(currentPhoto).then((photoUrl) async {
        setState(() {
          currentUser = currentUser!.copyWith(profilePic: photoUrl);
        });

        return UserService.updateUser(
            currentUser!, currentPassword, currentUser!.phone != originalPhone);
      }).whenComplete(() {
        setState(() {
          processingForm = false;
        });
      }).then((updatedUser) {
        GoRouter.of(context)
            .pushNamed(ProfileScreen.name, queryParams: {'id': updatedUser.id});
      }).onError((String errorMsg, _) {
        AppAlerts.error(alertContext: context, errorMessage: errorMsg);
      });
    }
  }

  Future getNewPhoto() async {
    var img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        currentPhoto = MultiImage(source: MultiImageSource.UPLOAD, file: img);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Loading(
      isLoading: processingForm,
      child: Scaffold(
        appBar: TopBar(),
        body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Form(
                key: _formKey,
                child: currentUser != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                            Text("Configurações de Perfil",
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.black,
                                  radius: 56,
                                  child: CircleAvatar(
                                    backgroundImage: currentPhoto != null
                                        ? currentPhoto!.source ==
                                                MultiImageSource.NETWORK
                                            ? NetworkImage(currentPhoto!.url!)
                                            : Image.file(File(
                                                    currentPhoto!.file!.path))
                                                .image
                                        : AssetImage(
                                            AppImages.placeholderWhite),
                                    radius: 55,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextButton(
                                          style: const ButtonStyle(
                                              padding: MaterialStatePropertyAll(
                                                  EdgeInsets.zero)),
                                          onPressed: getNewPhoto,
                                          child: Row(children: const [
                                            Icon(Icons.edit_square,
                                                color: AppColors.blue,
                                                size: 17),
                                            SizedBox(width: 3),
                                            Text(
                                              "Editar Foto de Perfil",
                                              style: TextStyle(
                                                  color: AppColors.blue,
                                                  fontSize: 12),
                                            )
                                          ])),
                                      TextButton(
                                          style: const ButtonStyle(
                                              padding: MaterialStatePropertyAll(
                                                  EdgeInsets.zero)),
                                          onPressed: () {
                                            setState(() {
                                              currentPhoto = null;
                                            });
                                          },
                                          child: Row(children: const [
                                            Icon(Icons.cancel_outlined,
                                                color: AppColors.error,
                                                size: 17),
                                            SizedBox(width: 3),
                                            Text(
                                              "Remover Foto de Perfil",
                                              style: TextStyle(
                                                  color: AppColors.error,
                                                  fontSize: 12),
                                            )
                                          ]))
                                    ])
                              ],
                            ),
                            const SizedBox(height: 10),
                            AppField(
                                label: "Nome",
                                child: TextFormField(
                                  initialValue: currentUser!.name,
                                  onSaved: (value) => setState(() {
                                    currentUser =
                                        currentUser!.copyWith(name: value);
                                  }),
                                  decoration: AppField.inputDecoration(
                                      hint: "Nome Completo"),
                                  validator: (value) => value!.validName(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .merge(const TextStyle(
                                          decoration: TextDecoration.none)),
                                )),
                            const SizedBox(height: 10),
                            AppField(
                                label: "E-mail",
                                child: TextFormField(
                                  initialValue: currentUser!.email,
                                  onSaved: (value) => setState(() {
                                    currentUser =
                                        currentUser!.copyWith(email: value);
                                  }),
                                  decoration: AppField.inputDecoration(
                                      hint: "exemplo@exemplo.com"),
                                  validator: (value) => value!.validEmail(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .merge(const TextStyle(
                                          decoration: TextDecoration.none)),
                                )),
                            const SizedBox(height: 10),
                            AppField(
                                label: "Data de Nascimento",
                                child: Row(children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _birthTextController,
                                      readOnly: true,
                                      style: const TextStyle(
                                          color: AppColors.brown, fontSize: 14),
                                      decoration: AppField.inputDecoration(
                                          hint: "dd/mm/aaaa"),
                                      onTap: () {
                                        AppAlerts.datePicker(
                                            alertContext: context,
                                            initialDate:
                                                currentUser!.birthDate.toDate(),
                                            onChangedDate: (newDate) {
                                              setState(() {
                                                _birthTextController.text =
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(newDate);
                                                currentUser = currentUser!
                                                    .copyWith(
                                                        birthDate:
                                                            Timestamp.fromDate(
                                                                newDate));
                                              });
                                            },
                                            futureDates: false);
                                      },
                                    ),
                                  ),
                                  const Icon(Icons.calendar_month_outlined,
                                      color: AppColors.darkYellow, size: 25)
                                ])),
                            const SizedBox(height: 10),
                            AppField(
                                label: "Telefone",
                                child: Row(
                                  children: [
                                    CountryCodePicker(
                                      initialSelection: '+55',
                                      padding: EdgeInsets.zero,
                                      comparator: (a, b) {
                                        final c1 =
                                            a.dialCode?.replaceFirst(r'+', '');
                                        final c2 =
                                            b.dialCode?.replaceFirst(r'+', '');
                                        return int.parse(c1!) - int.parse(c2!);
                                      },
                                      textStyle: const TextStyle(
                                          fontSize: 15, color: AppColors.black),
                                      flagWidth: 30,
                                      flagDecoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      onChanged: (newValue) {
                                        currentCountryCode = newValue;
                                      },
                                    ),
                                    Container(
                                      width: 10,
                                      height: 48,
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              left: BorderSide(
                                                  width: 1,
                                                  color: AppColors.shadow))),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue:
                                            currentUser!.phone.substring(4),
                                        onSaved: (value) {
                                          setState(() {
                                            if (value != null) {
                                              currentUser = currentUser!.copyWith(
                                                  phone:
                                                      "${currentCountryCode.dialCode} $value");
                                            }
                                          });
                                        },
                                        autocorrect: false,
                                        inputFormatters: [
                                          MaskedInputFormatter(
                                              '(##) #####-####')
                                        ],
                                        validator: (value) =>
                                            value!.validPhone(),
                                        keyboardType: TextInputType.phone,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .merge(const TextStyle(
                                                decoration:
                                                    TextDecoration.none)),
                                        decoration: AppField.inputDecoration(
                                            hint: "(XX) XXXXX-XXXX"),
                                      ),
                                    )
                                  ],
                                )),
                            const SizedBox(height: 10),
                            AppField(
                                label: "Nova Senha",
                                child: TextFormField(
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return value.validPassword();
                                    }
                                    return null;
                                  },
                                  onChanged: (value) => setState(() {
                                    currentPassword = value;
                                  }),
                                  decoration: AppField.inputDecoration(
                                      hint: "Senha",
                                      suffix: IconButton(
                                        icon: Icon(
                                          _visiblePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          size: 20,
                                          color: AppColors.black,
                                        ),
                                        padding: EdgeInsets.zero,
                                        onPressed: () => setState(() {
                                          _visiblePassword = !_visiblePassword;
                                        }),
                                      )),
                                  obscureText: !_visiblePassword,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .merge(const TextStyle(
                                          decoration: TextDecoration.none)),
                                )),
                            const SizedBox(height: 10),
                            const Text("Tags/Interesses"),
                            const SizedBox(height: 15),
                            InterestFilterItem(
                                interestFilter:
                                    MultiSelectFilter(title: "Interesses")
                                      ..currentValue = currentUser!.interests,
                                itemSize: 13,
                                onChanged: (newTags) {
                                  setState(() {
                                    currentUser = currentUser!.copyWith(
                                        interests: newTags
                                            .whereType<String>()
                                            .toList());
                                  });
                                }),
                            const SizedBox(height: 15),
                            const Text("Preferências da Conta"),
                            const SizedBox(height: 15),
                            BoolFilterItem(
                                boolFilter: BooleanFilter(
                                    title: "",
                                    label:
                                        "Mostrar eventos de meu interesse para todos")
                                  ..currentValue = currentUser!.showEventsAll,
                                labelSize: 13,
                                onChanged: () {
                                  setState(() {
                                    currentUser = currentUser!.copyWith(
                                        showEventsAll:
                                            !currentUser!.showEventsAll);
                                  });
                                }),
                            const SizedBox(height: 20),
                            BoolFilterItem(
                                boolFilter: BooleanFilter(
                                    title: "",
                                    label:
                                        "Mostrar eventos de meu interesse para quem me segue")
                                  ..currentValue = currentUser!.showEventsAll,
                                labelSize: 13,
                                onChanged: () {
                                  setState(() {
                                    currentUser = currentUser!.copyWith(
                                        showEventsAll:
                                            !currentUser!.showEventsAll);
                                  });
                                }),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                      onPressed: submitForm,
                                      style: const ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                AppColors.darkYellow),
                                      ),
                                      child: const Text(
                                        "Salvar Alterações",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        GoRouter.of(context).pop();
                                      },
                                      style: const ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                AppColors.lightGrey),
                                      ),
                                      child: const Text(
                                        "Cancelar",
                                        style:
                                            TextStyle(color: AppColors.brown),
                                      )),
                                )
                              ],
                            )
                          ])
                    : const SizedBox())),
        bottomNavigationBar: const TabNavigation(),
      ),
    ));
  }
}
