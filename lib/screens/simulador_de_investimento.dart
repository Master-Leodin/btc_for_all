import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class SimuladorDeInvestimento extends StatefulWidget {
  const SimuladorDeInvestimento({super.key});

  @override
  _SimuladorDeInvestimentoState createState() => _SimuladorDeInvestimentoState();
}

class _SimuladorDeInvestimentoState extends State<SimuladorDeInvestimento> {
  final TextEditingController _investedAmountController = TextEditingController();
  DateTime? _investmentDate;
  double _btcPriceAtInvestment = 0.0;  // Preço do BTC na data de investimento (em USD)
  double _btcPriceNowUsd = 0.0;        // Preço do BTC atual em USD
  double _investmentResult = 0.0;      // Valor atual do investimento em USD
  bool _isLoading = false;
  String _errorMessage = '';

  // Função para buscar o preço atual do Bitcoin usando a API CoinGecko
  Future<void> _fetchBitcoinPrice() async {
    try {
      // Tentativa com CoinGecko
      final url = Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _btcPriceNowUsd = (data['bitcoin']['usd'] as num).toDouble();  // Preço atual do BTC em USD
        });
      } else {
        throw Exception('Erro ao buscar o preço do Bitcoin na CoinGecko.');
      }
    } catch (e) {
      // Caso falhe na CoinGecko, tenta com a CoinCap
      try {
        final fallbackUrl = Uri.parse('https://api.coincap.io/v2/assets/bitcoin');
        final fallbackResponse = await http.get(fallbackUrl);
        if (fallbackResponse.statusCode == 200) {
          final fallbackData = json.decode(fallbackResponse.body);
          setState(() {
            _btcPriceNowUsd = (fallbackData['data']['priceUsd'] as num).toDouble();  // Preço atual do BTC em USD
          });
        } else {
          setState(() {
            _errorMessage = 'Erro ao buscar o preço do Bitcoin na CoinCap.';
          });
        }
      } catch (fallbackError) {
        setState(() {
          _errorMessage = 'Erro ao buscar o preço atual do Bitcoin: $e';
        });
      }
    }
  }

  Future<void> _fetchBtcPriceAtInvestment() async {
    if (_investmentDate == null) return;

    final formattedDate = DateFormat('dd-MM-yyyy').format(_investmentDate!);  // Formato necessário para a API

    try {
      // Tenta buscar os dados pela API do CoinGecko
      final url = Uri.parse('https://api.coingecko.com/api/v3/coins/bitcoin/history?date=$formattedDate');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verifica se há 'market_data' e o preço atual para USD
        if (data.containsKey('market_data') && data['market_data'].containsKey('current_price')) {
          final marketData = data['market_data'];

          setState(() {
            _btcPriceAtInvestment = (marketData['current_price']['usd'] as num).toDouble();
          });
        } else {
          // Se os dados não estiverem disponíveis, tenta a segunda API
          await _fetchBtcPriceFromAlternativeApi();
        }
      } else {
        // Se a resposta da CoinGecko falhar, tenta a segunda API
        await _fetchBtcPriceFromAlternativeApi();
      }
    } catch (e) {
      // Caso ocorra um erro, tenta buscar pela segunda API
      await _fetchBtcPriceFromAlternativeApi();
    }
  }

  Future<void> _fetchBtcPriceFromAlternativeApi() async {
    try {
      // Formata a data de investimento no formato necessário
      final formattedDate = DateFormat('yyyy-MM-dd').format(_investmentDate!);

      // Tenta buscar os dados pela API da CoinBase
      final fallbackUrl = Uri.parse(
          'https://api.coinbase.com/v2/prices/BTC-USD/spot?date=$formattedDate'
      );

      final response = await http.get(fallbackUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('data') && data['data'].containsKey('amount')) {
          setState(() {
            _btcPriceAtInvestment = double.parse(data['data']['amount']);
          });
        } else {
          setState(() {
            _errorMessage = 'Nenhuma API conseguiu buscar o preço do Bitcoin para esta data.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Nenhuma API conseguiu buscar o preço do Bitcoin para esta data.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao buscar o preço na data de investimento: $e';
      });
    }
  }

  // Função para calcular o resultado do investimento
  void _calculateInvestmentResult() {
    if (_btcPriceAtInvestment > 0 && _btcPriceNowUsd > 0) {
      final investedAmount = double.tryParse(_investedAmountController.text) ?? 0.0;
      final btcAmountBought = investedAmount / _btcPriceAtInvestment;  // Quantidade de BTC comprada com USD
      _investmentResult = btcAmountBought * _btcPriceNowUsd;           // Valor atual do investimento em USD
    }
  }

  // Função para processar o cálculo quando o botão for pressionado
  Future<void> _processSimulation() async {
    if (_investmentDate == null || _investedAmountController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, insira a data e o valor de investimento';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await _fetchBtcPriceAtInvestment();  // Busca o preço do BTC na data do investimento
    await _fetchBitcoinPrice();          // Busca o preço atual do BTC

    _calculateInvestmentResult();        // Calcula o resultado do investimento

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador de Investimento em Bitcoin'),
      ),
      body: SingleChildScrollView( // Torna o conteúdo rolável
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Simule seu investimento em BTC:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _investedAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor investido (USD)',
                  hintText: 'Exemplo: 1000',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Botão para selecionar a data
              Row(
                children: [
                  const Text('Selecione a data do investimento:'),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2010, 1, 1),  // Data mínima para seleção
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _investmentDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      _investmentDate != null
                          ? DateFormat('dd/MM/yyyy').format(_investmentDate!)
                          : 'Escolher Data',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _processSimulation,
                child: const Text('Calcular'),
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              const SizedBox(height: 20),
              if (_btcPriceAtInvestment > 0 && _investmentResult > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preço do Bitcoin na data: \$${_btcPriceAtInvestment.toStringAsFixed(2)}'),
                    Text('Preço atual do Bitcoin: \$${_btcPriceNowUsd.toStringAsFixed(2)}'),
                    Text('Valor atual do seu investimento: \$${_investmentResult.toStringAsFixed(2)}'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
