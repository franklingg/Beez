import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  static const String name = 'create_event';
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("CRIAR EVENTO"),
    );
  }
}
