import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final String baseUrl = "http://10.0.2.2:5000/api";
  final String host = "http://10.0.2.2:5000";

  List items = [];
  double total = 0;
  double discountAmount = 0;
  double displayTotal = 0;
  bool loading = true;

  // ================= DISCOUNTS =================
  List discounts = [];
  dynamic selectedDiscount;

  @override
  void initState() {
    super.initState();
    fetchCart();
    fetchDiscounts();
  }

  // ================= TOKEN =================
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    debugPrint("🟡 TOKEN = $token");
    return token;
  }

  // ================= IMAGE URL FIX =================
  String imageUrl(dynamic image) {
    if (image == null || image.toString().isEmpty) return "";

    final img = image.toString();

    if (img.startsWith("http")) return img;

    if (!img.startsWith("/uploads")) {
      return "$host/uploads/$img";
    }

    return "$host$img";
  }

  // ================= FETCH CART =================
  Future<void> fetchCart() async {
    setState(() => loading = true);

    try {
      final token = await getToken();
      if (token == null) {
        setState(() => loading = false);
        return;
      }

      final res = await http.get(
        Uri.parse("$baseUrl/cart"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          items = data["items"] ?? [];
          total = (data["totalAmount"] ?? 0).toDouble();
          discountAmount = 0;
          displayTotal = total;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("FETCH CART ERROR: $e");
      setState(() => loading = false);
    }
  }

  // ================= FETCH DISCOUNTS =================
  Future<void> fetchDiscounts() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/discounts"));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          discounts = data;
        });
      }
    } catch (e) {
      debugPrint("FETCH DISCOUNTS ERROR: $e");
    }
  }

  // ================= UPDATE QUANTITY =================
  Future<void> updateQuantity(String foodId, int qty) async {
    if (qty <= 0) return removeItem(foodId);

    final token = await getToken();

    await http.put(
      Uri.parse("$baseUrl/cart/update"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "foodId": foodId,
        "quantity": qty,
      }),
    );

    fetchCart();
  }

  // ================= REMOVE ITEM =================
  Future<void> removeItem(String foodId) async {
    final token = await getToken();

    await http.delete(
      Uri.parse("$baseUrl/cart/remove"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"foodId": foodId}),
    );

    fetchCart();
  }

  // ================= CHECKOUT =================
  Future<void> checkout() async {
    final token = await getToken();

    final body = {
      "deliveryAddress": "HUTECH Campus",
      if (selectedDiscount != null) "discountCode": selectedDiscount["code"],
    };

    final res = await http.post(
      Uri.parse("$baseUrl/cart/checkout"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(body),
    );

    final resData = jsonDecode(res.body);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 Order success!")),
      );
      setState(() {
        selectedDiscount = null;
        discountAmount = 0;
      });
      fetchCart();
    } else {
      String msg = resData["message"] ?? "Something went wrong";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "⚠️ Discount invalid or cannot be applied: $msg"),
        ),
      );
      setState(() {
        selectedDiscount = null;
        discountAmount = 0;
        displayTotal = total;
      });
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: Colors.orange,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text("🛒 Cart is empty"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final food = item["food"];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl(food["image"]),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.fastfood, size: 40),
                      ),
                    ),
                    title: Text(
                      food["name"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${item["price"]} \$"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => updateQuantity(
                            food["_id"],
                            item["quantity"] - 1,
                          ),
                        ),
                        Text(item["quantity"].toString()),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => updateQuantity(
                            food["_id"],
                            item["quantity"] + 1,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () =>
                              removeItem(food["_id"]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ================= DISCOUNT SELECT =================
          if (discounts.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Discount:",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      DropdownButton(
                        hint: const Text("Select discount"),
                        value: selectedDiscount,
                        items: discounts.map((d) {
                          return DropdownMenuItem(
                            value: d,
                            child: Text(d["code"]),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDiscount = value;

                            if (selectedDiscount != null) {
                              final type =
                              selectedDiscount["discountType"];
                              final val = (selectedDiscount["value"] ?? 0)
                                  .toDouble();

                              // Kiểm tra hết hạn
                              final now = DateTime.now();
                              final expireAtStr =
                              selectedDiscount["expireAt"];
                              bool expired = false;
                              if (expireAtStr != null) {
                                final expireAt = DateTime.parse(expireAtStr);
                                if (expireAt.isBefore(now)) expired = true;
                              }

                              if (expired) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "⚠️ Mã ${selectedDiscount["code"]} đã hết hạn, vui lòng chọn mã khác hoặc bỏ qua."),
                                  ),
                                );
                                discountAmount = 0;
                                displayTotal = total;
                              } else {
                                if (type == "percentage") {
                                  discountAmount = total * val / 100;
                                } else {
                                  discountAmount = val;
                                }
                                displayTotal = total - discountAmount;
                                if (displayTotal < 0) displayTotal = 0;
                              }
                            } else {
                              discountAmount = 0;
                              displayTotal = total;
                            }
                          });
                        },
                      ),
                      if (selectedDiscount != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          tooltip: "Clear discount",
                          onPressed: () {
                            setState(() {
                              selectedDiscount = null;
                              discountAmount = 0;
                              displayTotal = total;
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),

          // ================= TOTAL & PAY =================
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (discountAmount > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Discount:",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "-\$${discountAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total:",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "\$${displayTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Pay"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
