import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stalhub/view_model/tasks/task_view_model.dart';
import '../../../data/models/task_model.dart';
import '../../../view_model/auth/login_view_model.dart';  // ✅ Add this

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _taskNameController;
  late TextEditingController _clientNameController;
  late TextEditingController _assignedToController;
  late TextEditingController _priceController;
  late TextEditingController _statusController;
  late TextEditingController _platformController;
  late TextEditingController _fileLinkController;
  late TextEditingController _notesController;

  late DateTime _createdAt;
  DateTime? _dueDate;

  bool _isEditing = false;

  final List<String> allowedStatuses = [
    'Delivered',
    'Working',
    'Quality Checking',
    'Postponed',
    'Revision',
    'Discarded',
    'To Be Assigned',
    'To Be Delivered'
  ];

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _taskNameController = TextEditingController(text: task.taskName);
    _clientNameController = TextEditingController(text: task.clientName);
    _assignedToController = TextEditingController(text: task.assignedTo);
    _priceController = TextEditingController(text: task.price.toString());
    _statusController = TextEditingController(text: task.status);
    _platformController = TextEditingController(text: task.platform);
    _fileLinkController = TextEditingController(text: task.fileLink);
    _notesController = TextEditingController(text: task.notes);
    _createdAt = task.createdAt;
    _dueDate = task.dueDate;
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState?.validate() != true || _dueDate == null) return;

    final enteredStatus = _statusController.text.trim();

    if (!allowedStatuses.contains(enteredStatus)) {
      _showDialog("Invalid Status",
          "The status you entered is not allowed.\n\nAllowed statuses:\n• ${allowedStatuses.join('\n• ')}");
      return;
    }

    final updatedTask = Task(
      id: widget.task.id,
      taskName: _taskNameController.text,
      clientName: _clientNameController.text,
      assignedTo: _assignedToController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      status: enteredStatus,
      platform: _platformController.text,
      createdAt: _createdAt,
      dueDate: _dueDate!,
      fileLink: _fileLinkController.text,
      notes: _notesController.text,
    );

    // ✅ Inject userId and playerId
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final vm = TaskViewModel(
      userId: loginVM.loggedInUser?.id ?? '',
      playerId: loginVM.loggedInUser?.playerId ?? '',
    );

    await vm.updateTask(widget.task.id, updatedTask.toMap());

    if (context.mounted) {
      setState(() => _isEditing = false);
      _showDialog("Success!", "Task updated successfully.");
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Are you sure?", style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold)),
        content: const Text("This task will be permanently deleted."),
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
      // ✅ Inject userId and playerId
      final loginVM = Provider.of<LoginViewModel>(context, listen: false);
      final vm = TaskViewModel(
        userId: loginVM.loggedInUser?.id ?? '',
        playerId: loginVM.loggedInUser?.playerId ?? '',
      );

      await vm.deleteTask(widget.task.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _showDialog(String title, String content) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset('assets/images/stalwrites-logo.png', width: 122, height: 68),
            Container(
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _labelText("Task ID: ${widget.task.id}", bold: true),
                    const SizedBox(height: 8),
                    _textInput("Task Name", controller: _taskNameController, enabled: _isEditing),
                    _textInput("Client Name", controller: _clientNameController, enabled: _isEditing),
                    _textInput("Assigned To", controller: _assignedToController, enabled: _isEditing),
                    _textInput("Price", controller: _priceController, keyboard: TextInputType.number, enabled: _isEditing),
                    _textInput("Status", controller: _statusController, enabled: _isEditing),
                    _textInput("Platform", controller: _platformController, enabled: _isEditing),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _labelText(DateFormat.yMMMd().format(_createdAt))),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
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
                                    if (picked != null) {
                                      setState(() => _dueDate = picked);
                                    }
                                  }
                                : null,
                            child: Text(_dueDate == null ? "Select Due" : DateFormat.yMMMd().format(_dueDate!)),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    _textInput("File Link (optional)", controller: _fileLinkController, enabled: _isEditing),
                    const SizedBox(height: 8),
                    _textInput("Notes (optional)", controller: _notesController, maxLines: 3, enabled: _isEditing),
                    const SizedBox(height: 20),
                    _button(_isEditing ? "Update" : "Edit Task", const Color.fromARGB(255, 26, 26, 26), () {
                      if (_isEditing) {
                        _updateTask();
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
                      _button("Delete Task", const Color(0xFFFF0000), _deleteTask),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textInput(String hint, {TextEditingController? controller, int maxLines = 1, TextInputType? keyboard, bool enabled = true}) {
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
            fontWeight: FontWeight.w400,
            color: isOutline ? Colors.black.withAlpha(204) : const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    );
  }
}
