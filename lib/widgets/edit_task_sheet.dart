import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider_task/task_provider.dart';
import '../services/notification_service.dart';

class EditTaskSheet extends StatefulWidget {
  final int index;

  const EditTaskSheet({super.key, required this.index});

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late TextEditingController _controller;
  DateTime? _selectedDate;  // 1. MANEJO DE HORA: Almacena la fecha de la tarea
  TimeOfDay? _selectedTime; // 1. MANEJO DE HORA: Almacena la hora de la tarea

  @override
  void initState() {
    super.initState();
    final task = Provider.of<TaskProvider>(context, listen: false).tasks[widget.index];
    _controller = TextEditingController(text: task.title);
    _selectedDate = task.dueDate; // 1. MANEJO DE HORA: Obtiene fecha existente
    _selectedTime = task.dueTime ?? const TimeOfDay(hour: 8, minute: 0); // 1. MANEJO DE HORA: Obtiene hora existente o establece default
  }

  void _submit() async {
    final newTitle = _controller.text.trim();
    if (newTitle.isNotEmpty) {
      int? notificationId;

      final task = Provider.of<TaskProvider>(context, listen: false).tasks[widget.index];

      // 3. CANCELACION DE NOTIFICACION: Cancela la notificación existente antes de actualizar
      // Es importante para evitar notificaciones duplicadas
      if (task.notificationId != null) {
        await NotificationService.cancelNotification(task.notificationId!);
      }

      await NotificationService.showImmediateNotification(
        title: 'Tarea actualizada',
        body: 'Has actualizado la tarea: $newTitle',
        payload: 'Tarea actualizada: $newTitle',
      );

      // 1. MANEJO DE HORA: Si hay fecha y hora seleccionadas, programa nueva notificación
      if (_selectedDate != null && _selectedTime != null) {
        final scheduledDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,    // 1. MANEJO DE HORA: Usa la hora seleccionada
          _selectedTime!.minute,  // 1. MANEJO DE HORA: Usa los minutos seleccionados
        );

        // 2. IDENTIFICADOR: Genera un nuevo ID único basado en timestamp
        notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

        await NotificationService.scheduleNotification(
          title: 'Recordatorio de tarea actualizada',
          body: 'No olvides: $newTitle',
          scheduledDate: scheduledDateTime,
          payload: 'Tarea actualizada: $newTitle para $scheduledDateTime',
          notificationId: notificationId, // 2. IDENTIFICADOR: Asigna el nuevo ID
        );
      }

      Provider.of<TaskProvider>(context, listen: false).updateTask(
        widget.index,
        newTitle,
        newDate: _selectedDate,    // 1. MANEJO DE HORA: Pasa la nueva fecha
        newTime: _selectedTime,    // 1. MANEJO DE HORA: Pasa la nueva hora
        notificationId: notificationId, // 2. IDENTIFICADOR: Pasa el nuevo ID
      );

      Navigator.pop(context);
    }
  }

  // 1. MANEJO DE HORA: Método para actualizar fecha
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 1. MANEJO DE HORA: Método para actualizar hora
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          const Text('Editar tarea', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          // 1. MANEJO DE HORA: Selector de fecha
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickDate,
                child: const Text('Cambiar fecha'),
              ),
              const SizedBox(width: 10),
              if (_selectedDate != null)
                Text('${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            ],
          ),
          const SizedBox(height: 12),
          // 1. MANEJO DE HORA: Selector de hora
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickTime,
                child: const Text('Cambiar hora'),
              ),
              const SizedBox(width: 10),
              const Text('Hora: '),
              if (_selectedTime != null)
                Text('${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check),
            label: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}