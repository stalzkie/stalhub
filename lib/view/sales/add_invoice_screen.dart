import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stalhub/view_model/auth/login_view_model.dart';
import 'package:stalhub/view_model/sales/invoice_view_model.dart';
import '../../../data/models/invoice_model.dart';

class AddInvoiceScreen extends StatefulWidget {
  const AddInvoiceScreen({super.key});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _statusController = TextEditingController();
  final _platformController = TextEditingController();
  final _notesController = TextEditingController();

  final DateTime _createdAt = DateTime.now();
  DateTime? _dueDate;
  int? _invoiceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchNextInvoiceId());
  }

  Future<void> _fetchNextInvoiceId() async {
    final vm = context.read<InvoiceViewModel>();  // ✅ Use existing provider
    await vm.fetchInvoices();
    final invoices = vm.allInvoices;
    setState(() {
      _invoiceId = invoices.isEmpty ? 1 : invoices.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_dueDate == null || _invoiceId == null) return;

    final invoice = Invoice(
      id: _invoiceId!,
      clientName: _clientNameController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      status: _statusController.text,
      platform: _platformController.text,
      dueDate: _dueDate!,
      notes: _notesController.text,
      createdAt: _createdAt,
    );
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final vm = InvoiceViewModel(
      userId: loginVM.loggedInUser?.id ?? '',
      playerId: loginVM.loggedInUser?.playerId ?? '',
    );

    await vm.addInvoice(invoice);  // ✅ PlayerId injected

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _invoiceId == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Image.asset(
                            'assets/images/stalwrites-logo.png',
                            width: 122,
                            height: 68,
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
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
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _labelText("Invoice ID: $_invoiceId", bold: true),
                                    const SizedBox(height: 8),
                                    _textInput("Client Name", controller: _clientNameController),
                                    _textInput("Price", controller: _priceController, keyboard: TextInputType.number),
                                    _textInput("Status", controller: _statusController),
                                    _textInput("Platform", controller: _platformController),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(child: _labelText(DateFormat.yMMMd().format(_createdAt))),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              side: BorderSide(width: 2, color: Colors.black.withAlpha(128)),
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.black,
                                            ),
                                            onPressed: () async {
                                              final picked = await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(2020),
                                                lastDate: DateTime(2100),
                                              );
                                              if (picked != null) {
                                                setState(() => _dueDate = picked);
                                              }
                                            },
                                            child: Text(_dueDate == null ? "Select Due" : DateFormat.yMMMd().format(_dueDate!)),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _textInput("Notes (optional)", controller: _notesController, maxLines: 3),
                                    const SizedBox(height: 20),
                                    _button("Add Invoice", const Color.fromARGB(255, 26, 26, 26), _submitForm),
                                    const SizedBox(height: 10),
                                    _button("Go Back", Colors.white, () => Navigator.pop(context), isOutline: true),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _textInput(String hint, {TextEditingController? controller, int maxLines = 1, TextInputType? keyboard}) {
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
          if (hint.contains("optional")) return null;
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
            fontWeight: FontWeight.w500,
            color: isOutline ? Colors.black.withAlpha(204) : const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    );
  }
}
