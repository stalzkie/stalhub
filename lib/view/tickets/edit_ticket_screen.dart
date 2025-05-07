import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/ticket_model.dart';
import '../../../view_model/tickets/ticket_view_model.dart';
import 'package:stalhub/view/widgets/status_indicator.dart';

class EditTicketScreen extends StatefulWidget {
  final Ticket ticket;

  const EditTicketScreen({super.key, required this.ticket});

  @override
  State<EditTicketScreen> createState() => _EditTicketScreenState();
}

class _EditTicketScreenState extends State<EditTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientNameController;
  late TextEditingController _platformController;
  late TextEditingController _contentController;
  late DateTime _createdAt;
  late DateTime _updatedAt;
  String _selectedStatus = 'Not Read';
  bool _isEditing = false;
  bool _submitted = false;

  final List<String> _statusOptions = ['Not Read', 'Ongoing', 'Resolved', 'Discarded'];

  @override
  void initState() {
    super.initState();
    final ticket = widget.ticket;
    _clientNameController = TextEditingController(text: ticket.clientName);
    _platformController = TextEditingController(text: ticket.platform);
    _contentController = TextEditingController(text: ticket.content);
    _selectedStatus = ticket.status;
    _createdAt = ticket.createdAt;
    _updatedAt = ticket.updatedAt ?? ticket.createdAt;
  }

  Future<void> _updateTicket() async {
    setState(() => _submitted = true);

    if (_clientNameController.text.isEmpty ||
        _platformController.text.isEmpty ||
        _contentController.text.isEmpty) {
      _showErrorDialog("Please fill up all the required information.");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final updatedData = {
      'client_name': _clientNameController.text,
      'status': _selectedStatus,
      'platform': _platformController.text,
      'content': _contentController.text,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final vm = Provider.of<TicketViewModel>(context, listen: false);
    await vm.updateTicket(widget.ticket.id, updatedData);

    if (context.mounted) {
      setState(() => _isEditing = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Success!", style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold)),
          content: const Text("Ticket updated successfully."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Invalid Input"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  Future<void> _deleteTicket() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Are you sure?", style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold)),
        content: const Text("This ticket will be permanently deleted."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final vm = Provider.of<TicketViewModel>(context, listen: false);
      await vm.deleteTicket(widget.ticket.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/images/back-button-icon.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Form(
                  key: _formKey,
                  autovalidateMode:
                      _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Ticket ID: ${widget.ticket.id}", 20, FontWeight.w600),
                      _input("Client Name", _clientNameController, enabled: _isEditing),
                      _dropdownStatusField(),
                      _input("Platform", _platformController, enabled: _isEditing),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _label("Created: ${DateFormat.yMMMd().format(_createdAt)}", 14, FontWeight.w500)),
                          const SizedBox(width: 10),
                          Expanded(child: _label("Updated: ${DateFormat.yMMMd().format(_updatedAt)}", 14, FontWeight.w500)),
                        ],
                      ),
                      _input("Content", _contentController, maxLines: 5, enabled: _isEditing),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bottomButton(
              label: _isEditing ? "Update" : "Edit Ticket",
              color: const Color(0xFFFF7240),
              onTap: () {
                if (_isEditing) {
                  _updateTicket();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
            const SizedBox(height: 10),
            if (_isEditing)
              _bottomButton(
                label: "Cancel",
                color: Colors.white,
                textColor: Colors.black,
                onTap: () => setState(() => _isEditing = false),
                isOutline: true,
              ),
            const SizedBox(height: 10),
            if (_isEditing)
              _bottomButton(
                label: "Delete Ticket",
                color: const Color(0xFFFF0000),
                onTap: _deleteTicket,
              ),
          ],
        ),
      ),
    );
  }

  Widget _input(String hint, TextEditingController controller,
      {int maxLines = 1, TextInputType? keyboard, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
      ),
    );
  }

  Widget _dropdownStatusField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _isEditing ? Colors.white : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Status',
              style: TextStyle(fontSize: 14, fontFamily: 'Figtree', fontWeight: FontWeight.w500),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(15),
                elevation: 6,
                style: const TextStyle(fontSize: 14, fontFamily: 'Figtree'),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: StatusIndicator(status: status),
                    ),
                  );
                }).toList(),
                onChanged: _isEditing
                    ? (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, double fontSize, FontWeight fontWeight) {
    return Text(
      text,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, fontFamily: 'Figtree'),
    );
  }

  Widget _bottomButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isOutline = false,
    Color textColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isOutline ? Colors.white : color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black.withAlpha(204), width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w500,
            color: isOutline ? textColor : const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
    );
  }
}
