import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'pagina de login', home: LoginPage());
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double largura = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: largura * 0.85,
              child: Column(
                children: [
                  SizedBox(height: 80),
                  Icon(
                    Icons.lock,
                    size: largura * 0.2,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: largura * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'EMAIL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'SENHA',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('ENTRAR'),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(onPressed: () {}, child: Text('CRIAR CONTA')),
                  SizedBox(height: 500),
                  TextButton(onPressed: () {}, child: Text('ESQUECEU SUA SENHA?')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
