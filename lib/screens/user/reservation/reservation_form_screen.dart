import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/auth_service.dart';

class ReservationFormScreen extends StatefulWidget {
  final Map table;
  final DateTime reservationDate;

  const ReservationFormScreen({
    super.key,
    required this.table,
    required this.reservationDate,
  });

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final arrivalCtrl = TextEditingController();
  final guestCtrl = TextEditingController(text: "2");
  final noteCtrl = TextEditingController();

  static const String BASE_URL = "http://10.0.2.2:5000";

  Future<void> submit() async {
    if (guestCtrl.text.isEmpty || int.tryParse(guestCtrl.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid guests")),
      );
      return;
    }

    final token = await AuthService().getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are not logged in")),
      );
      return;
    }

    final dateStr =
        "${widget.reservationDate.year.toString().padLeft(4, '0')}-"
        "${widget.reservationDate.month.toString().padLeft(2, '0')}-"
        "${widget.reservationDate.day.toString().padLeft(2, '0')}";

    final body = {
      "tableId": widget.table["_id"],
      "reservationDate": dateStr,
      "expectedArrivalTime": arrivalCtrl.text,
      "numberOfGuests": int.parse(guestCtrl.text),
      "note": noteCtrl.text,
    };

    final res = await http.post(
      Uri.parse("$BASE_URL/api/reservations"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booked table successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed (${res.statusCode})")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Table ${widget.table['tableNumber']}"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Choose: ${widget.reservationDate.day}/"
                  "${widget.reservationDate.month}/"
                  "${widget.reservationDate.year}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: arrivalCtrl,
              decoration: const InputDecoration(
                labelText: "Time Arrived",
              ),
            ),
            TextField(
              controller: guestCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Number of guests"),
            ),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: "Note"),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text("Confirm"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
