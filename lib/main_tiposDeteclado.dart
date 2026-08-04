import 'package:flutter/material.dart';

void main() {
  runApp(MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TelaTeclado());
  }
}

class TelaTeclado extends StatelessWidget {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final idadeController = TextEditingController();
  final telefoneController = TextEditingController();

  TelaTeclado({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tipos de Teclado")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            //Texto padrão
            TextField(
              controller: nomeController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Nome",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            //email
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            //Idade
            TextField(
              controller: idadeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Idade",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            //Telefone
            TextField(
              controller: idadeController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Telefone",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                print("Nome: ${nomeController.text}");
                print("Email: ${emailController.text}");
                print("Idade: ${idadeController.text}");
                print("Telefone: ${telefoneController.text}");
              },
              child: Text("Mostrar Dados"),
            ),
          ],
        ),
      ),
    );
  }
}
