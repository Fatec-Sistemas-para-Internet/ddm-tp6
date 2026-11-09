import 'package:flutter/material.dart';

class TelaDetalhes extends StatelessWidget {
  const TelaDetalhes({super.key, required this.receita});

  final Map<String, dynamic> receita;

  @override
  Widget build(BuildContext context) {
    final ingredientes = <String>[];
    for (var i = 1; i <= 20; i++) {
      final ingrediente = (receita['strIngredient$i'] as String? ?? '').trim();
      final medida = (receita['strMeasure$i'] as String? ?? '').trim();
      if (ingrediente.isNotEmpty) {
        ingredientes.add(
          medida.isEmpty ? ingrediente : '$medida - $ingrediente',
        );
      }
    }
    final preparo = (receita['strInstructions'] as String? ?? '').trim();
    final imagem = receita['strMealThumb'] as String? ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enzo Akira Sasaki dos Santos\nPedro Augusto de Melo Borges',
          style: TextStyle(fontSize: 14),
          maxLines: 2,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            receita['strMeal'] as String? ?? 'Receita sem nome',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          imagemReceita(imagem, 200),
          const SizedBox(height: 16),
          Text('Ingredientes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (ingredientes.isEmpty)
            const Text('Ingredientes não informados.')
          else
            for (final ingrediente in ingredientes) Text(ingrediente),
          const SizedBox(height: 16),
          Text(
            'Modo de preparo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(preparo.isEmpty ? 'Modo de preparo não informado.' : preparo),
        ],
      ),
    );
  }
}

Widget imagemReceita(String url, double tamanho) {
  if (url.isEmpty) {
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: const Icon(Icons.broken_image),
    );
  }
  return Image.network(
    url,
    width: tamanho,
    height: tamanho,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => SizedBox(
      width: tamanho,
      height: tamanho,
      child: const Icon(Icons.broken_image),
    ),
  );
}
