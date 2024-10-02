import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart'; // Importar o pacote url_launcher

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  String _title = 'Carregando...';
  String _imageUrl = '';
  String _articleUrl = '';

  // Animação
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    fetchFirstArticle();

    // Configura o controlador para as animações de cor
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Duração da animação
      vsync: this,
    )..repeat(reverse: true); // Repetir em loop

    // Animação de mudança de cor (azul -> vermelho -> verde)
    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.blue, end: Colors.redAccent),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.redAccent, end: Colors.green),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.green, end: Colors.blue),
        weight: 1.0,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // Descartar o controlador quando a tela for fechada
    super.dispose();
  }

  Future<void> fetchFirstArticle() async {
    try {
      // Faz a requisição HTTP para o site do Livecoins
      final response = await http.get(Uri.parse('https://livecoins.com.br/'));

      if (response.statusCode == 200) {
        var document = html_parser.parse(response.body);
        var firstArticleTitle = document.querySelector('h3.entry-title > a')?.text ?? 'Título não encontrado';
        var firstArticleLink = document.querySelector('h3.entry-title > a')?.attributes['href'] ?? '';
        var firstArticleImage = document.querySelector('img')?.attributes['src'] ?? '';

        setState(() {
          _title = firstArticleTitle;
          _articleUrl = firstArticleLink;
          _imageUrl = firstArticleImage;
        });
      } else {
        setState(() {
          _title = 'Erro ao carregar notícias';
        });
      }
    } catch (e) {
      setState(() {
        _title = 'Erro ao carregar notícias';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animação da frase de doações com mudança de cor
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Text(
                  'Faça doações mensais para que seu site apareça aqui, não negocio valores, o que vier é de coração',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: _colorAnimation.value, // Controla a cor da animação
                  ),
                );
              },
            ),
            const SizedBox(height: 20), // Espaçamento entre a frase e o título

            // Exibir o título da notícia
            const Text(
              'Última Notícia do Livecoins',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Exibir a imagem da notícia
            if (_imageUrl.isNotEmpty)
              Image.network(_imageUrl),
            const SizedBox(height: 10),

            // Exibir o título da matéria
            Text(
              _title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Exibir o botão para abrir o link da notícia
            if (_articleUrl.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Abre o link da matéria no navegador
                  launchURL(_articleUrl);
                },
                child: const Text('Ler matéria completa'),
              ),
          ],
        ),
      ),
    );
  }

  // Função para abrir o URL usando url_launcher
  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Não foi possível abrir o link $url';
    }
  }
}
