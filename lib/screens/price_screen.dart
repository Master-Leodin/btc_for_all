import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String _price = "Carregando...";

  @override
  void initState() {
    super.initState();
    fetchBitcoinPrice();
  }

  Future<void> fetchBitcoinPrice() async {
    final url = Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _price = "\$${data['bitcoin']['usd']}";
      });
    } else {
      setState(() {
        _price = "Erro ao carregar preço";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Preço atual do BTC:', style: TextStyle(fontSize: 24)),
              Text(_price, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Text(
            'Versão 0.0.4 Beta Fracassado',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400], // Cinza claro
            ),
          ),
        ),
      ],
    );
  }
}
