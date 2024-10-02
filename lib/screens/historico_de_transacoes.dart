import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoricoDeTransacoes extends StatefulWidget {
  const HistoricoDeTransacoes({super.key});

  @override
  _HistoricoDeTransacoesState createState() => _HistoricoDeTransacoesState();
}

class _HistoricoDeTransacoesState extends State<HistoricoDeTransacoes> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String _errorMessage = '';  // Variável para exibir erros

  @override
  void initState() {
    super.initState();
    _fetchTransactions(); // Chama a função para buscar as transações ao inicializar
  }

  // Função para buscar o histórico de transações de uma API de blockchain
  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;  // Mostra o carregamento
      _errorMessage = '';  // Reseta qualquer mensagem de erro anterior
    });

    try {
      // Alterado para a API de transações não confirmadas do Blockchain.info
      final url = Uri.parse('https://blockchain.info/unconfirmed-transactions?format=json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Resposta da API: $data');  // Adicione esta linha para ver o retorno da API no console

        if (data != null && data['txs'] != null) {
          setState(() {
            _transactions = data['txs']; // Extrai as transações recentes
            _isLoading = false;  // Desativa o carregamento
          });
        } else {
          setState(() {
            _errorMessage = 'Nenhuma transação encontrada.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Erro ao carregar transações. Código: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao buscar transações: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Transações'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())  // Mostra o carregamento
          : _errorMessage.isNotEmpty  // Verifica se há mensagem de erro
          ? Center(
        child: Text(
          _errorMessage,  // Exibe a mensagem de erro
          style: const TextStyle(fontSize: 18, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      )
          : _transactions.isNotEmpty
          ? ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          final transactionHash = transaction['hash'] ?? 'Hash não disponível';
          final total = (transaction['total'] != null
              ? transaction['total'] / 100000000
              : 0.0);  // Converte satoshis para BTC
          final confirmations = transaction['confirmations'] ?? 0;

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Transação ${index + 1}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hash: ${transaction['hash']}'),
                  Text('Tamanho: ${transaction['size']} bytes'),
                  Text('Taxa: ${transaction['fee'] / 100000000} BTC'),  // Convertendo satoshis para BTC
                ],
              ),
            ),
          );
        },
      )
          : const Center(child: Text('Nenhuma transação encontrada.')),
    );
  }
}
