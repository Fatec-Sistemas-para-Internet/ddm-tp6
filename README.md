# TP6 — Busca de receitas

Aplicativo desenvolvido por **Enzo Akira Sasaki dos Santos** para a disciplina de Desenvolvimento de Dispositivos Mobile.

Permite pesquisar receitas pelo nome usando a API pública [TheMealDB](https://www.themealdb.com/docs_api_guide.php), visualizar imagens e abrir os ingredientes e o modo de preparo. Os dados das receitas são fornecidos pela API, geralmente em inglês. O aplicativo não salva dados localmente.

## Executar

É necessário ter o Flutter instalado, um dispositivo ou emulador configurado e acesso à internet.

```bash
flutter pub get
flutter run
```

Pesquise por um termo em inglês, como `chicken`, e toque em um resultado para ver os detalhes.

## Verificar

```bash
flutter analyze
flutter test
```
