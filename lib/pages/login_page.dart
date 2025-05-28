// lib/pages/user_selection_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'home_page.dart';

class UserSelectionPage extends StatefulWidget {
  const UserSelectionPage({super.key});

  @override
  State<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  List<User> _users = [];
  User? _selectedUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      // Fetch a limited number of users for a clean list
      final url = Uri.parse('https://api.escuelajs.co/api/v1/users?limit=10');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _users = data.map((json) => User.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Optionally show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }

  void _login() {
    if (_selectedUser != null) {
      // Use pushNamed for better route management if set up, otherwise pushReplacement is fine
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
        arguments: _selectedUser,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A gradient background gives a more premium feel
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildLoginCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App Icon/Logo for branding
          Icon(
            Icons.shopping_bag,
            size: 60,
            color: Colors.blue.shade600,
          ),
          const SizedBox(height: 16),
          const Text(
            "Welcome Back!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Select your profile to continue",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // The list of users replaces the dropdown
          _isLoading
              ? const CircularProgressIndicator()
              : _buildUserList(),

          const SizedBox(height: 32),

          // The login button, which is disabled until a user is selected
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedUser == null ? null : _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    // Constrain the height of the list to prevent it from taking too much space
    return Container(
      height: 250, // Adjust height as needed
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        itemCount: _users.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final user = _users[index];
          final isSelected = _selectedUser?.id == user.id;

          return _UserCard(
            user: user,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedUser = user;
              });
            },
          );
        },
      ),
    );
  }
}

// A dedicated widget for the user list item for cleaner code
class _UserCard extends StatelessWidget {
  final User user;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(user.avatar),
                onBackgroundImageError: (e, s) => const Icon(Icons.person),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Colors.blue.shade600,
                )
            ],
          ),
        ),
      ),
    );
  }
}