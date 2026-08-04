import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Exemplo do Expand",
      home: Scaffold(
        appBar: AppBar(title: const Text("Expanded")),
        body: Column(
          children: [
            Container(
              height: 100,
              width: 100,
              color: Colors.red,
              child: const Center(child: Text("Header")),
            ),
            Expanded(
              child: Container(
                color: Colors.blue,
                child: const Center(
                  child: Text(
                    "Ocupa todo o espaço restante",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
