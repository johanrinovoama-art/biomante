import 'package:flutter_test/flutter_test.dart';
import 'package:biomante/main.dart';

void main() {
  testWidgets('Biomante muestra el panel principal', (tester) async {
    await tester.pumpWidget(const BiomanteApp());
    await tester.pumpAndSettle();

    expect(find.text('Panel principal'), findsOneWidget);
    expect(find.text('Sistema de mantenimiento biomédico'), findsOneWidget);
    expect(find.text('Ver mis equipos'), findsOneWidget);
  });
}
