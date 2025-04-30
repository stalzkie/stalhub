import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/ticket_model.dart';
import '../../../view_model/tickets/ticket_view_model.dart';
import '../../../view_model/auth/login_view_model.dart'; // ✅ Add this for userId & playerId

class AddTicketScreen extends StatefulWidget {
  const AddTicketScreen({super.key});

  @override
  State<AddTicketScreen> createState() => _AddTicketScreenState();
}

class _AddTicketScreenState extends State<AddTicketScreen> {
  final _formKey = GlobalKey<FormState>();

  final _clientNameController = TextEditingController();
  final _statusController = TextEditingController();
  final _platformController = TextEditingController();
  final _contentController = TextEditingController();

  final DateTime _createdAt = DateTime.now();
  late DateTime _updatedAt;
  int? _ticketId;

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
    if (_formKey.currentState?.validate() != true || _ticketId == null) return;

    final ticket = Ticket(
      id: _ticketId!,
      clientName: _clientNameController.text,
      status: _statusController.text,
      platform: _platformController.text,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
      content: _contentController.text,
    );

    // ✅ Inject userId & playerId into TicketViewModel
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final vm = TicketViewModel(
      userId: loginVM.loggedInUser?.id ?? '',
      playerId: loginVM.loggedInUser?.playerId ?? '',
    );

    await vm.addTicket(ticket); // ✅ Notifications work here
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _ticketId == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                            _labelText("Ticket ID: $_ticketId", bold: true),
                            const SizedBox(height: 8),
                            _textInput("Client Name", controller: _clientNameController),
                            _textInput("Status", controller: _statusController),
                            _textInput("Platform", controller: _platformController),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _labelText("Created: ${DateFormat.yMMMd().format(_createdAt)}"),
                                _labelText("Updated: ${DateFormat.yMMMd().format(_updatedAt)}"),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _textInput("Content", controller: _contentController, maxLines: 5),
                            const SizedBox(height: 20),
                            _button("Add Ticket", const Color.fromARGB(255, 26, 26, 26), _submitForm),
                            const SizedBox(height: 10),
                            _button("Go Back", Colors.white, () => Navigator.pop(context), isOutline: true),
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
      {TextEditingController? controller, int maxLines = 1, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
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
          return (value == null || value.isEmpty) ? "Required" : null;
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
