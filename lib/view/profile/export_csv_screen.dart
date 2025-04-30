import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart' as p;
import '../../data/models/export_model.dart';
import '../../view_model/auth/login_view_model.dart';
import '../../data/repositories/export_repository.dart';

class ExportCsvScreen extends StatefulWidget {
  const ExportCsvScreen({super.key});

  @override
  State<ExportCsvScreen> createState() => _ExportCsvScreenState();
}

class _ExportCsvScreenState extends State<ExportCsvScreen> {
  String selectedData = 'Invoices';
  DateTime? startDate;
  DateTime? endDate;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _exportCsv() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both dates')),
      );
      return;
    }

    final supabase = Supabase.instance.client;
    final loginVM = p.Provider.of<LoginViewModel>(context, listen: false);
    final userId = loginVM.loggedInUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found. Cannot log export.')),
      );
      return;
    }

    List<List<dynamic>> rows = [];

    try {
      final startISO = startDate!.toIso8601String();
      final endISO = endDate!.toIso8601String();

      dynamic response;
      if (selectedData == 'Invoices') {
        response = await supabase
            .from('invoices')
            .select()
            .gte('created_at', startISO)
            .lte('created_at', endISO);

        rows = [
          ['ID', 'Client Name', 'Price', 'Status', 'Platform', 'Due Date'],
          ...response.map((row) => [
                row['id'],
                row['client_name'],
                row['price'],
                row['status'],
                row['platform'],
                row['due_date']
              ])
        ];
      } else if (selectedData == 'Tasks') {
        response = await supabase
            .from('tasks')
            .select()
            .gte('created_at', startISO)
            .lte('created_at', endISO);

        rows = [
          ['ID', 'Task Name', 'Assigned To', 'Price', 'Status', 'Platform', 'Due Date'],
          ...response.map((row) => [
                row['id'],
                row['task_name'],
                row['assigned_to'],
                row['price'],
                row['status'],
                row['platform'],
                row['due_date']
              ])
        ];
      } else if (selectedData == 'Customer Tickets') {
        response = await supabase
            .from('tickets')
            .select()
            .gte('created_at', startISO)
            .lte('created_at', endISO);

        rows = [
          ['ID', 'Client Name', 'Platform', 'Status', 'Updated At'],
          ...response.map((row) => [
                row['id'],
                row['client_name'],
                row['platform'],
                row['status'],
                row['updated_at']
              ])
        ];
      }

      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required')),
        );
        return;
      }

      final downloadsDir = Directory('/storage/emulated/0/Download');
      final String fileName =
          '${selectedData.toLowerCase().replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';

      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsString(const ListToCsvConverter().convert(rows));

      // Log the export to Supabase
      await ExportRepository().addExportRecord(
        ExportRecord(
          id: const Uuid().v4(),
          userId: userId,
          dataType: selectedData,
          startDate: startDate!,
          endDate: endDate!,
          exportedAt: DateTime.now(),
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to ${file.path}')),
        );
      }
    } catch (e) {
      debugPrint('Export failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Widget _buildDataOption(String label) {
    final isSelected = selectedData == label;
    return GestureDetector(
      onTap: () => setState(() => selectedData = label),
      child: Container(
        width: double.infinity,
        height: 64,
        margin: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black.withAlpha(128), width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w400,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          child: Column(
            children: [
              Image.asset('assets/images/stalwrites-logo.png', width: 122, height: 68),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose Your Data',
                  style: TextStyle(fontSize: 24, fontFamily: 'Figtree', fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              _buildDataOption('Invoices'),
              _buildDataOption('Customer Tickets'),
              _buildDataOption('Tasks'),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Date Range',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          startDate == null ? 'Start Date' : DateFormat.yMMMd().format(startDate!),
                          style: const TextStyle(fontFamily: 'Figtree'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          endDate == null ? 'End Date' : DateFormat.yMMMd().format(endDate!),
                          style: const TextStyle(fontFamily: 'Figtree'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black.withAlpha(128), width: 2),
                      ),
                      child: const Text('←', style: TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: _exportCsv,
                      child: Container(
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Text(
                          'Export Your Files',
                          style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Figtree'),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
