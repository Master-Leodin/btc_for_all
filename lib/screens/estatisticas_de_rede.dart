import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EstatisticasDeRede extends StatefulWidget {
  const EstatisticasDeRede({super.key});

  @override
  _EstatisticasDeRedeState createState() => _EstatisticasDeRedeState();
}

class _EstatisticasDeRedeState extends State<EstatisticasDeRede> {
  bool _isLoading = true;
  String _errorMessage = '';
  double _difficulty = 0.0;
  double _hashRate = 0.0;
  int _lightningNodes = 0;

  @override
  void initState() {
    super.initState();
    _fetchNetworkStats();
  }

  // Função para buscar as estatísticas da rede
  Future<void> _fetchNetworkStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Usar a API da Blockchain.info para buscar a dificuldade e hash rate
      final url = Uri.parse('https://blockchain.info/stats?format=json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Resposta da API: $data'); // Verificação do retorno da API

        setState(() {
          // Converter todos os números que podem ser retornados como int para double
          _difficulty = (data['difficulty'] as num).toDouble(); // Garante que seja double
          _hashRate = (data['hash_rate'] as num).toDouble() / 1000000000; // GH/s para TH/s
          _lightningNodes = 16800; // Um valor aproximado para os nós Lightning
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Erro ao carregar estatísticas. Código: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar estatísticas: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas de Rede'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: _errorMessage.isNotEmpty
            ? Center(
          child: Text(
            _errorMessage,
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas da Rede Bitcoin',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Dificuldade de Mineração: $_difficulty',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Hash Rate: $_hashRate TH/s',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Número de Nós da Lightning Network: $_lightningNodes',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
