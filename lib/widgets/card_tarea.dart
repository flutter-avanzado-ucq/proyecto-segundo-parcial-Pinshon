import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../provider_task/holiday_provider.dart'; // Nuevo 24 de julio

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final holidays = context.watch<HolidayProvider>().holidays;
    final isHoliday = task.dueDate != null &&
        holidays != null &&
        holidays.any((h) =>
            h.date.year == task.dueDate!.year &&
            h.date.month == task.dueDate!.month &&
            h.date.day == task.dueDate!.day);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.done,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: task.dueDate != null
            ? Builder(
                builder: (context) {
                  final locale = Localizations.localeOf(context).toString();
                  final dateText = Text(
                    '${DateFormat.yMd(locale).format(task.dueDate!)} ${DateFormat.Hm(locale).format(task.dueDate!)}',
                    style: const TextStyle(color: Colors.grey),
                  );
                  if (isHoliday) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        dateText,
                        Text(
                          localizations.holidayTag, // Replace 'holidayTag' with the correct getter name from your localization file
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return dateText;
                  }
                },
              )
            : null,
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
