import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ContadorTela());
  }
}

class ContadorTela extends StatefulWidget {
  const ContadorTela({super.key});

  @override
  State<ContadorTela> createState() => _ContadorTelaState();
}

class _ContadorTelaState extends State<ContadorTela> {
  int contador = 0;

  void incrementar() {
    setState(() {
      contador++;
    });
  }

  void decrementar() {
    setState(() {
      if (contador > 0) {
        contador--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("https://recoverit.wondershare.com/uploads/best-android-wallpaper-01.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Minha tela'),
          centerTitle: true,
          backgroundColor: Colors.black45,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.favorite, size: 150, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                "Curtida: $contador",
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: incrementar,
                    child: const Text("Curtir 👍"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: decrementar,
                    child: const Text("Descurtir 👎"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
