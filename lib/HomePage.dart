import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'records.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();

  String currentTime = "";
  String currentDate = "";
  Timer? timer;

  final String baseUrl = "https://simarnouredine.atwebpages.com";

  @override
  void initState() {
    super.initState();
    _updateClock();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  void _updateClock() {
    final now = DateTime.now();
    setState(() {
      currentTime =
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      currentDate =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    });
  }

  void resetForm() {
    nameController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> checkIn() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final encodedName = Uri.encodeComponent(name);

    final url = Uri.parse(
        "$baseUrl/add_attendance.php?name=$encodedName&date=$currentDate&check_in=$currentTime");

    try {
      final response = await http.get(url);
      print("Check-in response: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Checked in successfully")),
      );
      resetForm();
    } catch (e) {
      print("Check-in error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Check-in failed: $e")),
      );
    }
  }

  Future<void> checkOut() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final encodedName = Uri.encodeComponent(name);

    final url =
    Uri.parse("$baseUrl/update_checkout.php?name=$encodedName&check_out=$currentTime");

    try {
      final response = await http.get(url);
      print("Check-out response: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Checked out successfully")),
      );
      resetForm();
    } catch (e) {
      print("Check-out error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Check-out failed: $e")),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leadingWidth: 120,
        leading: Center(
          child: Text(
            currentDate,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        centerTitle: true,
        title: Text(
          currentTime,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecordsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome, please enter your name",
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueAccent,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Enter your name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: checkIn,
                  child: const Text("Check In"),
                ),
                ElevatedButton(
                  onPressed: checkOut,
                  child: const Text("Check Out"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
