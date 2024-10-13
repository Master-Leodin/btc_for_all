import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Para salvar localmente
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Para notificações no Android

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String _price = "Carregando...";
  double _alertPrice = 0.0; // Valor do alerta escolhido pelo usuário
  final TextEditingController _alertController = TextEditingController();
  FlutterLocalNotificationsPlugin? _localNotifications;

  @override
  void initState() {
    super.initState();
    fetchBitcoinPrice();
    _loadAlertPrice(); // Carregar o preço de alerta salvo
    _initializeNotifications(); // Inicializar notificações para Android
  }

  Future<void> _initializeNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidSettings);
    await _localNotifications?.initialize(initializationSettings);
  }

  Future<void> _showNotification(String message) async {
    const androidDetails = AndroidNotificationDetails(
      'btc_alert_channel',
      'BTC Alert',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformDetails = NotificationDetails(android: androidDetails);
    await _localNotifications?.show(0, 'Alerta de Preço BTC', message, platformDetails);
  }

  Future<void> fetchBitcoinPrice() async {
    final url = Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final double currentPrice = data['bitcoin']['usd'].toDouble();
      setState(() {
        _price = "\$${currentPrice.toStringAsFixed(2)}";
      });

      // Verificar se o preço atingiu o valor de alerta
      if (_alertPrice > 0.0 && currentPrice >= _alertPrice) {
        _showNotification('O preço do BTC atingiu \$${currentPrice.toStringAsFixed(2)}!');
      }
    } else {
      setState(() {
        _price = "Erro ao carregar preço";
      });
    }
  }

  Future<void> _saveAlertPrice(double price) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('btc_alert_price', price);
  }

  Future<void> _loadAlertPrice() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _alertPrice = prefs.getDouble('btc_alert_price') ?? 0.0;
    });
  }

  Future<void> _setAlertPrice() async {
    final double? price = double.tryParse(_alertController.text);
    if (price != null) {
      setState(() {
        _alertPrice = price;
      });
      await _saveAlertPrice(price);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alerta definido para \$${price.toStringAsFixed(2)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerta de Preço BTC'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Preço atual do BTC:', style: TextStyle(fontSize: 24)),
                Text(_price, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: _alertController,
                  decoration: const InputDecoration(
                    labelText: 'Definir Alerta de Preço',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _setAlertPrice,
                  child: const Text('Salvar Alerta'),
                ),
                const SizedBox(height: 20),
                if (_alertPrice > 0)
                  Text('Alerta atual: \$${_alertPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Text(
              'Versão 0.1.0 Beta Fracassado',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400], // Cinza claro
              ),
            ),
          ),
        ],
      ),
    );
  }
}
