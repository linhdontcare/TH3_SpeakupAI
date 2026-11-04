import 'package:flutter_test/flutter_test.dart';
import 'package:speakupai/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('SpeakUpAiApp launches and displays main navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const SpeakUpAiApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Luyện tập'), findsWidgets);
    expect(find.text('Tiến độ'), findsWidgets);
    expect(find.text('AI Lab'), findsWidgets);
    expect(find.text('Cài đặt'), findsWidgets);
  });
}
