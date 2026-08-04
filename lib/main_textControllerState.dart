import 'package:flutter/material.dart';

void main() {
  runApp(MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TelaControler());
  }
}

class TelaControler extends StatefulWidget {
  const TelaControler({super.key});

  @override
  _TelaControlerState createState() => _TelaControlerState();
}

class _TelaControlerState extends State<TelaControler> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Exemplo TextEditingController")),
      body: Column(
        children: [
          TextField(controller: controller),

          ElevatedButton(
            onPressed: () {
              print(controller.text);
            },
            child: Text("Mostrar"),
          ),
        ],
      ),
    );
  }
}
