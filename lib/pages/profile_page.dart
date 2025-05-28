// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import '../models/user.dart';

class ProfilePage extends StatelessWidget {
  // The page now requires a User object to be passed to it.
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar title can be dynamic or static.
     /* appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),*/
      // No FutureBuilder needed, as we have the user data.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // User Avatar
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(user.avatar),
                onBackgroundImageError: (exception, stackTrace) =>
                const Icon(Icons.person, size: 60),
              ),
              const SizedBox(height: 20),
              // User Name
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // User Email
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 10),

              // --- Profile Action Buttons ---
              _buildProfileOption(
                context,
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Profile Clicked!')),
                  );
                },
              ),
              _buildProfileOption(
                context,
                icon: Icons.history_outlined,
                title: 'Order History',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order History Clicked!')),
                  );
                },
              ),
              _buildProfileOption(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings Clicked!')),
                  );
                },
              ),
              const Divider(),
              _buildProfileOption(
                context,
                icon: Icons.logout,
                title: 'Logout',
                isLogout: true, // Special styling for logout
                onTap: () {
                  // Navigate back to the user selection/login screen
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/user-selection', // Make sure this route exists in your main.dart
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to create consistent list tiles for options.
  Widget _buildProfileOption(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final color = isLogout ? Colors.red : Colors.grey[700];
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: isLogout ? FontWeight.bold : FontWeight.normal),
      ),
      trailing: isLogout ? null : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}