  // lib/screens/dashboard_screen.dart
  import 'package:flutter/material.dart';
  import 'package:fl_chart/fl_chart.dart';
  import '../models/dashboard_stats.dart';
  import '../services/api_service.dart';

  class DashboardScreen extends StatefulWidget {
    final String token;

    const DashboardScreen({Key? key, required this.token}) : super(key: key);

    @override
    _DashboardScreenState createState() => _DashboardScreenState();
  }

  class _DashboardScreenState extends State<DashboardScreen> {
    late Future<DashboardStats> _statsFuture;
    int touchedIndex = -1;

    @override
    void initState() {
      super.initState();
      _loadStats();
    }

    void _loadStats() {
      _statsFuture = ApiService().getDashboardStats(widget.token);
    }

    @override
    Widget build(BuildContext context) {
      return FutureBuilder<DashboardStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading dashboard data'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(_loadStats),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = snapshot.data!;
          return _buildDashboardContent(stats);
        },
      );
    }

    Widget _buildDashboardContent(DashboardStats stats) {
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
                    _buildStatisticsGrid(stats),
                    const SizedBox(height: 32),
                    _buildChartsSection(stats),
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
                  'Dashboard Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back! Here\'s what\'s happening with your platform',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => setState(_loadStats),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Data'),
            ),
          ],
        ),
      );
    }

    Widget _buildStatisticsGrid(DashboardStats stats) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 1200 ? 4 : 2;

          return GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                'Total Users',
                stats.userStats.total.toString(),
                Icons.people,
                Colors.blue,
                'Total registered users',
              ),
              _buildStatCard(
                'Active Users',
                stats.userStats.active.toString(),
                Icons.check_circle,
                Colors.green,
                'Currently active users',
              ),
              _buildStatCard(
                'Inactive Users',
                stats.userStats.inactive.toString(),
                Icons.cancel,
                Colors.red,
                'Currently inactive users',
              ),
              _buildStatCard(
                'New Users',
                stats.userStats.newLastWeek.toString(),
                Icons.trending_up,
                Colors.orange,
                'New users in last 7 days',
              ),
            ],
          );
        },
      );
    }

    Widget _buildChartsSection(DashboardStats stats) {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1200) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildRoleDistributionChart(stats)),
                const SizedBox(width: 24),
                Expanded(child: _buildActivityChart(stats)),
              ],
            );
          } else {
            return Column(
              children: [
                _buildRoleDistributionChart(stats),
                const SizedBox(height: 24),
                _buildActivityChart(stats),
              ],
            );
          }
        },
      );
    }

    Widget _buildStatCard(
        String title,
        String value,
        IconData icon,
        Color color,
        String subtitle,
        ) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildRoleDistributionChart(DashboardStats stats) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Role Distribution',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              AspectRatio(
                aspectRatio: 1.5,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _buildPieChartSections(stats),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildChartLegend(stats),
            ],
          ),
        ),
      );
    }

    List<PieChartSectionData> _buildPieChartSections(DashboardStats stats) {
      return [
        PieChartSectionData(
          value: stats.roleDistribution.superAdmin.toDouble(),
          title: '${stats.roleDistribution.superAdmin}',
          color: Colors.blue,
          radius: 100,
        ),
        PieChartSectionData(
          value: stats.roleDistribution.admin.toDouble(),
          title: '${stats.roleDistribution.admin}',
          color: Colors.green,
          radius: 100,
        ),
        PieChartSectionData(
          value: stats.roleDistribution.regular.toDouble(),
          title: '${stats.roleDistribution.regular}',
          color: Colors.orange,
          radius: 100,
        ),
      ];
    }

    Widget _buildChartLegend(DashboardStats stats) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('Super Admin', stats.roleDistribution.superAdmin, Colors.blue),
          _buildLegendItem('Admin', stats.roleDistribution.admin, Colors.green),
          _buildLegendItem('Regular', stats.roleDistribution.regular, Colors.orange),
        ],
      );
    }

    Widget _buildLegendItem(String label, int value, Color color) {
      return Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label ($value)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    Widget _buildActivityChart(DashboardStats stats) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Activity Status',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              _buildActivityProgress(stats),
              const SizedBox(height: 24),
              _buildActivityStats(stats),
            ],
          ),
        ),
      );
    }

    Widget _buildActivityProgress(DashboardStats stats) {
      final percentage = stats.activeInactiveRatio.percentage;
      return Column(
        children: [
          LinearProgressIndicator(
            value: double.parse(percentage) / 100,          minHeight: 10,
            backgroundColor: Colors.red[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 16),
          Text(
            '$percentage% Active Users',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      );
    }

    Widget _buildActivityStats(DashboardStats stats) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActivityStatItem(
            'Active',
            stats.activeInactiveRatio.active.toString(),
            Colors.green,
          ),
          _buildActivityStatItem(
            'Inactive',
            stats.activeInactiveRatio.inactive.toString(),
            Colors.red,
          ),
        ],
      );
    }

    Widget _buildActivityStatItem(String label, String value, Color color) {
      return Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }
  }