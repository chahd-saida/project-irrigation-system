import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "systeme d'irrigation",
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      home: const HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  double? temperature;
  double? humidity;
  int? soilMoisture;
  String? pumpStatus;

  final String esp32Url = 'http://192.168.219.130/status';

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(esp32Url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = data['temperature']?.toDouble();
          humidity = data['humidity']?.toDouble();
          soilMoisture = data['soil_moisture_percent']?.toInt();
          pumpStatus =
              data['pump_status']?.toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur HTTP: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion : $e'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
    @override
    void initState() {
      super.initState();
      fetchData(); // appel initial
      Timer.periodic(const Duration(seconds: 2), (timer) {
        fetchData();
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Système d'irrigation automatique "),
          centerTitle: true,
          backgroundColor: Colors.green.shade700,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [


            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade100,
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  )
                ],
              ),
              child: Text(humidity != null ? "💧Humidité de l'air: ${humidity!.toStringAsFixed(1)}%" : "💧Humidité de l'air: N/A",
                style: const TextStyle(fontSize: 24),
              ),
            ),


            const SizedBox(height: 30),

            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade100,
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  )
                ],
              ),
              child: Text(
                temperature != null ? "🌡️Température de l'air: ${temperature!.toStringAsFixed(1)}°C" : "🌡️Température de l'air: N/A",
                style: const TextStyle(fontSize: 24),
              ),
            ),


            const SizedBox(height: 30),

            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade100,
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  )
                ],
              ),
              child: Text(soilMoisture != null
                  ? "🌱 Humidité du Sol: ${soilMoisture!}%" : "🌱 Humidité du Sol: N/A",
                style: const TextStyle(fontSize: 24),
              ),
            ),


            const SizedBox(height: 30),

            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade100,
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  )
                ],
              ),
              child: Text(
                pumpStatus != null ? "Pompe: ${pumpStatus!}" : "Pompe: N/A",
                style: const TextStyle(fontSize: 24),
              ),
            ),


            const SizedBox(height: 30),


          ],
        ),
      );
    }
  }


