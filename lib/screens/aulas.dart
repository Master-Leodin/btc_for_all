import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AulasScreen extends StatefulWidget {
  const AulasScreen({super.key});

  @override
  _AulasScreenState createState() => _AulasScreenState();
}

class _AulasScreenState extends State<AulasScreen> with SingleTickerProviderStateMixin {
  // Animação
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

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

  final List<Map<String, String>> aulas = const [
    {
      'title': 'Canal Bitcoinheiros\nAssista ao conteúdo sobre Bitcoin',
      'url': 'https://www.youtube.com/@Bitcoinheiros',
      'image': 'assets/images/bitconheiros.png',
    },
    // Adicione mais links aqui se desejar
  ];

  Future<void> _openLink(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Não foi possível abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aulas e mais sobre Bitcoin'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animação da frase de doações com mudança de cor
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Text(
                  'Faça doações mensais para que seu canal apareça aqui, não negocio valores, o que vier é de coração',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: _colorAnimation.value, // Controla a cor da animação
                  ),
                );
              },
            ),
            const SizedBox(height: 20), // Espaçamento entre a frase e a lista

            // Exibir a lista de aulas
            Column(
              children: aulas.map((aula) {
                return ListTile(
                  leading: aula['image'] != ''
                      ? Image.asset(aula['image']!, width: 80, height: 80)
                      : const Icon(Icons.link),
                  title: Text(aula['title']!),
                  onTap: () => _openLink(aula['url']!),
                  trailing: const Icon(Icons.open_in_new),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
