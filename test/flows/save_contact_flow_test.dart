import 'package:bytebank/main.dart';
import 'package:bytebank/screens/contact_form.dart';
import 'package:bytebank/screens/contacts_list.dart';
import 'package:bytebank/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:bytebank/models/contact.dart';
import '../matchers/matchers.dart';
import '../mocks/mocks.dart';

void main() {
  MockContactDao mockContactDao;
  MockTransactionWebClient mockTransactionWebClient;

  setUp(() {
    mockContactDao = MockContactDao();
    mockTransactionWebClient = MockTransactionWebClient();
  });
  testWidgets('Should save a contact', (tester) async {
    await tester.pumpWidget(BytebankApp(
      contactDao: mockContactDao,
      transactionWebClient: mockTransactionWebClient,
    ));

    final dashboard = find.byType(Dashboard);
    expect(dashboard, findsOneWidget);

    final transferFeatureItem = find.byWidgetPredicate((widget) =>
        featureItemMatcher(widget, 'Transfer', Icons.monetization_on));
    expect(transferFeatureItem, findsOneWidget);
    await tester.tap(transferFeatureItem);
    await tester.pumpAndSettle();

    final contactsList = find.byType(ContactsList);
    expect(contactsList, findsOneWidget);

    verify(mockContactDao.findAll()).called(1); //verify verifica a chamada de
    //metodos

    final fabNewContact = find.widgetWithIcon(FloatingActionButton, Icons.add);
    expect(fabNewContact, findsOneWidget);
    await tester.tap(fabNewContact);
    await tester.pumpAndSettle();

    final contactForm = find.byType(ContactForm);
    expect(contactForm, findsOneWidget);

    final nameTextField = find.byWidgetPredicate((widget) {
      return textFieldWithLabel(widget, 'Full name');
    });
    expect(nameTextField, findsOneWidget);
    await tester.enterText(nameTextField, 'Alex');

    final accountNumberTextField = find.byWidgetPredicate((widget) {
      return textFieldWithLabel(widget, 'Account number');
    });
    expect(accountNumberTextField, findsOneWidget);
    await tester.enterText(accountNumberTextField, '9867');

    final createButton = find.widgetWithText(RaisedButton, 'Create');
    expect(createButton, findsOneWidget);
    await tester.tap(createButton);

    verify(mockContactDao.save(Contact(0, 'Alex', 9867)));
    await tester.pumpAndSettle();

    final contactsListBack = find.byType(ContactsList);

    expect(contactsListBack, findsOneWidget);

    verify(mockContactDao.findAll()).called(1);
  });
}
