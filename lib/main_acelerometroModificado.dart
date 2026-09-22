import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFEAF3FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SensorPage(),
    );
  }
}

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  double x = 0;
  double y = 0;
  double z = 0;

  bool isMoving = false;

  // Aceleração da gravidade aproximada (m/s²)
  static const double _gravity = 9.8;
  // Sensibilidade: quanto menor, mais fácil detectar movimento
  static const double _threshold = 1.2;

  @override
  void initState() {
    super.initState();

    accelerometerEventStream().listen((event) {
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;

        // Magnitude do vetor de aceleração
        final double magnitude = sqrt(x * x + y * y + z * z);

        // Diferença em relação à gravidade parada (1g)
        final double delta = (magnitude - _gravity).abs();

        isMoving = delta > _threshold;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isMoving
        ? const Color(0xFF1976D2) // azul mais forte para "em movimento"
        : const Color(0xFF64B5F6); // azul mais claro para "parado"

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor do celular'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Acelerômetro',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),

            const SizedBox(height: 24),

            // Aviso de status (movimento / parado)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMoving ? Icons.directions_run : Icons.stop_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isMoving ? 'Dispositivo em movimento' : 'Dispositivo parado',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF90CAF9), width: 1.5),
              ),
              child: Column(
                children: [
                  Text(
                    'X: ${x.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  Text(
                    'Y: ${y.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  Text(
                    'Z: ${z.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}