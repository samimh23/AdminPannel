// lib/models/dashboard_stats.dart
class DashboardStats {
  final UserStats userStats;
  final RoleDistribution roleDistribution;
  final ActiveInactiveRatio activeInactiveRatio;

  DashboardStats({
    required this.userStats,
    required this.roleDistribution,
    required this.activeInactiveRatio,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      userStats: UserStats.fromJson(json['userStats']),
      roleDistribution: RoleDistribution.fromJson(json['roleDistribution']),
      activeInactiveRatio: ActiveInactiveRatio.fromJson(json['activeInactiveRatio']),
    );
  }
}

class UserStats {
  final int total;
  final int active;
  final int inactive;
  final int newLastWeek;

  UserStats({
    required this.total,
    required this.active,
    required this.inactive,
    required this.newLastWeek,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      total: json['total'],
      active: json['active'],
      inactive: json['inactive'],
      newLastWeek: json['newLastWeek'],
    );
  }
}

class RoleDistribution {
  final int superAdmin;
  final int admin;
  final int regular;

  RoleDistribution({
    required this.superAdmin,
    required this.admin,
    required this.regular,
  });

  factory RoleDistribution.fromJson(Map<String, dynamic> json) {
    return RoleDistribution(
      superAdmin: json['superAdmin'],
      admin: json['admin'],
      regular: json['regular'],
    );
  }
}

class ActiveInactiveRatio {
  final int active;
  final int inactive;
  final String percentage;

  ActiveInactiveRatio({
    required this.active,
    required this.inactive,
    required this.percentage,
  });

  factory ActiveInactiveRatio.fromJson(Map<String, dynamic> json) {
    return ActiveInactiveRatio(
      active: json['active'],
      inactive: json['inactive'],
      percentage: json['percentage'],
    );
  }
}