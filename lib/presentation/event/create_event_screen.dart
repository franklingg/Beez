import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/models/filter_map_model.dart';
import 'package:beez/presentation/event/event_photos_widget.dart';
import 'package:beez/presentation/event/event_screen.dart';
import 'package:beez/presentation/map/filter_item/bool_filter_item.dart';
import 'package:beez/presentation/map/filter_item/interest_filter_item.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/app_field_widget.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:beez/presentation/shared/top_bar_widget.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:beez/services/event_service.dart';
import 'package:beez/utils/images_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:go_router/go_router.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';

class CreateEventScreen extends StatefulWidget {
  static const String name = 'create_event';
  final EventModel? existingEvent;
  const CreateEventScreen({super.key, this.existingEvent});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool processingForm = false;
  List<MultiImage?> currentPhotos = List.filled(4, null, growable: false);
  String currentTitle = "";
  String currentDescription = "";
  DateTime? currentDate;
  TimeOfDay? currentTime;
  PlaceDetails? currentAddress;
  bool isFree = false;
  List<String> currentInterests = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingEvent != null) {
      setState(() {
        currentTitle = widget.existingEvent!.name;
        currentDescription = widget.existingEvent!.description;
        currentDate = widget.existingEvent!.date.toDate();
        currentTime =
            TimeOfDay.fromDateTime(widget.existingEvent!.date.toDate());
        isFree = widget.existingEvent!.isFree;
        currentInterests = widget.existingEvent!.tags;
        widget.existingEvent!.photos.forEachIndexed((idx, photoUrl) {
          currentPhotos[idx] =
              MultiImage(source: MultiImageSource.NETWORK, url: photoUrl);
        });
      });
    }
    _dateController.text = currentDate != null
        ? DateFormat('dd/MM/yyyy').format(currentDate!)
        : '';
    final formatter = NumberFormat("00");
    _timeController.text = currentTime != null
        ? "${formatter.format(currentTime!.hour)}:${formatter.format(currentTime!.minute)}"
        : '';
    _addressController.text = widget.existingEvent?.address != null
        ? widget.existingEvent!.address
        : '';
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        processingForm = true;
      });
      _formKey.currentState!.save();
      EventService.uploadPhotos(currentPhotos).then((uploadedPhotos) {
        if (widget.existingEvent != null) {
          return editEvent(uploadedPhotos);
        } else {
          return createEvent(uploadedPhotos);
        }
      }).then((event) {
        setState(() {
          processingForm = false;
        });
        GoRouter.of(context)
            .pushReplacement("/${EventScreen.name}?id=${event.id}");
      }).onError((String error, _) {
        AppAlerts.error(alertContext: context, errorMessage: error);
      });
    }
  }

  Future<EventModel> editEvent(List<String> uploadedPhotos) {
    final fullDate = currentDate!
        .add(Duration(hours: currentTime!.hour, minutes: currentTime!.minute));
    final updatedEvent = widget.existingEvent!.copyWith(
        date: Timestamp.fromDate(fullDate),
        address: currentAddress!.formattedAddress!,
        location: GeoPoint(currentAddress!.geometry!.location.lat,
            currentAddress!.geometry!.location.lng),
        description: currentDescription,
        isFree: isFree,
        name: currentTitle,
        photos: uploadedPhotos,
        tags: currentInterests);
    return EventService.updateEvent(updatedEvent);
  }

  Future<EventModel> createEvent(List<String> uploadedPhotos) {
    final fullDate = currentDate!
        .add(Duration(hours: currentTime!.hour, minutes: currentTime!.minute));
    final creatorId =
        Provider.of<UserProvider>(context, listen: false).currentUserId;
    final newEvent = EventModel(
        id: 'not_set',
        creator: creatorId!,
        date: Timestamp.fromDate(fullDate),
        name: currentTitle,
        description: currentDescription,
        interested: [],
        location: GeoPoint(currentAddress!.geometry!.location.lat,
            currentAddress!.geometry!.location.lng),
        address: currentAddress!.formattedAddress!,
        photos: uploadedPhotos,
        tags: currentInterests,
        isFree: isFree);
    return EventService.createEvent(newEvent);
  }

  void clearForm() {
    _formKey.currentState!.reset();
    setState(() {
      currentDate = null;
      currentTime = null;
      _dateController.text = '';
      _timeController.text = '';
      isFree = false;
      currentInterests = [];
    });
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
            child: Consumer<UserProvider>(
                builder: (_, userProvider, __) => Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                              widget.existingEvent == null
                                  ? "Cadastrar novo evento"
                                  : "Editar evento",
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 15),
                          EventPhotos(
                              photos: currentPhotos,
                              onChanged: (newPhotos) {
                                setState(() {
                                  currentPhotos = newPhotos;
                                });
                              }),
                          const SizedBox(height: 15),
                          AppField(
                            label: "Título",
                            child: TextFormField(
                                onSaved: (value) => setState(() {
                                      currentTitle = value ?? currentTitle;
                                    }),
                                initialValue: currentTitle,
                                decoration: AppField.inputDecoration(
                                    hint: "Meu evento"),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Não deve ser vazio";
                                  }
                                  return null;
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .merge(const TextStyle(
                                        decoration: TextDecoration.none))),
                          ),
                          const SizedBox(height: 10),
                          AppField(
                            label: "Descrição",
                            child: TextFormField(
                                minLines: 4,
                                maxLines: null,
                                initialValue: currentDescription,
                                keyboardType: TextInputType.multiline,
                                onSaved: (value) => setState(() {
                                      currentDescription =
                                          value ?? currentDescription;
                                    }),
                                decoration: AppField.inputDecoration(
                                        hint: "Descritor do evento")
                                    .copyWith(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 9)),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .merge(const TextStyle(
                                        decoration: TextDecoration.none))),
                          ),
                          const SizedBox(height: 10),
                          const Text("Data e horário"),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                  child: AppField(
                                      child: TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                validator: (value) {
                                  if (currentDate == null) {
                                    return "Obrigatório.";
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                    color: AppColors.brown, fontSize: 14),
                                decoration: AppField.inputDecoration(
                                    hint: "dd/mm/aaaa",
                                    suffix: const Icon(
                                        Icons.calendar_month_outlined,
                                        color: AppColors.darkYellow,
                                        size: 22)),
                                onTap: () {
                                  AppAlerts.datePicker(
                                      alertContext: context,
                                      initialDate: currentDate,
                                      onChangedDate: (newDate) {
                                        setState(() {
                                          _dateController.text =
                                              DateFormat('dd/MM/yyyy')
                                                  .format(newDate);
                                          currentDate = newDate;
                                        });
                                      });
                                },
                              ))),
                              const SizedBox(width: 15),
                              Expanded(
                                child: AppField(
                                  child: TextFormField(
                                      controller: _timeController,
                                      readOnly: true,
                                      validator: (value) {
                                        if (currentTime == null) {
                                          return "Obrigatório.";
                                        }
                                        return null;
                                      },
                                      style: const TextStyle(
                                          color: AppColors.brown, fontSize: 14),
                                      decoration: AppField.inputDecoration(
                                          hint: "hh:mm",
                                          suffix: const Icon(
                                              Icons.access_time_rounded,
                                              color: AppColors.darkYellow,
                                              size: 22)),
                                      onTap: () {
                                        final formatter = NumberFormat("00");
                                        AppAlerts.timePicker(
                                            alertContext: context,
                                            initialTime: currentTime,
                                            onChangedTime: (newTime) {
                                              setState(() {
                                                _timeController.text =
                                                    "${formatter.format(newTime.hour)}:${formatter.format(newTime.minute)}";
                                                currentTime = newTime;
                                              });
                                            });
                                      }),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          AppField(
                            label: "Endereço",
                            child: GestureDetector(
                              onTap: () async {
                                var place = await PlacesAutocomplete.show(
                                    context: context,
                                    apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
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
                                    apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
                                    apiHeaders: await const GoogleApiHeaders()
                                        .getHeaders(),
                                  );
                                  String placeid = place.placeId ?? "0";
                                  final detail =
                                      await plist.getDetailsByPlaceId(placeid,
                                          language: 'pt-BR');
                                  setState(() {
                                    currentAddress = detail.result;
                                    _addressController.text =
                                        currentAddress!.formattedAddress!;
                                  });
                                }
                              },
                              child: TextFormField(
                                controller: _addressController,
                                enabled: false,
                                decoration: AppField.inputDecoration(
                                    hint: "Rua Tal, 00"),
                                validator: (value) {
                                  if (currentAddress == null ||
                                      widget.existingEvent?.address != null) {
                                    return "Obrigatório.";
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text("Gratuidade"),
                          const SizedBox(height: 10),
                          BoolFilterItem(
                              boolFilter: BooleanFilter(
                                  title: "Gratuidade",
                                  label:
                                      "Evento Gratuito (Não necessita de ingresso/entrada)")
                                ..currentValue = isFree,
                              labelSize: 13,
                              onChanged: () {
                                setState(() {
                                  isFree = !isFree;
                                });
                              }),
                          const SizedBox(height: 15),
                          const Text("Tags/Interesses"),
                          const SizedBox(height: 8),
                          InterestFilterItem(
                              interestFilter:
                                  MultiSelectFilter(title: "Interesses")
                                    ..currentValue = currentInterests,
                              onChanged: (newTags) {
                                setState(() {
                                  currentInterests =
                                      newTags.whereType<String>().toList();
                                });
                              }),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    onPressed: submitForm,
                                    style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          AppColors.darkYellow),
                                    ),
                                    child: const Text(
                                      "Salvar",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: ElevatedButton(
                                    onPressed: clearForm,
                                    style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          AppColors.lightGrey),
                                    ),
                                    child: const Text(
                                      "Limpar",
                                      style: TextStyle(color: AppColors.brown),
                                    )),
                              )
                            ],
                          )
                        ])))),
        bottomNavigationBar: const TabNavigation(),
      ),
    ));
  }
}
