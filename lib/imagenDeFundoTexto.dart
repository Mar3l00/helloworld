import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


@override 
Widget build(BuildContext context){
  return MaterialApp(
    home: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/imagens/imgFundo.jpg"),
            fit: BoxFit.contain,
            ),
          ),
          child: const Center(
            child: Text(
              "SENAI",
              style: TextStyle(
                fontSize: 30,
                color: Color.fromRGBO(255, 1, 1, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}