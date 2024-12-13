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
  List<User> _users = [];
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: _buildMainContent(),
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                'Manage and monitor user accounts',
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
            label: const Text('Refresh Data'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(),
          const Divider(height: 1),
          Expanded(
            child: _buildUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (_) => _loadUsers(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 48,
            child: _buildRoleDropdown(),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 48,
            child: _buildSortByDropdown(),
          ),
          const SizedBox(width: 16),
          _buildSortOrderButton(),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
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
        ),
      ),
    );
  }

  Widget _buildSortByDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
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
        ),
      ),
    );
  }

  Widget _buildSortOrderButton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(_sortOrder == 'asc' ? Icons.arrow_upward : Icons.arrow_downward),
        onPressed: () {
          setState(() {
            _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
          });
          _loadUsers();
        },
      ),
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
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.grey[200],
          dataTableTheme: DataTableThemeData(
            headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
            dataRowColor: MaterialStateProperty.all(Colors.white),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 24,
          columns: [
            const DataColumn(label: Text('ID')),
            const DataColumn(label: Text('Name')),
            const DataColumn(label: Text('Email')),
            const DataColumn(label: Text('Role')),
            const DataColumn(label: Text('Status')),
            const DataColumn(label: Text('Joined Date')),
            const DataColumn(label: Text('Actions')),
          ],
          rows: _users.map((user) => _buildUserRow(user)).toList(),
        ),
      ),
    );
  }

  DataRow _buildUserRow(User user) {
    return DataRow(
      cells: [
        DataCell(Text(user.id.substring(0, 8))),
        DataCell(Text(user.name)),
        DataCell(Text(user.email)),
        DataCell(_buildRoleChip(user.role)),
        DataCell(_buildStatusChip(user.isActive)),
        DataCell(Text(_formatDate(user.createdAt))),
        DataCell(_buildActions(user)),
      ],
    );
  }

  Widget _buildRoleChip(String role) {
    final color = _getRoleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        role.capitalize(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    final color = isActive ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActions(User user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            user.isActive ? Icons.toggle_on : Icons.toggle_off,
            color: user.isActive ? Colors.green : Colors.grey,
          ),
          onPressed: () => _toggleUserStatus(user.id, !user.isActive),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _editUser(user),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'superadmin':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime? date) {
    return date == null ? 'N/A' : DateFormat('MMM d, yyyy').format(date);
  }

  void _editUser(User user) {
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
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleUserStatus(String userId, bool newStatus) async {
    try {
      await ApiService().updateUserStatus(widget.token, userId, newStatus);
      await _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}