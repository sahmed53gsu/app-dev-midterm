import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:group_chat_app/main.dart' as app;
void main(){
  group('App Test',(){
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('full app test', (tester) async{
      app.main();
      await tester.pumpAndSettle();
      final emailFormField = find.byType(TextFormField).first;
      final passwordFormField = find.byType(TextFormField).last;
      final loginButton = find.byType(RaisedButton).first;
      final addGroupButton = find.byType(FloatingActionButton).first;
      final typeGroup = find.byKey(Key("typeGroup"));
      final addGroup = find.byType(FlatButton).last;


      await tester.enterText(emailFormField, 'test@gmail.com');
      await tester.enterText(passwordFormField, 'testgmail');
      await tester.pumpAndSettle();

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      await tester.tap(addGroupButton);
      await tester.pumpAndSettle();
      await tester.enterText(typeGroup, "test group");
      await tester.pumpAndSettle();
      await tester.tap(addGroup);
      await tester.pumpAndSettle();


    });
  });
}