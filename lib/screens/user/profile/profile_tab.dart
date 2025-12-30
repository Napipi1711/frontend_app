import 'package:flutter/material.dart';
import '../../../../services/auth_service.dart';
import '../../login_screen.dart';
import 'widgets/profile_navbar.dart';
import 'history_screen.dart';
import 'orders_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool isLoggedIn = false;
  String username = "";
  int _currentIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    final user = await AuthService().getCurrentUser();
    setState(() {
      isLoggedIn = user['success'] == true || user['username'] != null;
      username = user['username'] ?? "";
      _pages = [
        const OrdersScreen(),
        HistoryScreen(username: username),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),


            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ProfileNavBar(
                currentIndex: _currentIndex,
                onTabSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            // Phần nội dung chính
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _pages.isNotEmpty
                    ? _pages[_currentIndex]
                    : const Center(child: CircularProgressIndicator(color: Colors.orange)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white24,
              child: isLoggedIn
                  ? Text(username[0].toUpperCase(), style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold))
                  : const Icon(Icons.person, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),

          // Thông tin Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? "Hello," : "Hello!",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  isLoggedIn ? username : "customer",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Nút Logout hoặc Login dạng Icon Circle
          Material(
            color: Colors.white24,
            shape: const CircleBorder(),
            child: IconButton(
              icon: Icon(isLoggedIn ? Icons.logout : Icons.login, color: Colors.white),
              onPressed: () async {
                if (isLoggedIn) {
                  await AuthService().logout();
                  checkLoginStatus();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ).then((_) => checkLoginStatus());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}