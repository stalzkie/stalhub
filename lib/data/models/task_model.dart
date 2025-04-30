class Task {
  final int id;
  final String taskName;
  final String clientName;
  final double price;
  final String status;
  final String platform;
  final DateTime createdAt;
  final DateTime dueDate;
  final String assignedTo;
  final String? fileLink;
  final String? notes;

  Task({
    required this.id,
    required this.taskName,
    required this.clientName,
    required this.price,
    required this.status,
    required this.platform,
    required this.createdAt,
    required this.dueDate,
    required this.assignedTo,
    this.fileLink,
    this.notes,
  });

  // Factory for creating from Supabase JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      taskName: json['task_name'],
      clientName: json['client_name'],
      price: double.parse(json['price'].toString()),
      status: json['status'],
      platform: json['platform'],
      createdAt: DateTime.parse(json['created_at']),
      dueDate: DateTime.parse(json['due_date']),
      assignedTo: json['assigned_to'],
      fileLink: json['file_link'],
      notes: json['notes'],
    );
  }

  // For inserting/updating to Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_name': taskName,
      'client_name': clientName,
      'price': price,
      'status': status,
      'platform': platform,
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'assigned_to': assignedTo,
      'file_link': fileLink,
      'notes': notes,
    };
  }

  // Optional: For immutability and state updates
  Task copyWith({
    int? id,
    String? taskName,
    String? clientName,
    double? price,
    String? status,
    String? platform,
    DateTime? createdAt,
    DateTime? dueDate,
    String? assignedTo,
    String? fileLink,
    String? notes,
  }) {
    return Task(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      clientName: clientName ?? this.clientName,
      price: price ?? this.price,
      status: status ?? this.status,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      fileLink: fileLink ?? this.fileLink,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
