import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UsersScreen extends StatefulWidget {
  final String token;

  const UsersScreen({Key? key, required this.token}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  List<User> _users = [];
  bool _isLoadingMore = false;
  bool _isLoading = false;
  String? _error;
  String _selectedRole = '';
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(),
                  const SizedBox(height: 24),
                  _buildUsersList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Users Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Comprehensive user overview and management',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Users'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name, email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => _loadUsers(),
            ),
          ),
          const SizedBox(width: 16),
          _buildRoleDropdown(),
          const SizedBox(width: 16),
          _buildSortByDropdown(),
          const SizedBox(width: 16),
          _buildSortOrderButton(),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButton<String>(
      value: _selectedRole,
      hint: const Text('All Roles'),
      items: [
        const DropdownMenuItem(value: '', child: Text('All Roles')),
        const DropdownMenuItem(value: 'admin', child: Text('Admin')),
        const DropdownMenuItem(value: 'user', child: Text('User')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedRole = value ?? '';
        });
        _loadUsers();
      },
    );
  }

  Widget _buildSortByDropdown() {
    return DropdownButton<String>(
      value: _sortBy,
      items: [
        const DropdownMenuItem(value: 'createdAt', child: Text('Date')),
        const DropdownMenuItem(value: 'name', child: Text('Name')),
        const DropdownMenuItem(value: 'email', child: Text('Email')),
      ],
      onChanged: (value) {
        setState(() {
          _sortBy = value ?? 'createdAt';
        });
        _loadUsers();
      },
    );
  }

  Widget _buildSortOrderButton() {
    return IconButton(
      icon: Icon(_sortOrder == 'asc' ? Icons.arrow_upward : Icons.arrow_downward),
      onPressed: () {
        setState(() {
          _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
        });
        _loadUsers();
      },
    );
  }

  Widget _buildUsersList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading users', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User List',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 40,
                columns: [
                  _buildDataColumn('ID'),
                  _buildDataColumn('Name'),
                  _buildDataColumn('Email'),
                  _buildDataColumn('Role'),
                  _buildDataColumn('Status'),
                  _buildDataColumn('Joined Date'),
                  _buildDataColumn('Last Login'),
                  _buildDataColumn('Actions'),
                ],
                rows: _users.map((user) => _buildUserRow(user)).toList(),
              ),
            ),
            if (_users.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No users found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  DataRow _buildUserRow(User user) {
    return DataRow(
      cells: [
        DataCell(Text(user.id.substring(0, 8))), // Truncated ID
        DataCell(Text(user.name)),
        DataCell(Text(user.email)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.role.capitalize(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.isActive ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: user.isActive ? Colors.green[900] : Colors.red[900],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(Text(_formatDate(user.createdAt))),
        DataCell(Text("okey")),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  user.isActive ? Icons.check_circle : Icons.cancel,
                  color: user.isActive ? Colors.green : Colors.red,
                ),
                onPressed: () => _toggleUserStatus(user.id, !user.isActive),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editUser(user),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'superadmin':
        return Colors.deepPurple;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime? date) {
    return date == null
        ? 'N/A'
        : DateFormat('MMM d, yyyy').format(date);
  }

  void _editUser(User user) {
    // Placeholder for user edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit functionality for ${user.name} coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loadUsers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _users = [];
      _error = null;
    });

    try {
      final response = await ApiService().getUsers(
        token: widget.token,
        search: _searchController.text,
        role: _selectedRole,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      setState(() {
        _users = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load users: ${e.toString()}';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleUserStatus(String userId, bool newStatus) async {
    final currentUsers = List<User>.from(_users);
    final userIndex = _users.indexWhere((user) => user.id == userId);

    if (userIndex != -1) {
      setState(() {
        _users[userIndex] = _users[userIndex].copyWith(isActive: newStatus);
      });
    }

    try {
      await ApiService().updateUserStatus(widget.token, userId, newStatus);

      await _loadUsers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User status updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() {
        _users = currentUsers;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user status: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}