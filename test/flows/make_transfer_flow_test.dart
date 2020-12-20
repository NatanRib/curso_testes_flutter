import 'package:bytebank/components/response_dialog.dart';
import 'package:bytebank/components/transaction_auth_dialog.dart';
import 'package:bytebank/main.dart';
import 'package:bytebank/models/contact.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:bytebank/screens/contacts_list.dart';
import 'package:bytebank/screens/dashboard.dart';
import 'package:bytebank/screens/transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../matchers/matchers.dart';
import '../mocks/mocks.dart';

void main() {
  MockContactDao mockContactDao;
  MockTransactionWebClient mockTransactionWebClient;

  setUp(() {
    mockContactDao = MockContactDao();
    mockTransactionWebClient = MockTransactionWebClient();
  });
  testWidgets('Should make a transfer', (tester) async {
    await tester.pumpWidget(BytebankApp(
      contactDao: mockContactDao,
      transactionWebClient: mockTransactionWebClient,
    ));

    final dashboard = find.byType(Dashboard);
    expect(dashboard, findsOneWidget);

    final transferFeatureItem = find.byWidgetPredicate((widget) =>
        featureItemMatcher(widget, 'Transfer', Icons.monetization_on));
    expect(transferFeatureItem, findsOneWidget);

    final alex = Contact(0, 'Alex', 1000);
    when(mockContactDao.findAll()).thenAnswer((realInvocation) async {
      return [alex];
    });

    await tester.tap(transferFeatureItem);
    await tester.pumpAndSettle();

    final contactsList = find.byType(ContactsList);
    expect(contactsList, findsOneWidget);

    verify(mockContactDao.findAll())
        .called(1); //verify verifica a chamada de funcoes

    final contactItem = find.byWidgetPredicate((widget) {
      if (widget is ContactItem) {
        return widget.contact.name == 'Alex' &&
            widget.contact.accountNumber == 1000;
      }
      return false;
    });

    expect(contactItem, findsOneWidget);

    await tester.tap(contactItem);
    await tester.pumpAndSettle();

    final transferForm = find.byType(TransactionForm);
    expect(transferForm, findsOneWidget);

    final contactName = find.text('Alex');
    expect(contactName, findsOneWidget);
    final contactAccountNumber = find.text('1000');
    expect(contactAccountNumber, findsOneWidget);

    final valueTextField =
        find.byWidgetPredicate((widget) => textFieldWithLabel(widget, 'Value'));
    expect(valueTextField, findsOneWidget);

    await tester.enterText(valueTextField, '200');

    final transferButton = find.widgetWithText(RaisedButton, 'Transfer');
    expect(transferButton, findsOneWidget);

    await tester.tap(transferButton);
    await tester.pumpAndSettle();

    final authenticationDialog = find.byType(TransactionAuthDialog);
    expect(authenticationDialog, findsOneWidget);

    final authenticatePassword =
        find.byKey(transferAuthenticatePasswordTextField);
    expect(authenticatePassword, findsOneWidget);

    await tester.enterText(authenticatePassword, '1234');

    final cancelButton = find.widgetWithText(FlatButton, 'Cancel');
    expect(cancelButton, findsOneWidget);
    final confirmButton = find.widgetWithText(FlatButton, 'Confirm');
    expect(confirmButton, findsOneWidget);

    when(mockTransactionWebClient.save(Transaction(null, 200, alex), '1234'))
        .thenAnswer((realInvocation) async => Transaction(null, 200, alex));

    await tester.tap(confirmButton);

    verify(mockTransactionWebClient.save(Transaction(null, 200, alex), '1234'))
        .called(1);

    await tester.pumpAndSettle();

    final dialogSuccess = find.byType(SuccessDialog);
    expect(dialogSuccess, findsOneWidget);

    final okButton = find.widgetWithText(FlatButton, 'Ok');
    expect(okButton, findsOneWidget);

    await tester.tap(okButton);
    await tester.pumpAndSettle();

    final contactListBack = find.byType(ContactsList);
    expect(contactListBack, findsOneWidget);
  });
}
