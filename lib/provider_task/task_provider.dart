import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class Task {
  String title;
  bool done;
  DateTime? dueDate;
  TimeOfDay? dueTime;  // 1. MANEJO DE HORA: Campo para almacenar la hora de vencimiento de la tarea
  int? notificationId; // 2. IDENTIFICADOR DE NOTIFICACION: Campo para guardar el ID de la notificación asociada

  Task({
    required this.title,
    this.done = false,
    this.dueDate,
    this.dueTime,       // 1. MANEJO DE HORA: Se recibe como parámetro opcional
    this.notificationId, // 2. IDENTIFICADOR DE NOTIFICACION: Se recibe como parámetro opcional
  });
}

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  void addTask(String title, {DateTime? dueDate, TimeOfDay? dueTime, int? notificationId}) {
    _tasks.insert(0, Task(
      title: title,
      dueDate: dueDate,
      dueTime: dueTime,       // 1. MANEJO DE HORA: Se pasa la hora al crear la tarea
      notificationId: notificationId, // 2. IDENTIFICADOR DE NOTIFICACION: Se pasa el ID al crear la tarea
    ));
    notifyListeners();
  }

  void toggleTask(int index) {
    _tasks[index].done = !_tasks[index].done;
    notifyListeners();
  }

  void removeTask(int index) {
    final task = _tasks[index];
    if (task.notificationId != null) {
      // 3. CANCELACION DE NOTIFICACION: Se cancela la notificación al eliminar la tarea
      // Es importante para evitar que queden notificaciones programadas para tareas eliminadas
      NotificationService.cancelNotification(task.notificationId!);
    }
    _tasks.removeAt(index);
    notifyListeners();
  }

  void updateTask(int index, String newTitle, {DateTime? newDate, TimeOfDay? newTime, int? notificationId}) {
    final task = _tasks[index];

    // 3. CANCELACION DE NOTIFICACION: Se cancela la notificación previa al actualizar
    // Es importante para evitar duplicados cuando se actualiza una tarea con nueva notificación
    if (task.notificationId != null) {
      NotificationService.cancelNotification(task.notificationId!);
    }

    _tasks[index].title = newTitle;
    _tasks[index].dueDate = newDate;
    _tasks[index].dueTime = newTime;       // 1. MANEJO DE HORA: Se actualiza la hora
    _tasks[index].notificationId = notificationId; // 2. IDENTIFICADOR DE NOTIFICACION: Se actualiza el ID

    notifyListeners();
  }
}