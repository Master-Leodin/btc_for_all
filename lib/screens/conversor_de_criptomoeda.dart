import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConversorDeCriptomoeda extends StatefulWidget {
  const ConversorDeCriptomoeda({super.key});

  @override
  _ConversorDeCriptomoedaState createState() => _ConversorDeCriptomoedaState();
}

class _ConversorDeCriptomoedaState extends State<ConversorDeCriptomoeda> {
  final TextEditingController _controller = TextEditingController();
  double _convertedValueBRL = 0.0;
  double _convertedValueUSD = 0.0;
  double _btcValueUSD = 0.0;
  double _btcValueBRL = 0.0;
  String _selectedCurrency = 'real'; // Define a moeda padrão como BRL (Real)
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchValues();
  }

  Future<void> _fetchValues() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.get(
        Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd,brl'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        double btcUsdValue = (data['bitcoin']['usd'] as num).toDouble();
        double btcBrlValue = (data['bitcoin']['brl'] as num).toDouble();

        setState(() {
          _btcValueUSD = btcUsdValue;
          _btcValueBRL = btcBrlValue;
          _isLoading = false;
        });
      } else {
        throw Exception('Erro ao buscar dados da CoinGecko');
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados: $error';
        _isLoading = false;
      });
    }
  }

  void _convertCurrency() {
    String value = _controller.text;
    if (value.isEmpty) {
      setState(() {
        _convertedValueBRL = 0.0;
        _convertedValueUSD = 0.0;
      });
      return;
    }

    try {
      final double enteredValue = double.parse(value);
      setState(() {
        if (_selectedCurrency == 'real') {
          _convertedValueBRL = enteredValue / _btcValueBRL; // Real para BTC
        } else if (_selectedCurrency == 'usd') {
          _convertedValueUSD = enteredValue / _btcValueUSD; // USD para BTC
        } else if (_selectedCurrency == 'btc') {
          _convertedValueBRL = enteredValue * _btcValueBRL; // BTC para BRL
          _convertedValueUSD = enteredValue * _btcValueUSD; // BTC para USD
        }
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Valor inválido: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Criptomoeda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : Column(
          children: [
            // RadioListTiles para selecionar o tipo de moeda
            RadioListTile<String>(
              title: const Text('Real (BRL)'),
              value: 'real',
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('USD'),
              value: 'usd',
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('BTC'),
              value: 'btc',
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Digite o valor',
                hintText: 'Digite o valor para converter',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertCurrency, // Chama a conversão ao clicar
              child: const Text('Converter'),
            ),
            const SizedBox(height: 20),
            // Exibe o valor convertido dependendo da seleção
            _selectedCurrency == 'real'
                ? SelectableText(
              'Valor em Bitcoin (texto selecionável): ${_convertedValueBRL.toStringAsFixed(8)} BTC',
              style: const TextStyle(fontSize: 20),
            )
                : _selectedCurrency == 'usd'
                ? SelectableText(
              'Valor em Bitcoin (texto selecionável): ${_convertedValueUSD.toStringAsFixed(8)} BTC',
              style: const TextStyle(fontSize: 20),
            )
                : Column(
              children: [
                SelectableText(
                  'Valor em BRL: ${_convertedValueBRL.toStringAsFixed(2)} BRL',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  'Valor em USD: ${_convertedValueUSD.toStringAsFixed(2)} USD',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchValues,
              child: const Text('Atualizar valores BTC'),
            ),
          ],
        ),
      ),
    );
  }
}
