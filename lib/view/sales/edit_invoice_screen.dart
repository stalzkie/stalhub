import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/invoice_model.dart';
import '../../../view_model/sales/invoice_view_model.dart';
import 'package:stalhub/view/widgets/status_indicator.dart';

class EditInvoiceScreen extends StatefulWidget {
  final Invoice invoice;

  const EditInvoiceScreen({super.key, required this.invoice});

  @override
  State<EditInvoiceScreen> createState() => _EditInvoiceScreenState();
}

class _EditInvoiceScreenState extends State<EditInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientNameController;
  late TextEditingController _priceController;
  late TextEditingController _platformController;
  late TextEditingController _notesController;

  late DateTime _createdAt;
  DateTime? _dueDate;
  String _selectedStatus = 'Paid';

  bool _isEditing = false;
  bool _submitted = false;
  bool _isLoading = false;

  final List<String> _statusOptions = ['Paid', 'Unpaid', 'Discarded'];

  @override
  void initState() {
    super.initState();
    final invoice = widget.invoice;
    _clientNameController = TextEditingController(text: invoice.clientName);
    _priceController = TextEditingController(text: invoice.price.toString());
    _platformController = TextEditingController(text: invoice.platform);
    _notesController = TextEditingController(text: invoice.notes ?? '');
    _createdAt = invoice.createdAt;
    _dueDate = invoice.dueDate;
    _selectedStatus = invoice.status;
  }

  Future<void> _updateInvoice() async {
    setState(() {
      _submitted = true;
      _isLoading = true;
    });

    final isEmpty = _clientNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _platformController.text.isEmpty ||
        _dueDate == null;

    if (isEmpty) {
      _showErrorDialog("Please fill up all the required information.");
      setState(() => _isLoading = false);
      return;
    }

    final parsedPrice = double.tryParse(_priceController.text);
    if (parsedPrice == null) {
      _showErrorDialog("Please enter a valid number for Price.");
      setState(() => _isLoading = false);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }

    final updated = widget.invoice.copyWith(
      clientName: _clientNameController.text,
      price: parsedPrice,
      status: _selectedStatus,
      platform: _platformController.text,
      dueDate: _dueDate!,
      notes: _notesController.text,
    );

    final vm = context.read<InvoiceViewModel>();
    await vm.updateInvoice(updated.id, updated.toMap());
    await vm.fetchInvoices();

    if (context.mounted) {
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Success!", style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold)),
          content: const Text("Invoice updated successfully."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close", style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      );
    }
  }

  Future<void> _deleteInvoice() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Are you sure?", style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold)),
        content: const Text("This invoice will be permanently deleted."),
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
      setState(() => _isLoading = true);
      final vm = context.read<InvoiceViewModel>();
      await vm.deleteInvoice(widget.invoice.id);
      await vm.fetchInvoices();
      if (context.mounted) Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 150),
              child: Form(
                key: _formKey,
                autovalidateMode: _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/images/back-button-icon.png', width: 32, height: 32),
                    ),
                    const SizedBox(height: 20),
                    Text("Invoice ID: ${widget.invoice.id}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Figtree')),
                    _input("Client Name", _clientNameController, enabled: _isEditing),
                    _input("Price", _priceController, keyboard: TextInputType.number, enabled: _isEditing),
                    _dropdownStatusField(),
                    _input("Platform", _platformController, enabled: _isEditing),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Text("Created: ${DateFormat.yMMMd().format(_createdAt)}")),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isEditing ? Colors.white : Colors.grey.shade200,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: _isEditing
                                ? () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _dueDate ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) setState(() => _dueDate = picked);
                                  }
                                : null,
                            child: Text(_dueDate == null ? "Select Due Date" : DateFormat.yMMMd().format(_dueDate!)),
                          ),
                        ),
                      ],
                    ),
                    _input("Notes (optional)", _notesController, maxLines: 3, enabled: _isEditing),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _bottomButton(
                  label: _isEditing ? "Update" : "Edit Invoice",
                  color: const Color(0xFFFF7240),
                  onTap: _isLoading
                      ? null
                      : () {
                          if (_isEditing) {
                            _updateInvoice();
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
                    onTap: _isLoading ? null : () => setState(() => _isEditing = false),
                    isOutline: true,
                  ),
                const SizedBox(height: 10),
                if (_isEditing)
                  _bottomButton(
                    label: "Delete Invoice",
                    color: const Color(0xFFFF0000),
                    onTap: _isLoading ? null : _deleteInvoice,
                  ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.white.withOpacity(0.8),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7240)),
              ),
            ),
          ),
      ],
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
        validator: (value) => (value == null || value.isEmpty) && enabled ? "Required" : null,
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
            const Text('Status', style: TextStyle(fontSize: 14, fontFamily: 'Figtree', fontWeight: FontWeight.w500)),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                items: _statusOptions.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: StatusIndicator(status: status),
                  );
                }).toList(),
                onChanged: _isEditing ? (val) => setState(() => _selectedStatus = val!) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomButton({
    required String label,
    required Color color,
    required VoidCallback? onTap,
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
            color: isOutline ? textColor : const Color(0xFF000000),
          ),
        ),
      ),
    );
  }
}
