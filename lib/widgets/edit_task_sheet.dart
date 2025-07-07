import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider_task/task_provider.dart';
import '../services/notification_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditTaskSheet extends StatefulWidget {
  final int index;

  const EditTaskSheet({super.key, required this.index});

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late TextEditingController _controller;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final task = Provider.of<TaskProvider>(context, listen: false).tasks[widget.index];
    _controller = TextEditingController(text: task.title);
    _selectedDate = task.dueDate;
    _selectedTime = task.dueDate != null 
        ? TimeOfDay.fromDateTime(task.dueDate!)
        : TimeOfDay.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    final newTitle = _controller.text.trim();
    if (newTitle.isEmpty) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final task = taskProvider.tasks[widget.index];
    final localizations = AppLocalizations.of(context)!;

    // Cancelar notificación existente
    if (task.notificationId != null) {
      await NotificationService.cancelNotification(task.notificationId!);
    }

    // Generar nuevo ID de notificación
    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    // Mostrar notificación inmediata
    await NotificationService.showImmediateNotification(
      title: localizations.taskUpdatedNotification,
      body: localizations.taskUpdatedBody(newTitle),
      notificationId: notificationId, payload: '',
    );

    DateTime? finalDueDate;

    // Programar notificación si hay fecha/hora
    if (_selectedDate != null && _selectedTime != null) {
      finalDueDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      
      await NotificationService.scheduleNotification(
        title: localizations.updatedReminder(newTitle),
        body: localizations.taskUpdatedBody(newTitle),
        scheduledDate: finalDueDate,
        notificationId: notificationId,
      );
    }

    // Actualizar tarea
    taskProvider.updateTask(
      widget.index,
      newTitle,
      newDate: finalDueDate,
      notificationId: notificationId,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localizations.editTaskTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: localizations.titleLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _pickDate,
                child: Text(localizations.changeDate),
              ),
              Text(
                _selectedDate != null 
                    ? DateFormat.yMd(Localizations.localeOf(context).toString()).format(_selectedDate!)
                    : localizations.noDueDate,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _pickTime,
                child: Text(localizations.changeTime),
              ),
              Text(
                _selectedTime != null 
                    ? _selectedTime!.format(context)
                    : localizations.noTime,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text(localizations.saveChanges),
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}