import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalculadoraDeTransacoes extends StatefulWidget {
  const CalculadoraDeTransacoes({super.key});

  @override
  _CalculadoraDeTransacoesState createState() => _CalculadoraDeTransacoesState();
}

class _CalculadoraDeTransacoesState extends State<CalculadoraDeTransacoes> {
  double _transactionAmount = 0.0; // Valor da transação em BTC
  double _feeInBtc = 0.0; // Taxa calculada em BTC
  double _btcPriceInUsd = 0.0; // Preço do BTC em USD
  double _btcPriceInBrl = 0.0; // Preço do BTC em BRL
  double _onChainFee = 0.00005; // Taxa padrão para On-chain (inicialmente)
  bool _isLoading = false; // Controle de carregamento
  bool _isCalculated = false; // Controle para verificar se as taxas foram calculadas

  // Função para buscar taxas on-chain e preço do Bitcoin
  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true; // Inicia o carregamento
        _isCalculated = false; // Reiniciar estado de cálculo
      });

      // Usar Future.wait para buscar preço do BTC e taxas on-chain simultaneamente
      await Future.wait([
        _fetchBitcoinPrice(), // Buscar preço do BTC
        _fetchOnChainFee(),   // Buscar taxas On-chain reais
      ]);

      // Calcula a taxa ao finalizar o carregamento
      _calculateFee();

      // Atualizar o estado após o carregamento
      setState(() {
        _isLoading = false;
        _isCalculated = true; // Marca como calculado
      });
    } catch (e) {
      // Se houver erro, exibir uma mensagem e parar o carregamento
      setState(() {
        _isLoading = false;
        _isCalculated = false; // Marca como não calculado
      });
      print("Erro ao carregar dados: $e");
    }
  }

  // Função para buscar o preço do Bitcoin via CoinGecko API em USD e BRL
  Future<void> _fetchBitcoinPrice() async {
    try {
      final url = Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd,brl');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _btcPriceInUsd = (data['bitcoin']['usd'] as num).toDouble(); // Forçar conversão para double
          _btcPriceInBrl = (data['bitcoin']['brl'] as num).toDouble(); // Forçar conversão para double
          print('Preço do BTC: $_btcPriceInUsd USD, $_btcPriceInBrl BRL');
        });
      } else {
        throw Exception('Erro ao buscar o preço do Bitcoin');
      }
    } catch (e) {
      print("Erro ao buscar preço do Bitcoin: $e");
      rethrow; // Lançar novamente o erro para ser capturado na chamada de _fetchData
    }
  }

  // Função para buscar taxas On-chain reais usando a API Mempool.space
  Future<void> _fetchOnChainFee() async {
    try {
      final url = Uri.parse('https://mempool.space/api/v1/fees/recommended');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Garantir que o valor esteja sendo convertido para double
          _onChainFee = (data['fastestFee'] as num).toDouble() / 100000000; // Atualiza a taxa On-chain em BTC
          print('Taxa On-chain em BTC: $_onChainFee');
        });
      } else {
        throw Exception('Erro ao buscar as taxas On-chain');
      }
    } catch (e) {
      print("Erro ao buscar taxas On-chain: $e");
      rethrow;
    }
  }

  // Calcula a taxa com base no valor da transação e na taxa on-chain
  void _calculateFee() {
    if (_transactionAmount > 0 && _onChainFee > 0) {
      setState(() {
        _feeInBtc = _transactionAmount * _onChainFee; // Calcula a taxa em BTC
        print('Taxa calculada: $_feeInBtc BTC');
      });
    } else {
      print('Valores insuficientes para cálculo da taxa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Transações On-chain'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insira o valor da transação (BTC):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Exemplo: 0.01',
              ),
              onChanged: (value) {
                setState(() {
                  _transactionAmount = double.tryParse(value) ?? 0.0;
                  _isCalculated = false; // Reinicia o estado de cálculo ao mudar o valor
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _transactionAmount > 0
                  ? () {
                _fetchData(); // Buscar os dados e calcular as taxas
              }
                  : null, // Desabilita o botão se o valor da transação for inválido
              child: const Text('Calcular'),
            ),
            const SizedBox(height: 20),
            // Verifica o estado de carregamento
            if (_isLoading)
              const Center(child: CircularProgressIndicator()), // Mostra o indicador de carregamento
            // Exibe os resultados após o cálculo
            if (_isCalculated && !_isLoading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Taxa de envio (On-chain): ${_feeInBtc.toStringAsFixed(8)} BTC',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Verifica se o preço em USD foi carregado
                  _btcPriceInUsd > 0
                      ? Text(
                    'Taxa estimada em USD: \$${(_feeInBtc * _btcPriceInUsd).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                      : const Text('Aguardando preço do BTC em USD...'),
                  const SizedBox(height: 10),
                  // Verifica se o preço em BRL foi carregado
                  _btcPriceInBrl > 0
                      ? Text(
                    'Taxa estimada em BRL: R\$${(_feeInBtc * _btcPriceInBrl).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                      : const Text('Aguardando preço do BTC em BRL...'),
                  const SizedBox(height: 20),
                  SelectableText(
                    'Total a ser enviado (texto selecionável): ${( _transactionAmount + _feeInBtc).toStringAsFixed(8)} BTC',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
