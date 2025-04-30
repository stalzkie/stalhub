    class ExportRecord {
      final String id;
      final String userId;
      final String dataType;
      final DateTime startDate;
      final DateTime endDate;
      final DateTime exportedAt;

      ExportRecord({
        required this.id,
        required this.userId,
        required this.dataType,
        required this.startDate,
        required this.endDate,
        required this.exportedAt,
      });

      factory ExportRecord.fromJson(Map<String, dynamic> json) {
        return ExportRecord(
          id: json['id'],
          userId: json['user_id'],
          dataType: json['data_type'],
          startDate: DateTime.parse(json['start_date']),
          endDate: DateTime.parse(json['end_date']),
          exportedAt: DateTime.parse(json['exported_at']),
        );
      }

      Map<String, dynamic> toJson() {
        return {
          'id': id,
          'user_id': userId,
          'data_type': dataType,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'exported_at': exportedAt.toIso8601String(),
        };
      }
    }