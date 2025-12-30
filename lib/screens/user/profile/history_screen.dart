import 'package:flutter/material.dart';
import '../../../../services/reservation_service.dart';

class HistoryScreen extends StatefulWidget {
  final String username;
  const HistoryScreen({super.key, required this.username});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List reservations = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReservations();
  }

  void loadReservations() async {
    setState(() => loading = true);
    try {
      final data = await ReservationService().getMyReservations();
      setState(() => reservations = data);
    } catch (e) {
      debugPrint("ERROR loading reservations: $e");
      setState(() => reservations = []);
    }
    setState(() => loading = false);
  }

  // Hàm phụ giúp hiển thị màu sắc theo trạng thái
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              "Chưa có lịch đặt bàn nào",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final res = reservations[index];
        final table = res['table'];
        final status = res['status'] ?? "pending";
        final dateStr = res['reservationDate'] ?? "";
        final guests = res['numberOfGuests'] ?? 0;

        // Cắt chuỗi ngày tháng: 2023-10-24T10:00 -> 24-10-2023
        String displayDate = "N/A";
        if (dateStr.isNotEmpty) {
          final parts = dateStr.split('T')[0].split('-');
          if (parts.length == 3) {
            displayDate = "${parts[2]}-${parts[1]}-${parts[0]}";
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.table_restaurant, color: Colors.orange),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "NumberOftables ${table['tableNumber']}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(displayDate, style: const TextStyle(color: Colors.black87)),
                        const SizedBox(width: 16),
                        const Icon(Icons.people, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("$guests Guests", style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {

              },
            ),
          ),
        );
      },
    );
  }
}