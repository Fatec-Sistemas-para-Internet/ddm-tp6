// Aluno: Enzo Akira Sasaki dos Santos
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'detalhes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.client});

  final http.Client? client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Busca de receitas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: TelaPesquisa(client: client),
    );
  }
}

class TelaPesquisa extends StatefulWidget {
  const TelaPesquisa({super.key, this.client});

  final http.Client? client;

  @override
  State<TelaPesquisa> createState() => _TelaPesquisaState();
}

class _TelaPesquisaState extends State<TelaPesquisa> {
  final TextEditingController pesquisaController = TextEditingController();
  List<dynamic> receitas = [];
  bool carregando = false;
  String mensagem =
      'Pesquise uma receita pelo nome. Experimente termos em inglês, como chicken.';

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  Future<void> pesquisar() async {
    final termo = pesquisaController.text.trim();
    if (termo.isEmpty) {
      setState(() {
        receitas = [];
        mensagem = 'Digite o nome de uma receita para pesquisar.';
      });
      return;
    }
    setState(() {
      carregando = true;
      receitas = [];
      mensagem = '';
    });
    try {
      final uri = Uri.https('www.themealdb.com', '/api/json/v1/1/search.php', {
        's': termo,
      });
      final resposta = widget.client == null
          ? await http.get(uri)
          : await widget.client!.get(uri);
      if (resposta.statusCode != 200) throw Exception('Erro HTTP');
      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      final lista = dados['meals'];
      if (lista != null && lista is! List) {
        throw const FormatException('Resposta inválida');
      }
      if (!mounted) return;
      setState(() {
        receitas = lista ?? [];
        mensagem = receitas.isEmpty ? 'Nenhuma receita encontrada.' : '';
        carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        mensagem = 'Não foi possível consultar as receitas. Tente novamente.';
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enzo Akira Sasaki dos Santos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: pesquisaController,
              decoration: const InputDecoration(
                labelText: 'Nome da receita',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: carregando ? null : pesquisar,
              child: const Text('Pesquisar'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : receitas.isEmpty
                  ? Center(child: Text(mensagem, textAlign: TextAlign.center))
                  : ListView.builder(
                      itemCount: receitas.length,
                      itemBuilder: (context, index) {
                        final receita = receitas[index] as Map<String, dynamic>;
                        final imagem = receita['strMealThumb'] as String? ?? '';
                        return ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TelaDetalhes(receita: receita),
                            ),
                          ),
                          leading: imagemReceita(imagem, 64),
                          title: Text(
                            receita['strMeal'] as String? ?? 'Receita sem nome',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
