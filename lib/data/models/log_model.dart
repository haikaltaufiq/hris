class LogActivityModel {
  final int id;
  final String user;
  final String action;
  final String module;
  final String description;
  final List<ChangeLog>? changes;
  final String createdAt;

  LogActivityModel({
    required this.id,
    required this.user,
    required this.action,
    required this.module,
    required this.description,
    this.changes,
    required this.createdAt,
  });

  factory LogActivityModel.fromJson(Map<String, dynamic> json) {
    return LogActivityModel(
      id: json['id'],
      user: json['user'],
      action: json['action'],
      module: json['module'],
      description: json['description'],
      changes: json['changes'] != null
          ? (json['changes'] as List)
              .map((c) => ChangeLog.fromJson(c))
              .toList()
          : null,
      createdAt: json['created_at'],
    );
  }
}

class ChangeLog {
  final String field;
  final String oldValue;
  final String newValue;

  ChangeLog({
    required this.field,
    required this.oldValue,
    required this.newValue,
  });

  factory ChangeLog.fromJson(Map<String, dynamic> json) {
    return ChangeLog(
      field: json['field'],
      oldValue: json['old'],
      newValue: json['new'],
    );
  }
}
