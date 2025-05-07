import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stalhub/view_model/sales/invoice_view_model.dart';
import 'package:stalhub/view/widgets/status_indicator.dart';
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
  final _platformController = TextEditingController();
  final _notesController = TextEditingController();

  final DateTime _createdAt = DateTime.now();
  DateTime? _dueDate;
  int? _invoiceId;
  String _selectedStatus = 'Paid';
  bool _submitted = false;
  bool _isLoading = false;

  final List<String> _statusOptions = ['Paid', 'Unpaid', 'Discarded'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchNextInvoiceId());
  }

  Future<void> _fetchNextInvoiceId() async {
    final vm = context.read<InvoiceViewModel>();
    await vm.fetchInvoices();
    final invoices = vm.allInvoices;
    setState(() {
      _invoiceId = invoices.isEmpty
          ? 1
          : invoices.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
    });
  }

  Future<void> _submitForm() async {
    setState(() => _submitted = true);

    final isEmptyRequiredField = _clientNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _platformController.text.isEmpty ||
        _dueDate == null;

    if (isEmptyRequiredField || _invoiceId == null) {
      _showErrorDialog("Please fill up all the required information.");
      return;
    }

    final parsedPrice = double.tryParse(_priceController.text);
    if (parsedPrice == null) {
      _showErrorDialog("Please enter a valid number for Price.");
      return;
    }

    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    final invoice = Invoice(
      id: _invoiceId!,
      clientName: _clientNameController.text,
      price: parsedPrice,
      status: _selectedStatus,
      platform: _platformController.text,
      dueDate: _dueDate!,
      notes: _notesController.text,
      createdAt: _createdAt,
    );

    final vm = context.read<InvoiceViewModel>();
    await vm.addInvoice(invoice);
    await vm.fetchInvoices(); // refresh the list

    if (context.mounted) {
      Navigator.pop(context, true); // return to invoice list
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Invalid Input"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          _invoiceId == null
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
                            autovalidateMode: _submitted
                                ? AutovalidateMode.always
                                : AutovalidateMode.disabled,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Invoice ID: $_invoiceId", 20, FontWeight.w600),
                                _input("Client Name", _clientNameController),
                                _input("Price", _priceController, keyboard: TextInputType.number),
                                _dropdownStatusField(),
                                _input("Platform", _platformController),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _label("Created: ${DateFormat.yMMMd().format(_createdAt)}", 14, FontWeight.w500),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          side: BorderSide(
                                            color: (_dueDate == null && _submitted)
                                                ? Colors.red
                                                : Colors.black.withAlpha(128),
                                            width: 2,
                                          ),
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
                                        child: Text(
                                          _dueDate == null
                                              ? "Select Due Date"
                                              : DateFormat.yMMMd().format(_dueDate!),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                _input("Notes (optional)", _notesController, maxLines: 3),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: SizedBox(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF7240), // Match your brand color
                    strokeWidth: 6,// Thicker ring
                  ),
                ),
              ),
            ),
        ],
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
              'Add Invoice',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String hint, TextEditingController controller,
      {int maxLines = 1, TextInputType? keyboard}) {
    final isOptional = hint.toLowerCase().contains("optional");

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
            borderSide: (_submitted && !isOptional && controller.text.isEmpty)
                ? const BorderSide(color: Colors.red)
                : BorderSide.none,
          ),
        ),
        validator: (value) {
          if (isOptional) return null;
          return (value == null || value.isEmpty) ? "Required" : null;
        },
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
