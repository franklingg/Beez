import 'package:beez/constants/app_colors.dart';
import 'package:beez/constants/app_images.dart';
import 'package:beez/presentation/login/forgot_password_screen.dart';
import 'package:beez/presentation/map/map_screen.dart';
import 'package:beez/presentation/register/phone_confirmation_screen.dart';
import 'package:beez/presentation/shared/app_alerts.dart';
import 'package:beez/presentation/register/registration_screen.dart';
import 'package:beez/presentation/login/signin_items_widget.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/app_field_widget.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:beez/providers/event_provider.dart';
import 'package:beez/providers/notification_provider.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:beez/services/auth_service.dart';
import 'package:beez/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String name = 'login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _visiblePassword = false;
  bool processingForm = false;
  String currentEmail = "";
  String currentPassword = "";

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        processingForm = true;
      });
      _formKey.currentState!.save();
      final possibleUser = Provider.of<UserProvider>(context, listen: false)
          .findUser(currentEmail);
      if (possibleUser != null && !possibleUser.verifiedPhone) {
        setState(() {
          processingForm = false;
        });
        GoRouter.of(context)
            .pushNamed(PhoneConfirmationScreen.name, extra: possibleUser);
      } else {
        AuthService.performLogin(
                context: context,
                method: SignInMethod.EMAIL,
                email: currentEmail,
                password: currentPassword)
            .then((user) {
              return Provider.of<NotificationProvider>(context, listen: false)
                  .subscribeNotifications(
                      user.id,
                      Provider.of<EventProvider>(context, listen: false)
                          .nextEvents);
            })
            .whenComplete(() => setState(() {
                  processingForm = false;
                }))
            .then((_) {
              GoRouter.of(context).pushNamed(MapScreen.name);
            })
            .onError((String errorMsg, _) {
              AppAlerts.error(alertContext: context, errorMessage: errorMsg);
            });
      }
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
                  Text(
                    "Acesse sua conta e tenha acesso\na toda a Colmeia!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SvgPicture.asset(
                    AppImages.loginBanner,
                    height: 170,
                  ),
                  const SizedBox(height: 20),
                  AppField(
                    child: TextFormField(
                      onSaved: (value) => setState(() {
                        currentEmail = value ?? currentEmail;
                      }),
                      decoration: AppField.inputDecoration(hint: "E-mail"),
                      validator: (value) => value!.validEmail(),
                      style: Theme.of(context).textTheme.bodyMedium!.merge(
                          const TextStyle(decoration: TextDecoration.none)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  AppField(
                    child: TextFormField(
                      validator: (value) => value!.validPassword(),
                      onSaved: (value) => setState(() {
                        currentPassword = value ?? currentPassword;
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
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      GoRouter.of(context).pushNamed(ForgotPasswordScreen.name);
                    },
                    child: Text("Esqueceu a senha?",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        submitForm();
                      },
                      style: const ButtonStyle(
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.symmetric(vertical: 10)),
                          backgroundColor:
                              MaterialStatePropertyAll(AppColors.darkYellow)),
                      child: const Text(
                        "Entrar",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )),
                  const SizedBox(height: 20),
                  const Text(
                    "Ou conecte-se com",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.mediumGrey, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  const SignInItems(),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Não tem uma conta?",
                        style: TextStyle(fontSize: 13),
                      ),
                      TextButton(
                          onPressed: () {
                            GoRouter.of(context)
                                .pushNamed(RegistrationScreen.name);
                          },
                          child: const Text(
                            "Registre-se",
                            style: TextStyle(
                                color: AppColors.darkYellow, fontSize: 13),
                          ))
                    ],
                  )
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
