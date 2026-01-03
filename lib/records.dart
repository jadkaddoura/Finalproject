
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'data.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  List<Data> records = [];final String baseUrl = "https://simarnouredine.atwebpages.com";

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_attendance.php"));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          records = data
              .map(
                (e) => Data(
              e['name'],
              e['date'],
              checkIn: e['check_in'] ?? "",
              checkOut: e['check_out'] ?? "",
              id: e['id'].toString(),
            ),
          )
              .toList();
        });
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await http.get(Uri.parse("$baseUrl/delete_attendance.php?id=$id"));
      fetchRecords(); // refresh after deletion
    } catch (e) {
      print("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Work Records"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _RecordsSearch(records),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchRecords,
          ),
        ],
      ),
      body: records.isEmpty
          ? const Center(child: Text("No records yet"))
          : ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return Card(
            child: ListTile(
              title: Text(record.name),
              subtitle: Text(
                  "Date: ${record.date}\nCheck In: ${record.checkIn}\nCheck Out: ${record.checkOut}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteRecord(record.id),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom SearchDelegate for records
class _RecordsSearch extends SearchDelegate<Data?> {
  final List<Data> records;

  _RecordsSearch(this.records);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = records
        .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return results.isEmpty
        ? const Center(child: Text("No results found"))
        : ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final record = results[index];
        return Card(
          child: ListTile(
            title: Text(record.name),
            subtitle: Text(
                "Date: ${record.date}\nCheck In: ${record.checkIn}\nCheck Out: ${record.checkOut}"),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = records
        .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final record = suggestions[index];
        return ListTile(
          title: Text(record.name),
          onTap: () {
            query = record.name;
            showResults(context);
          },
        );
      },
    );
  }
}
