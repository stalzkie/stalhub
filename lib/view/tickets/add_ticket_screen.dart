import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/ticket_model.dart';
import '../../../view_model/tickets/ticket_view_model.dart';
import 'package:stalhub/view/widgets/status_indicator.dart';

class AddTicketScreen extends StatefulWidget {
  const AddTicketScreen({super.key});

  @override
  State<AddTicketScreen> createState() => _AddTicketScreenState();
}

class _AddTicketScreenState extends State<AddTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _platformController = TextEditingController();
  final _contentController = TextEditingController();

  final DateTime _createdAt = DateTime.now();
  late DateTime _updatedAt;
  int? _ticketId;

  bool _submitted = false;

  String _selectedStatus = 'Not Read';
  final List<String> _statusOptions = ['Not Read', 'Ongoing', 'Resolved', 'Discarded'];

  @override
  void initState() {
    super.initState();
    _updatedAt = _createdAt;
    _fetchNextTicketId();
  }

  Future<void> _fetchNextTicketId() async {
    final vm = Provider.of<TicketViewModel>(context, listen: false);
    await vm.fetchTickets();
    final tickets = vm.allTickets;
    setState(() {
      _ticketId = tickets.isEmpty
          ? 1
          : tickets.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
    });
  }

  Future<void> _submitForm() async {
    setState(() => _submitted = true);

    final isEmptyRequired = _clientNameController.text.isEmpty ||
        _platformController.text.isEmpty ||
        _contentController.text.isEmpty;

    if (isEmptyRequired || _ticketId == null) {
      _showErrorDialog("Please fill up all the required information.");
      return;
    }

    if (_formKey.currentState?.validate() != true) return;

    final ticket = Ticket(
      id: _ticketId!,
      clientName: _clientNameController.text,
      status: _selectedStatus,
      platform: _platformController.text,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
      content: _contentController.text,
    );

    final vm = Provider.of<TicketViewModel>(context, listen: false);
    await vm.addTicket(ticket);

    if (context.mounted) Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: _ticketId == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                        autovalidateMode: _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label("Ticket ID: $_ticketId", 20, FontWeight.w600),
                            _input("Client Name", _clientNameController),
                            _dropdownStatusField(),
                            _input("Platform", _platformController),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _label("Created: ${DateFormat.yMMMd().format(_createdAt)}", 14, FontWeight.w500)),
                                const SizedBox(width: 10),
                                Expanded(child: _label("Updated: ${DateFormat.yMMMd().format(_updatedAt)}", 14, FontWeight.w500)),
                              ],
                            ),
                            _input("Content", _contentController, maxLines: 5),
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
        child: GestureDetector(
          onTap: _submitForm,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7240),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black.withAlpha(204), width: 2),
            ),
            child: const Text(
              'Add Ticket',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String hint, TextEditingController controller,
      {int maxLines = 1, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: (_submitted && controller.text.isEmpty)
                ? const BorderSide(color: Colors.red)
                : BorderSide.none,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w500,
              ),
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
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
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
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: 'Figtree',
      ),
    );
  }
}
