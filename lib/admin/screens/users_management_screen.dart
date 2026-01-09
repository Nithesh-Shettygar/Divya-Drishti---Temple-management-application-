import 'package:divya_drishti/admin/models/user_model.dart';
import 'package:divya_drishti/admin/services/api_service.dart';
import 'package:divya_drishti/admin/widgets/user_card.dart';
import 'package:flutter/material.dart';


class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await ApiService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
      });
    } catch (e) {
      _showError('Failed to load users: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          return user.phone.contains(query) ||
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.userRef.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Note: You'll need to add a delete user endpoint to your backend
        // await ApiService.deleteUser(user.id);
        setState(() {
          _users.removeWhere((u) => u.id == user.id);
          _filterUsers(_searchQuery);
        });
        _showSuccess('User deleted successfully');
      } catch (e) {
        _showError('Failed to delete user: $e');
      }
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Name'),
                subtitle: Text(user.name),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: Text(user.phone),
              ),
              ListTile(
                leading: const Icon(Icons.numbers),
                title: const Text('User Reference'),
                subtitle: Text(user.userRef),
              ),
              ListTile(
                leading: const Icon(Icons.cake),
                title: const Text('Date of Birth'),
                subtitle: Text(user.dob),
              ),
              ListTile(
                leading: const Icon(Icons.transgender),
                title: const Text('Gender'),
                subtitle: Text(user.gender),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Address'),
                subtitle: Text(user.address),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Registered On'),
                subtitle: Text(
                  '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => _editUser(user),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _editUser(User user) {
    // Implement edit functionality
    _showSuccess('Edit user functionality to be implemented');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterUsers,
              decoration: InputDecoration(
                labelText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Chip(
                  avatar: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      _filteredUsers.length.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  label: const Text('Total Users'),
                ),
                const SizedBox(width: 8),
                Chip(
                  avatar: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, size: 16),
                  ),
                  label: const Text('Active'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Users List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No users found'
                                  : 'No users matching "$_searchQuery"',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return UserCard(
                              user: user,
                              onTap: () => _showUserDetails(user),
                              onDelete: () => _deleteUser(user),
                              onEdit: () => _editUser(user),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new user
          _showAddUserDialog();
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddUserDialog() {
    // Implement add user dialog
    _showSuccess('Add user functionality to be implemented');
  }
}