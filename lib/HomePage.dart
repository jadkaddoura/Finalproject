import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'RecordsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();

  String currentTime = "";
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
      "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";
    });
  }

  Future<void> checkIn() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final resp = await http.post(
      Uri.parse("$baseUrl/add_attendance.php"),
      body: {
        'name': name,
        'date': DateTime.now().toString().substring(0, 10),
        'check_in': DateTime.now().toString().substring(11, 19),
      },
    );

    final body = json.decode(resp.body);
    if (body["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Checked in ✅")),
      );
      nameController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Check-in failed: ${body["error"] ?? "Unknown"}")),
      );
    }
  }

  Future<void> checkOut() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final resp = await http.post(
      Uri.parse("$baseUrl/update_checkout.php"),
      body: {
        'name': name,
        'check_out': DateTime.now().toString().substring(11, 19),
      },
    );

    final body = json.decode(resp.body);
    if (body["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Checked out ✅")),
      );
      nameController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Check-out failed: ${body["error"] ?? "Unknown"}")),
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
        leadingWidth: 90,
        leading: const SizedBox(),
        centerTitle: true,
        title: Text(
          currentTime,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
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
              'Welcome please enter your name',
              style: TextStyle(color: Colors.blueAccent, fontSize: 18, fontStyle: FontStyle.italic),
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
                ElevatedButton(onPressed: checkIn, child: const Text("Check In")),
                ElevatedButton(onPressed: checkOut, child: const Text("Check Out")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
