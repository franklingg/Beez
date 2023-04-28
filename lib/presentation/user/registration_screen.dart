import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/loading_widget.dart';
import 'package:flutter/material.dart';

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

  void submitLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        processingForm = true;
      });
      _formKey.currentState!.save();
      Future.delayed(Duration(seconds: 5)).then((v) {
        setState(() {
          processingForm = false;
        });
      });
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
              child: Text("TELA DE REGISTRO"),
            ),
          ),
          bottomNavigationBar: const TabNavigation(),
        ),
      ),
    );
  }
}
