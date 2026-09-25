import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPM sesi 1',
      theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        brightness: Brightness.dark, // Optional: keeps dark mode enabled
      ),
      scaffoldBackgroundColor: Colors.grey[900],
    ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    if (_counter > 0) {
      setState(() {
        _counter--;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Angka tidak boleh kurang dari 0"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEven = _counter % 2 == 0;
    final Color counterColor = isEven ? Colors.green : Colors.red;
    final String textStatus = isEven ? "Angka Genap" : "Angka Ganjil";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PPM Sesi 1 - Muhammad Djibriel Maulidan (20240040239)",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ==================== KARTU IDENTITAS ====================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E222A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        color: Colors.indigoAccent,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Identity Card',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  IdentityDetailRow(
                      label: 'Nama', value: 'Muhammad Djibriel Maulidan'),
                  IdentityDetailRow(label: 'NIM', value: '20240040239'),
                  IdentityDetailRow(
                      label: 'Prodi/Kelas',
                      value: 'Teknik Informatika / TI24G'),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ==================== TAMPILAN COUNTER ====================
            const Text(
              'Nilai Counter:',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              '$_counter',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: counterColor,
              ),
            ),
            const SizedBox(height: 8),

            // Badge Status (Ganjil / Genap)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: counterColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: counterColor),
              ),
              child: Text(
                textStatus,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: counterColor,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ==================== TOMBOL KONTROL ====================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombol Decrement (-)
                ElevatedButton.icon(
                  onPressed: _decrementCounter,
                  icon: const Icon(Icons.remove),
                  label: const Text(''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),

                // Tombol Reset
                OutlinedButton.icon(
                  onPressed: _resetCounter,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),

                // Tombol Increment (+)
                ElevatedButton.icon(
                  onPressed: _incrementCounter,
                  icon: const Icon(Icons.add),
                  label: const Text(''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Widget Helper untuk Baris Identitas
class IdentityDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const IdentityDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ': $value',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}