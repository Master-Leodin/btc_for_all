import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class P2PScreen extends StatefulWidget {
  const P2PScreen({super.key});

  @override
  State<P2PScreen> createState() => _P2PScreenState();
}

class _P2PScreenState extends State<P2PScreen> with TickerProviderStateMixin {
  final List<Map<String, String>> links = const [
    {
      'title': 'Compre BTC via P2P com segurança',
      'url': 'https://eulen.app/partners-p2p/',
      'image': 'assets/images/p2p.png',
    },
  ];

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  Future<void> _openLink(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Não foi possível abrir $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _colorAnimation = ColorTween(begin: Colors.grey[600], end: Colors.blue[800]).animate(_controller);

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compre BTC via P2P com segurança'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinha todo o conteúdo à esquerda
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Text(
                  'Faça doações mensais para que seu site apareça aqui, não negocio valores, o que vier é de coração',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: _colorAnimation.value,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinha os itens da lista à esquerda
              children: links.map((link) {
                return ListTile(
                  leading: link['image'] != ''
                      ? Image.asset(link['image']!, width: 80, height: 80)
                      : const Icon(Icons.link),
                  title: Text(link['title']!),
                  onTap: () => _openLink(link['url']!),
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
