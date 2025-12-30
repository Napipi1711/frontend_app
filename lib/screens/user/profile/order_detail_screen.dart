import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final String baseUrl = "http://10.0.2.2:5000/api";
  Map order = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetail();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchOrderDetail() async {
    setState(() => loading = true);
    try {
      final token = await getToken();
      final res = await http.get(
        Uri.parse("$baseUrl/orders/${widget.orderId}"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        setState(() {
          order = jsonDecode(res.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text("Detail: #${widget.orderId.substring(widget.orderId.length - 6).toUpperCase()}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : order.isEmpty
          ? const Center(child: Text("No order found."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần Trạng thái
            _buildStatusCard(),
            const SizedBox(height: 20),

            const Text("Ordered dish",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),


            _buildItemsList(),

            const SizedBox(height: 20),

            // Tổng cộng (Bill)
            _buildBillSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = order["status"] ?? "pending";
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.local_shipping, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Order status", style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text(status.toUpperCase(),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    final items = (order["items"] as List?) ?? [];
    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              // Ảnh món ăn (Placeholder)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60, height: 60,
                  color: Colors.orange.withOpacity(0.1),
                  child: const Icon(Icons.fastfood, color: Colors.orange),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item["name"] ?? "Dish",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("quantity: ${item["quantity"]}",
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Text("\$${item["price"]}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBillSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildBillRow("Temporarily calculated", "\$${order["totalAmount"]}"),
          _buildBillRow("Service fee", "\$0.00"),
          const Divider(height: 30),
          _buildBillRow("TotalAmount", "\$${order["totalAmount"]}", isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey
        )),
        Text(value, style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.bold,
            color: isTotal ? Colors.orange : Colors.black
        )),
      ],
    );
  }
}