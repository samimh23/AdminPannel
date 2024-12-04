import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  String _selectedRole = '';
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(_onScroll);
  }
  // In _UsersScreenState class
  Future<void> _updateUserRole(String userId, String currentRole) async {
    final colorScheme = Theme.of(context).colorScheme;

    // Store current users state for rollback
    final currentUsers = List<User>.from(_users);

    String? newRole = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update User Role'),
          content: DropdownButton<String>(
            value: currentRole,
            items: [
              DropdownMenuItem(value: 'USER', child: Text('User')),
              DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
              DropdownMenuItem(value: 'SUPER_ADMIN', child: Text('Super Admin')),
            ],
            onChanged: (String? value) {
              Navigator.of(context).pop(value);
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );

    if (newRole != null && newRole != currentRole) {
      try {
        // Optimistic update
        final userIndex = _users.indexWhere((user) => user.id == userId);
        if (userIndex != -1) {
          setState(() {
            _users[userIndex] = _users[userIndex].copyWith(role: newRole);
          });
        }

        // Make API call
        await ApiService().updateUserRole(widget.token, userId, newRole);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User role updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // Reload users to ensure consistency
        await _loadUsers();
      } catch (e) {
        // Revert optimistic update
        setState(() {
          _users = currentUsers;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update user role: ${e.toString()}'),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  // Existing methods like _loadUsers, _toggleUserStatus remain the same

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    final textTheme = Theme
        .of(context)
        .textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme, textTheme),
            _buildFilters(colorScheme),
            Expanded(
              child: _error != null
                  ? Center(
                child: Text(
                  _error!,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              )
                  : _buildUsersList(colorScheme, textTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Users Management',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: Icon(Icons.search, color: colorScheme.primary),
              filled: true,
              fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
            onChanged: (_) => _loadUsers(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildFilters(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildRoleDropdown(colorScheme),
          _buildSortByDropdown(colorScheme),
          _buildSortOrderButton(colorScheme),
          _buildPaginationInfo(colorScheme),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildRoleDropdown(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          value: _selectedRole,
          dropdownColor: colorScheme.surface,
          items: [
            DropdownMenuItem(value: '',
                child: Text('All Roles',
                    style: TextStyle(color: colorScheme.onSurface))),
            DropdownMenuItem(value: 'admin',
                child: Text(
                    'Admin', style: TextStyle(color: colorScheme.onSurface))),
            DropdownMenuItem(value: 'user',
                child: Text(
                    'User', style: TextStyle(color: colorScheme.onSurface))),
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

  Widget _buildSortByDropdown(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          value: _sortBy,
          dropdownColor: colorScheme.surface,
          items: [
            DropdownMenuItem(value: 'createdAt',
                child: Text(
                    'Date', style: TextStyle(color: colorScheme.onSurface))),
            DropdownMenuItem(value: 'name',
                child: Text(
                    'Name', style: TextStyle(color: colorScheme.onSurface))),
            DropdownMenuItem(value: 'email',
                child: Text(
                    'Email', style: TextStyle(color: colorScheme.onSurface))),
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

  Widget _buildSortOrderButton(ColorScheme colorScheme) {
    return IconButton(
      icon: Icon(
        _sortOrder == 'asc' ? Icons.arrow_upward : Icons.arrow_downward,
        color: colorScheme.primary,
      ),
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        setState(() {
          _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
        });
        _loadUsers();
      },
    );
  }

  Widget _buildPaginationInfo(ColorScheme colorScheme) {
    return Text(
      'Page $_currentPage of $_totalPages',
      style: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildUsersList(ColorScheme colorScheme, TextTheme textTheme) {
    return RefreshIndicator(
      onRefresh: () => _loadUsers(),
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) =>
                    colorScheme.surfaceVariant.withOpacity(0.5),
              ),
              columns: [
                _buildDataColumn('Name', colorScheme),
                _buildDataColumn('Email', colorScheme),
                _buildDataColumn('Role', colorScheme),
                _buildDataColumn('Status', colorScheme),
                _buildDataColumn('Actions', colorScheme),
              ],
              rows: _users.map((user) {
                return DataRow(
                  cells: [
                    DataCell(Text(user.name, style: textTheme.bodyMedium)),
                    DataCell(Text(user.email, style: textTheme.bodyMedium)),
                    DataCell(Text(user.role, style: textTheme.bodyMedium)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.isActive ? Colors.green[50] : Colors
                              .red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: user.isActive ? Colors.green[900] : Colors
                                .red[900],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Switch(
                        value: user.isActive,
                        activeColor: colorScheme.primary,
                        onChanged: (bool value) {
                          _toggleUserStatus(user.id, value);
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (_isLoadingMore)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: colorScheme.primary),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  DataColumn _buildDataColumn(String label, ColorScheme colorScheme) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

// Existing dispose and other methods remain the same


  Future<void> _loadUsers({bool reset = true}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (reset) {
        _users = [];
        _currentPage = 1;
      }
      _error = null;
    });

    try {
      final response = await ApiService().getUsers(
        token: widget.token,
        page: _currentPage,
        limit: 10,
        search: _searchController.text,
        role: _selectedRole,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      setState(() {
        if (reset) {
          _users = response.data;
        } else {
          _users.addAll(response.data);
        }
        _totalPages = response.meta.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load users: ${e.toString()}';
        _isLoading = false;
      });

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleUserStatus(String userId, bool newStatus) async {
    // Optimistic update for better UX
    final currentUsers = List<User>.from(_users);
    final userIndex = _users.indexWhere((user) => user.id == userId);

    if (userIndex != -1) {
      setState(() {
        _users[userIndex] = _users[userIndex].copyWith(isActive: newStatus);
      });
    }

    try {
      await ApiService().updateUserStatus(widget.token, userId, newStatus);

      // Reload the current page of users to ensure consistency
      await _loadUsers(reset: true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User status updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Revert optimistic update if API call fails
      setState(() {
        _users = currentUsers;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user status: ${e.toString()}'),
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      await _loadUsers(reset: false);
    } catch (e) {
      // Decrement page back if loading fails
      _currentPage--;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load more users: ${e.toString()}'),
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.atEdge) {
      bool isBottom = _scrollController.position.pixels != 0;
      if (isBottom && _currentPage < _totalPages) {
        _loadMoreUsers();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}