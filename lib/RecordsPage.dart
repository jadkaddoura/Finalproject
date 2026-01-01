import 'package:flutter/material.dart';
import 'data.dart';

class RecordsPage extends StatefulWidget {
  final List<data> records;

  const RecordsPage(this.records, {super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  String searchText = "";

  void _deleteRecord(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Record"),
          content: const Text("Are you sure you want to delete this record?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.records.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = widget.records.where((a) {
      return a.name.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("work Records"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: const InputDecoration(
                hintText: "Search by name",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredRecords.length,
        itemBuilder: (context, index) {
          final a = filteredRecords[index];
          return Card(
            child: ListTile(
              title: Text(a.name),
              subtitle: Text(
                "Date: ${a.date}\n"
                    "Check In: ${a.checkIn}\n"
                    "Check Out: ${a.checkOut}",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteRecord(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
