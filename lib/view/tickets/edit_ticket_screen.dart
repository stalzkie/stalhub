import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/ticket_model.dart';
import '../../../view_model/tickets/ticket_view_model.dart';
import '../../../view_model/auth/login_view_model.dart'; // ✅ Add this for userId & playerId

class EditTicketScreen extends StatefulWidget {
  final Ticket ticket;

  const EditTicketScreen({super.key, required this.ticket});

  @override
  State<EditTicketScreen> createState() => _EditTicketScreenState();
}

class _EditTicketScreenState extends State<EditTicketScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _clientNameController;
  late TextEditingController _statusController;
  late TextEditingController _platformController;
  late TextEditingController _contentController;

  late DateTime _createdAt;
  late DateTime _updatedAt;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final ticket = widget.ticket;
    _clientNameController = TextEditingController(text: ticket.clientName);
    _statusController = TextEditingController(text: ticket.status);
    _platformController = TextEditingController(text: ticket.platform);
    _contentController = TextEditingController(text: ticket.content);
    _createdAt = ticket.createdAt;
    _updatedAt = ticket.updatedAt ?? ticket.createdAt;
  }

  Future<void> _updateTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedData = {
      'client_name': _clientNameController.text,
      'status': _statusController.text,
      'platform': _platformController.text,
      'content': _contentController.text,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // ✅ Inject userId & playerId
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final vm = TicketViewModel(
      userId: loginVM.loggedInUser?.id ?? '',
      playerId: loginVM.loggedInUser?.playerId ?? '',
    );

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
            )
          ],
        ),
      );
    }
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
      // ✅ Inject userId & playerId
      final loginVM = Provider.of<LoginViewModel>(context, listen: false);
      final vm = TicketViewModel(
        userId: loginVM.loggedInUser?.id ?? '',
        playerId: loginVM.loggedInUser?.playerId ?? '',
      );

      await vm.deleteTicket(widget.ticket.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 40),
          Image.asset('assets/images/stalwrites-logo.png', width: 122, height: 68),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
              decoration: ShapeDecoration(
                color: const Color(0xFFEDEDED),
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 2, color: Colors.black.withAlpha(128)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _labelText("Ticket ID: ${widget.ticket.id}", bold: true),
                      const SizedBox(height: 8),
                      _textInput("Client Name", controller: _clientNameController, enabled: _isEditing),
                      _textInput("Status", controller: _statusController, enabled: _isEditing),
                      _textInput("Platform", controller: _platformController, enabled: _isEditing),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _labelText("Created: ${DateFormat.yMMMd().format(_createdAt)}"),
                          _labelText("Updated: ${DateFormat.yMMMd().format(_updatedAt)}"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _textInput("Content", controller: _contentController, maxLines: 5, enabled: _isEditing),
                      const SizedBox(height: 20),
                      _button(_isEditing ? "Update" : "Edit Ticket", const Color.fromARGB(255, 26, 26, 26), () {
                        if (_isEditing) {
                          _updateTicket();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      }),
                      const SizedBox(height: 10),
                      _button(_isEditing ? "Cancel" : "Go Back", Colors.white, () {
                        if (_isEditing) {
                          setState(() => _isEditing = false);
                        } else {
                          Navigator.pop(context);
                        }
                      }, isOutline: true),
                      const SizedBox(height: 10),
                      if (_isEditing)
                        _button("Delete Ticket", const Color(0xFFFF0000), _deleteTicket),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textInput(String hint,
      {TextEditingController? controller, int maxLines = 1, TextInputType? keyboard, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black.withAlpha(100)),
          ),
        ),
        validator: (value) {
          if (hint.contains("Content") && (value == null || value.isEmpty)) {
            return "Content cannot be empty";
          }
          return null;
        },
      ),
    );
  }

  Widget _labelText(String text, {bool bold = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: bold ? 20 : 14,
        fontWeight: bold ? FontWeight.bold : FontWeight.w400,
        fontFamily: 'Figtree',
      ),
    );
  }

  Widget _button(String label, Color color, VoidCallback onTap, {bool isOutline = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 330,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isOutline ? Colors.white : color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black.withAlpha(204), width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w400,
            color: isOutline ? Colors.black.withAlpha(204) : const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    );
  }
}
