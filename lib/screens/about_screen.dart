import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sobre o App\nDoações e Minha História',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Este é um aplicativo de tudo sobre o Bitcoin.\nHistória do motivo pessoal de criação abaixo dos QR Codes (textão)',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Informações de Contato',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    SelectableText.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Email para erros, dúvidas, sujestões, patrocínios, PIX e PayPal\n(email selecionável e não envie links ou meu BOT irá excluir):\n\n',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextSpan(
                            text: 'leonardo132@gmail.com',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueAccent).copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Informações do Desenvolvedor',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Desenvolvido por: Master Leodin usando dart com o framework flutter',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/images/pix.jpg',
                      width: 600,
                      height: 600,
                      fit: BoxFit.contain,
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        return const Center(child: Text('Imagem não encontrada'));
                      },
                    ),
                  ],
                ),
              ),
            ),

            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Minha História e Motivações',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Após ser mais uma vítima do estado por vários motivos, hoje vivo nas ruas, mas isso não significa que devo desistir.\n\n'
                          'Vendendo doces por 2 anos (tive que aprender a vender) nos semáforos, comprei outro notebook (fraco), pois, além do que já\n'
                          'tinha me acontecido, tive TUDO roubado.\n\n'
                          'Sonho em, antes de sair em definitivo do Brazil, vizitar o Pará para ver se eu vejo as luzes de Colares da famosa "Operação Prato",\n '
                          'mas como é caro e isolado a área, irei pelo lado do Marajó.\n\n'
                          'Pretendo me estabelecer no Peru ou, se ganhar bastante, sudeste asiático, comida boa e custo de vida baixo.\n\n'
                          'Assim que me estabelecer fora, irei trazer meu irmão pra viver e trabalhar junto comigo, ele sofreu um golpe da barriga e está na pior.\n\n'
                          'Finalizando, o que eu ganhar em BTC, irá ficar parado (só comprarei o curso "Bitcoin BlackPill") nas carteiras e usar somente os reais.\n',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
