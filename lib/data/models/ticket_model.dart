class Ticket {
  final int id;
  final String clientName;
  final String status;
  final String platform;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastNotifiedAt; // ✅ NEW FIELD
  final String content;

  Ticket({
    required this.id,
    required this.clientName,
    required this.status,
    required this.platform,
    required this.createdAt,
    this.updatedAt,
    this.lastNotifiedAt, // ✅ include in constructor
    required this.content,
  });

  // Factory constructor for creating a Ticket from Supabase JSON
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      clientName: json['client_name'],
      status: json['status'],
      platform: json['platform'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null && json['updated_at'] != ''
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      lastNotifiedAt: json['last_notified_at'] != null && json['last_notified_at'] != ''
          ? DateTime.tryParse(json['last_notified_at'].toString())
          : null,
      content: json['content'] ?? '',
    );
  }

  // Convert Ticket to JSON for insert
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_name': clientName,
      'status': status,
      'platform': platform,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_notified_at': lastNotifiedAt?.toIso8601String(), // ✅
      'content': content,
    };
  }

  // Convert Ticket to Map for update
  Map<String, dynamic> toMap() {
    return {
      'client_name': clientName,
      'status': status,
      'platform': platform,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_notified_at': lastNotifiedAt?.toIso8601String(), // ✅
      'content': content,
    };
  }

  // Return a copy with updated fields
  Ticket copyWith({
    String? clientName,
    String? status,
    String? platform,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastNotifiedAt, // ✅
    String? content,
  }) {
    return Ticket(
      id: id,
      clientName: clientName ?? this.clientName,
      status: status ?? this.status,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastNotifiedAt: lastNotifiedAt ?? this.lastNotifiedAt,
      content: content ?? this.content,
    );
  }
}
