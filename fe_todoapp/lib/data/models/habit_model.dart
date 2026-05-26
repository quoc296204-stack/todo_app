class Habit {
  final int id;
  final String title;
  final String subtitle;
  final String streak;
  final bool isCompleted;
  final bool isWater;

  Habit({required this.id, required this.title, required this.subtitle, required this.streak, required this.isCompleted, this.isWater = false});

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'] ?? "",
      streak: "${json['current_streak']} ngày",
      isCompleted: json['is_completed_today'],
      isWater: json['is_water'] ?? false,
    );
  }
}