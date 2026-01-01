import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  List<Data> records = [];
  final String baseUrl = "https://simarnouredine.atwebpages.com";

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    final response = await http.get(Uri.parse("$baseUrl/get_attendance.php"));
    final List data = json.decode(response.body);

    setState(() {
      records = data.map((e) => Data(
        e['name'],
        e['date'],
        checkIn: e['check_in'] ?? "",
        checkOut: e['check_out'] ?? "",
      )).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("work Records"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await showSearch(
                context: context,
                delegate: _SearchDelegate(records),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchRecords,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final a = records[index];
          return Card(
            child: ListTile(
              title: Text(a.name),
              subtitle: Text(
                "Date: ${a.date}\n"
                    "Check In: ${a.checkIn}\n"
                    "Check Out: ${a.checkOut}",
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchDelegate extends SearchDelegate {
  final List<Data> records;
  _SearchDelegate(this.records);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = "")
  ];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) {
    final results = records
        .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: results.map((r) => ListTile(
        title: Text(r.name),
        subtitle: Text("In: ${r.checkIn} | Out: ${r.checkOut}"),
      )).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);
}
