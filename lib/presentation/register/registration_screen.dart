import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/user_model.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/shared/app_field_widget.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:beez/services/user_service.dart';
import 'package:beez/utils/extensions.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:intl/intl.dart';

class RegistrationScreen extends StatefulWidget {
  static const String name = 'registration';
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _visiblePassword = false;
  bool processingForm = false;
  String currentName = "";
  String currentEmail = "";
  DateTime? currentBirthDate;
  CountryCode? currentCountryCode;
  String currentPhone = "";
  String currentPassword = "";
  String currentPasswordConfirmation = "";

  final TextEditingController _birthTextController = TextEditingController();

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        processingForm = true;
      });
      _formKey.currentState!.save();
      final userData = UserModel.initialize(currentName, currentEmail,
          currentPassword, currentPhone, currentBirthDate!);
      // UserService.registerNewUser(userData)
      //     .whenComplete(() => setState(() {
      //           processingForm = false;
      //         }))
      //     .then((user) {
      //   // GoRouter.of(context).pushNamed(MapScreen.name);
      // }).onError((String errorMsg, _) {
      //   AppAlerts.error(alertContext: context, errorMessage: errorMsg);
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Loading(
        isLoading: processingForm,
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Cadastro de Perfil",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 25),
                  AppField(
                      label: "Nome",
                      child: TextFormField(
                        onSaved: (value) => setState(() {
                          currentName = value ?? currentName;
                        }),
                        decoration:
                            AppField.inputDecoration(hint: "Nome Completo"),
                        validator: (value) => value!.validName(),
                        style: Theme.of(context).textTheme.bodyMedium!.merge(
                            const TextStyle(decoration: TextDecoration.none)),
                      )),
                  const SizedBox(height: 10),
                  AppField(
                      label: "E-mail",
                      child: TextFormField(
                        onSaved: (value) => setState(() {
                          currentEmail = value ?? currentEmail;
                        }),
                        decoration: AppField.inputDecoration(
                            hint: "exemplo@exemplo.com"),
                        validator: (value) => value!.validEmail(),
                        style: Theme.of(context).textTheme.bodyMedium!.merge(
                            const TextStyle(decoration: TextDecoration.none)),
                      )),
                  const SizedBox(height: 10),
                  AppField(
                      label: "Data de Nascimento",
                      child: Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _birthTextController,
                            readOnly: true,
                            validator: (value) {
                              if (currentBirthDate == null)
                                return "Data de Nascimento é obrigatória.";
                            },
                            style: const TextStyle(
                                color: AppColors.brown, fontSize: 14),
                            decoration:
                                AppField.inputDecoration(hint: "dd/mm/aaaa"),
                            onTap: () {
                              AppAlerts.datePicker(
                                  alertContext: context,
                                  initialDate: currentBirthDate,
                                  onChangedDate: (newDate) {
                                    setState(() {
                                      _birthTextController.text =
                                          DateFormat('dd/MM/yyyy')
                                              .format(newDate);
                                      currentBirthDate = newDate;
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
                              final c1 = a.dialCode?.replaceFirst(r'+', '');
                              final c2 = b.dialCode?.replaceFirst(r'+', '');
                              return int.parse(c1!) - int.parse(c2!);
                            },
                            textStyle: const TextStyle(
                                fontSize: 15, color: AppColors.black),
                            flagWidth: 30,
                            flagDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
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
                                        width: 1, color: AppColors.shadow))),
                          ),
                          Expanded(
                            child: TextFormField(
                              onSaved: (value) => setState(() {
                                currentPhone = value ?? currentPhone;
                              }),
                              autocorrect: false,
                              inputFormatters: [
                                MaskedInputFormatter('(##) #####-####')
                              ],
                              validator: (value) => value!.validPhone(),
                              keyboardType: TextInputType.phone,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .merge(const TextStyle(
                                      decoration: TextDecoration.none)),
                              decoration: AppField.inputDecoration(
                                  hint: "(XX) XXXXX-XXXX"),
                            ),
                          )
                        ],
                      )),
                  const SizedBox(height: 10),
                  AppField(
                      label: "Senha",
                      child: TextFormField(
                        validator: (value) => value!.validPassword(),
                        onSaved: (value) => setState(() {
                          currentPassword = value ?? currentPassword;
                        }),
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
                        style: Theme.of(context).textTheme.bodyMedium!.merge(
                            const TextStyle(decoration: TextDecoration.none)),
                      )),
                  const SizedBox(height: 10),
                  AppField(
                      label: "Confirmação de Senha",
                      child: TextFormField(
                        validator: (value) => value != currentPassword
                            ? "As senhas não conferem."
                            : null,
                        onSaved: (value) => setState(() {
                          currentPasswordConfirmation =
                              value ?? currentPasswordConfirmation;
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
                        style: Theme.of(context).textTheme.bodyMedium!.merge(
                            const TextStyle(decoration: TextDecoration.none)),
                      )),
                  const SizedBox(height: 15),
                  ElevatedButton(
                      onPressed: submitForm,
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(AppColors.darkYellow),
                      ),
                      child: const Text(
                        "Prosseguir",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                ],
              ),
            ),
          ),
          bottomNavigationBar: const TabNavigation(),
        ),
      ),
    );
  }
}
