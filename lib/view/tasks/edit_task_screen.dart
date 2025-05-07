import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/task_model.dart';
import '../../../view_model/tasks/task_view_model.dart';
import 'package:stalhub/view/widgets/status_indicator.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _submitted = false;
  bool _isLoading = false;

  late TextEditingController _taskNameController;
  late TextEditingController _clientNameController;
  late TextEditingController _assignedToController;
  late TextEditingController _priceController;
  late TextEditingController _platformController;
  late TextEditingController _fileLinkController;
  late TextEditingController _notesController;

  late DateTime _createdAt;
  DateTime? _dueDate;
  late String _selectedStatus;

  final List<String> _statusOptions = [
    'Delivered',
    'Working',
    'Quality Checking',
    'Postponed',
    'Revision',
    'Discarded',
    'To Be Assigned',
    'To Be Delivered',
  ];

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _taskNameController = TextEditingController(text: task.taskName);
    _clientNameController = TextEditingController(text: task.clientName);
    _assignedToController = TextEditingController(text: task.assignedTo);
    _priceController = TextEditingController(text: task.price.toString());
    _platformController = TextEditingController(text: task.platform);
    _fileLinkController = TextEditingController(text: task.fileLink);
    _notesController = TextEditingController(text: task.notes);
    _createdAt = task.createdAt;
    _dueDate = task.dueDate;
    _selectedStatus = task.status;
  }

  void _showDialog(String title, String content) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  Future<void> _updateTask() async {
    if (_isLoading) return;
    setState(() {
      _submitted = true;
      _isLoading = true;
    });

    final isEmpty = _taskNameController.text.isEmpty ||
        _clientNameController.text.isEmpty ||
        _assignedToController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _platformController.text.isEmpty ||
        _dueDate == null;

    if (isEmpty) {
      _showDialog("Invalid Input", "Please fill up all the required information.");
      setState(() => _isLoading = false);
      return;
    }

    final parsedPrice = double.tryParse(_priceController.text);
    if (parsedPrice == null) {
      _showDialog("Invalid Input", "Please enter a valid number for Price.");
      setState(() => _isLoading = false);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }

    final updatedTask = Task(
      id: widget.task.id,
      taskName: _taskNameController.text,
      clientName: _clientNameController.text,
      assignedTo: _assignedToController.text,
      price: parsedPrice,
      status: _selectedStatus,
      platform: _platformController.text,
      fileLink: _fileLinkController.text,
      notes: _notesController.text,
      createdAt: _createdAt,
      dueDate: _dueDate!,
    );

    final vm = context.read<TaskViewModel>();
    await vm.updateTask(widget.task.id, updatedTask.toMap());

    if (!mounted) return;
    setState(() {
      _isEditing = false;
      _isLoading = false;
    });
    _showDialog("Success!", "Task updated successfully.");
  }

  Future<void> _deleteTask() async {
    if (_isLoading) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Are you sure?", style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold)),
        content: const Text("This task will be permanently deleted."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final vm = context.read<TaskViewModel>();
      await vm.deleteTask(widget.task.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                    _label("Task ID: ${widget.task.id}", 20, FontWeight.w600),
                    _input("Task Name", _taskNameController, enabled: _isEditing),
                    _input("Client Name", _clientNameController, enabled: _isEditing),
                    _input("Assigned To", _assignedToController, enabled: _isEditing),
                    _input("Price", _priceController, keyboard: TextInputType.number, enabled: _isEditing),
                    _dropdownStatusField(),
                    _input("Platform", _platformController, enabled: _isEditing),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _label("Created: ${DateFormat.yMMMd().format(_createdAt)}", 14, FontWeight.w500)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isEditing ? Colors.white : Colors.grey.shade200,
                              foregroundColor: Colors.black,
                              side: BorderSide(
                                color: (_dueDate == null && _submitted)
                                    ? Colors.red
                                    : Colors.black.withAlpha(128),
                                width: 2,
                              ),
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
                    _input("File Link (optional)", _fileLinkController, enabled: _isEditing),
                    _input("Notes (optional)", _notesController, maxLines: 3, enabled: _isEditing),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
            if (_isLoading)
              Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(child: CircularProgressIndicator(
                    color: Color(0xFFFF7240),
                    strokeWidth: 6,
                  ),),
              ),
          ],
        ),
      ),
    );
  }

  Widget _input(String hint, TextEditingController controller,
      {int maxLines = 1, TextInputType? keyboard, bool enabled = true}) {
    final isOptional = hint.toLowerCase().contains("optional");

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
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: (_submitted && !isOptional && controller.text.isEmpty && enabled)
                ? const BorderSide(color: Colors.red)
                : BorderSide.none,
          ),
        ),
        validator: (value) {
          if (isOptional || !enabled) return null;
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
                onChanged: _isEditing ? (value) => setState(() => _selectedStatus = value!) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, double size, FontWeight weight) {
    return Text(text, style: TextStyle(fontSize: size, fontWeight: weight, fontFamily: 'Figtree'));
  }

  Widget _buildBottomActions() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x00F9F9F9), Color(0xFFF9F9F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 25),
          color: const Color(0xFFF9F9F9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _bottomButton(
                label: _isEditing ? "Update" : "Edit Task",
                color: const Color(0xFFFF7240),
                onTap: () {
                  if (_isEditing) {
                    _updateTask();
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
                  label: "Delete Task",
                  color: const Color(0xFFFF0000),
                  onTap: _deleteTask,
                ),
            ],
          ),
        ),
      ),
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
            color: isOutline ? textColor : Colors.black,
          ),
        ),
      ),
    );
  }
}
