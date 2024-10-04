import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksScreen extends StatelessWidget {
  const LinksScreen({super.key});

  final List<Map<String, String>> links = const [
    {
      'title': 'Linktree 38Tão\nGanhe satoshis e mais',
      'url': 'https://linktr.ee/r38tao',
      'image': 'assets/images/38.png',
    },
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
        title: const Text('Links Úteis'),
      ),
      body: SingleChildScrollView( // Adicionando o SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column( // Usando Column em vez de ListView.builder
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
      ),
    );
  }
}
