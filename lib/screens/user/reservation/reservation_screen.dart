import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'reservation_form_screen.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime selectedDate = DateTime.now();
  List tables = [];
  bool loading = false;

  static const String BASE_URL = "http://10.0.2.2:5000";

  Future<void> loadTables() async {
    setState(() => loading = true);

    final date =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    print("DEBUG: load tables for $date");

    final res = await http.get(
      Uri.parse("$BASE_URL/api/reservations/available?date=$date"),
    );

    print("DEBUG RESPONSE ${res.statusCode}: ${res.body}");

    if (res.statusCode == 200) {
      tables = jsonDecode(res.body);
    } else {
      tables = [];
    }

    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    loadTables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservation"),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              "Select Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );

              if (picked != null) {
                setState(() => selectedDate = picked);
                loadTables();
              }
            },
          ),
          const Divider(),
          loading
              ? const CircularProgressIndicator()
              : Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservationFormScreen(
                          table: table,
                          reservationDate: selectedDate,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "Table ${table['tableNumber']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
