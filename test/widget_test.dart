import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tp6/main.dart';

void main() {
  testWidgets('Mostra pesquisa e identifica o aluno', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Enzo Akira Sasaki dos Santos'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Pesquisar'), findsOneWidget);
  });

  testWidgets('Pesquisa vazia orienta sem chamar a API', (tester) async {
    var chamadas = 0;
    final client = MockClient((request) async {
      chamadas++;
      return http.Response('{}', 200);
    });
    await tester.pumpWidget(MyApp(client: client));
    await tester.tap(find.text('Pesquisar'));
    await tester.pump();
    expect(chamadas, 0);
    expect(
      find.text('Digite o nome de uma receita para pesquisar.'),
      findsOneWidget,
    );
  });

  testWidgets('Consulta usa o texto digitado e mostra resultado', (
    tester,
  ) async {
    Uri? uri;
    final client = MockClient((request) async {
      uri = request.url;
      return http.Response(
        jsonEncode({
          'meals': [
            {'strMeal': 'Chicken Handi', 'strMealThumb': ''},
          ],
        }),
        200,
      );
    });
    await tester.pumpWidget(MyApp(client: client));
    await tester.enterText(find.byType(TextField), 'chicken & rice');
    await tester.tap(find.text('Pesquisar'));
    await tester.pumpAndSettle();
    expect(uri!.queryParameters['s'], 'chicken & rice');
    expect(find.text('Chicken Handi'), findsOneWidget);
  });

  testWidgets('Sem resultados mostra mensagem', (tester) async {
    final client = MockClient(
      (request) async => http.Response('{"meals":null}', 200),
    );
    await tester.pumpWidget(MyApp(client: client));
    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.tap(find.text('Pesquisar'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma receita encontrada.'), findsOneWidget);
  });

  for (final resposta in [
    http.Response('erro', 500),
    http.Response('inválido', 200),
  ]) {
    testWidgets(
      'Resposta inválida ou erro HTTP mostra mensagem (${resposta.statusCode})',
      (tester) async {
        final client = MockClient((request) async => resposta);
        await tester.pumpWidget(MyApp(client: client));
        await tester.enterText(find.byType(TextField), 'chicken');
        await tester.tap(find.text('Pesquisar'));
        await tester.pumpAndSettle();
        expect(
          find.text('Não foi possível consultar as receitas. Tente novamente.'),
          findsOneWidget,
        );
      },
    );
  }

  testWidgets('Mostra carregamento enquanto espera e trata falha de conexão', (
    tester,
  ) async {
    final resposta = Completer<http.Response>();
    final client = MockClient((request) => resposta.future);
    await tester.pumpWidget(MyApp(client: client));
    await tester.enterText(find.byType(TextField), 'chicken');
    await tester.tap(find.text('Pesquisar'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    resposta.completeError(Exception('sem conexão'));
    await tester.pumpAndSettle();
    expect(
      find.text('Não foi possível consultar as receitas. Tente novamente.'),
      findsOneWidget,
    );
  });
}
