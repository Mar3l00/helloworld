import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Carteira digital")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 350,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.greenAccent,
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Paypal",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        Icon(Icons.contactless, color: Colors.white, size: 40),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.sim_card,
                          color: const Color.fromARGB(255, 128, 108, 47),
                          size: 40,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "9876 5432 1987 6543",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Titular", style: TextStyle(color: Colors.white)),
                        Text("Validade", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Diego F. M. Tavares",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        Text(
                          "10/30",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 350,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.red,
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Banco Sesi",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        Icon(Icons.contactless, color: Colors.white, size: 40),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.sim_card,
                          color: const Color.fromARGB(255, 128, 108, 47),
                          size: 40,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "1234 5678 9012 3456",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Titular", style: TextStyle(color: Colors.white)),
                        Text("Validade", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Marcelo D. Santonio",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        Text(
                          "12/30",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
