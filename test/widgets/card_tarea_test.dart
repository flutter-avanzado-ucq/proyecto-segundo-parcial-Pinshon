// Importaciones básicas de Flutter
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Importaciones para internacionalización
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Importaciones de la aplicación
import 'package:flutter_animaciones_notificaciones/widgets/card_tarea.dart';
import 'package:flutter_animaciones_notificaciones/models/task_model.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/holiday_provider.dart';

void main() {
  // 🧪 Test principal: Verifica que TaskCard muestra el título y responde a interacciones
  testWidgets('TaskCard muestra el título y responde al botón de check', (WidgetTester tester) async {
    // Variables para rastrear llamadas a callbacks
    bool fueMarcado = false;    // Para el checkbox
    bool fueEditado = false;   // Para el botón de editar
    bool fueEliminado = false; // Para el botón de eliminar

    // Construye y renderiza el widget bajo prueba
    await tester.pumpWidget(
      MaterialApp(
        // Configuración para internacionalización
        localizationsDelegates: const [
          AppLocalizations.delegate,          // Delegado para traducciones de la app
          GlobalMaterialLocalizations.delegate, // Delegado para Material Design
          GlobalWidgetsLocalizations.delegate, // Delegado para widgets básicos
          GlobalCupertinoLocalizations.delegate, // Delegado para estilo iOS
        ],
        supportedLocales: const [Locale('es')], // Solo español
        home: ChangeNotifierProvider<HolidayProvider>(
          // Proveedor de feriados (aunque no se usa directamente en este test)
          create: (_) => HolidayProvider(),
          child: Scaffold(
            body: TaskCard(
              // Tarea de prueba con valores predeterminados
              task: Task(
                title: 'Tarea de prueba', // Título visible
                done: false,              // Estado inicial no completada
                dueDate: DateTime.now(),  // Fecha actual como vencimiento
              ),
              // Callbacks para probar interacciones
              onToggle: () => fueMarcado = true,   // Al marcar/desmarcar
              onEdit: () => fueEditado = true,    // Al editar
              onDelete: () => fueEliminado = true, // Al eliminar
            ),
          ),
        ),
      ),
    );

    // ⏳ Espera a que se completen todas las animaciones
    await tester.pumpAndSettle();

    // ✅ Verificación 1: El título de la tarea se muestra correctamente
    expect(find.text('Tarea de prueba'), findsOneWidget);

    // ✅ Verificación 2: El checkbox refleja el estado inicial (no marcado)
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, false);

    // 🖱️ Prueba de interacción 1: Marcar la tarea como completada
    await tester.tap(find.byType(Checkbox));
    await tester.pump(); // Procesa el frame después del tap
    expect(fueMarcado, true); // Verifica que se llamó al callback

    // ✏️ Prueba de interacción 2: Botón de editar
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();
    expect(fueEditado, true); // Verifica que se llamó al callback

    // 🗑️ Prueba de interacción 3: Botón de eliminar
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    expect(fueEliminado, true); // Verifica que se llamó al callback
  });
}