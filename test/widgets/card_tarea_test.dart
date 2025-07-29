import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_animaciones_notificaciones/widgets/card_tarea.dart';
import 'package:flutter_animaciones_notificaciones/models/task_model.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/holiday_provider.dart';

void main() {
  testWidgets('TaskCard muestra el título y responde al botón de check', (WidgetTester tester) async {
    bool fueMarcado = false;
    bool fueEditado = false;
    bool fueEliminado = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es')],
        home: ChangeNotifierProvider<HolidayProvider>(
          create: (_) => HolidayProvider(),
          child: Scaffold(
            body: TaskCard(
              task: Task(
                title: 'Tarea de prueba',
                done: false,
                dueDate: DateTime.now(),
              ),
              onToggle: () => fueMarcado = true,
              onEdit: () => fueEditado = true,
              onDelete: () => fueEliminado = true,
            ),
          ),
        ),
      ),
    );

    // Espera a que se completen todas las animaciones
    await tester.pumpAndSettle();

    // Verifica que el texto está en pantalla
    expect(find.text('Tarea de prueba'), findsOneWidget);

    // Verifica el checkbox
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, false);

    // Prueba interacción con el checkbox
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(fueMarcado, true);

    // Prueba botón de editar
    await tester.tap(find.byIcon(Icons.edit));
    expect(fueEditado, true);

    // Prueba botón de eliminar
    await tester.tap(find.byIcon(Icons.delete));
    expect(fueEliminado, true);
  });
}