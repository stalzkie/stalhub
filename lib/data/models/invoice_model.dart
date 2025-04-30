class Invoice {
  final int id;
  final String clientName;
  final double price;
  final String status;
  final String platform;
  final DateTime createdAt;
  final DateTime dueDate;
  final String? notes;

  Invoice({
    required this.id,
    required this.clientName,
    required this.price,
    required this.status,
    required this.platform,
    required this.createdAt,
    required this.dueDate,
    this.notes,
  });

  // Create Invoice object from Supabase
  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      clientName: map['client_name'],
      price: double.tryParse(map['price'].toString()) ?? 0.0,
      status: map['status'],
      platform: map['platform'],
      createdAt: DateTime.parse(map['created_at']),
      dueDate: DateTime.parse(map['due_date']),
      notes: map['notes'],
    );
  }

  // Convert Invoice object to Supabase-insertable map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_name': clientName,
      'price': price,
      'status': status,
      'platform': platform,
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'notes': notes,
    };
  }

  //editing
  Invoice copyWith({
    int? id,
    String? clientName,
    double? price,
    String? status,
    String? platform,
    DateTime? createdAt,
    DateTime? dueDate,
    String? notes,
  }) {
    return Invoice(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      price: price ?? this.price,
      status: status ?? this.status,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
    );
  }
}
