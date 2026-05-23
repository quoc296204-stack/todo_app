// class AITaskResponse {
//   final String status;
//   final String message;
//   final AIData data;
//
//   AITaskResponse({required this.status, required this.message, required this.data});
//
//   factory AITaskResponse.fromJson(Map<String, dynamic> json) {
//     return AITaskResponse(
//       status: json['status'] ?? '',
//       message: json['message'] ?? '',
//       data: AIData.fromJson(json['data'] ?? {}),
//     );
//   }
// }
//
// class AIData {
//   final int id;
//   final String title;
//   final DateTime dueDate;
//   final String priority;
//   final String category;
//
//   AIData({
//     required this.id,
//     required this.title,
//     required this.dueDate,
//     required this.priority,
//     required this.category,
//   });
//
//   factory AIData.fromJson(Map<String, dynamic> json) {
//     return AIData(
//       id: json['id'] ?? 0,
//       title: json['title'] ?? '',
//       dueDate: DateTime.parse(json['due_date'] ?? DateTime.now().toIsoferString()),
//       priority: json['priority'] ?? 'TRUNG BÌNH',
//       category: json['category'] ?? 'Cá nhân',
//     );
//   }
// }