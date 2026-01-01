import 'package:flutter/material.dart';
import 'dart:async';

import 'data.dart';
import 'RecordsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();

  /// Shared attendance list
  static List<data> attendanceList = [];

  String currentTime = "";
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _updateClock();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateClock();
    });
  }

  /// Update live clock
  void _updateClock() {
    final now = DateTime.now();
    setState(() {
      currentTime =
      "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";
    });
  }

  // Get today's date
  String _todayDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}";
  }

  /// Check In logic
  void _checkIn() {
    if (nameController.text.trim().isEmpty) return;

    final name = nameController.text.trim();
    final date = _todayDate();

    final exists = attendanceList.any(
          (a) => a.name == name && a.date == date && a.checkOut.isEmpty,
    );

    if (!exists) {
      attendanceList.add(
        data(name, date, checkIn: currentTime),
      );

      nameController.clear(); // ✅ reset for next person
      setState(() {});
    }
  }

  /// Check Out logic
  void _checkOut() {
    if (nameController.text.trim().isEmpty) return;

    final name = nameController.text.trim();

    for (var a in attendanceList.reversed) {
      if (a.name == name && a.checkOut.isEmpty) {
        a.checkOut = currentTime;

        nameController.clear(); // ✅ reset for next person
        setState(() {});
        break;
      }
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
        leading: Text(
       _todayDate(),
          
          style: TextStyle(color: Colors.white,fontSize: 18,),
        ),
        backgroundColor: Colors.blueAccent, // change AppBar color
        centerTitle: true,
        title: Text(
          currentTime, // live clock

          style: const TextStyle(
            color: Colors.black, // clock color
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecordsPage(attendanceList),
                ),
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
            Text(
              'Welcome please enter your name',
           style: TextStyle(color:Colors.blueAccent, fontSize: 18,fontStyle: FontStyle.italic ),


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
                  onPressed: _checkIn,
                  child: const Text("Check In"),
                ),
                ElevatedButton(
                  onPressed: _checkOut,
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
