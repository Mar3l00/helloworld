import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha localização',
      home: const LocalizacaoPage(),
    );
  }
}

class LocalizacaoPage extends StatefulWidget {
  const LocalizacaoPage({super.key});

  @override
  State<LocalizacaoPage> createState() => _LocalizacaoPageState();
}

class _LocalizacaoPageState extends State<LocalizacaoPage> {
  double latitude = 0.0;
  double longitude = 0.0;
  double distancia = 0.0;
  double latitudecasa = -21.485671;
  double longitudecasa = -47.007091;

  Future<void> buscarLocalizacao() async {
    bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      await Geolocator.openLocationSettings();
      return;
    }
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied) {
      permissao == LocationPermission.deniedForever;
    }
    Position posicao = await Geolocator.getCurrentPosition();
    setState(() {
      latitude = posicao.latitude;
      longitude = posicao.longitude;
    });
    print('Latitude: $latitude');
    print('Longitude: $longitude');
  }

  Future<void> calcularDistancia() async {
    double distanciaCalculada = Geolocator.distanceBetween(
      latitude,
      longitude,
      latitudecasa,
      longitudecasa,
    );
    setState(() {
      distancia = distanciaCalculada;
    });
    print('Distância até casa: ${distancia.toStringAsFixed(2)} metros');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha localização')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                "Localização atual:",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                "Latitude: $latitude\nLongitude: $longitude",
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(height: 20),
              Text(
                "Longitude: $longitude\nLongitude: $longitude",
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: buscarLocalizacao,
                child: const Text("Atualizar localização"),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: calcularDistancia,
                child: const Text("Calcular distância até casa"),
              ),
              Text(
                "Distancia até em casa: ${(distancia / 1000).toStringAsFixed(2)} km",
              ),
            ],
          ),
        ),
      ),
    );
  }
}