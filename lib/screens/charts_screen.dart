import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  List<FlSpot> _dataPoints = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    fetchHistoricalPrices();
  }

  Future<void> fetchHistoricalPrices() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    final url = Uri.parse('https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=30');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prices = data['prices'] as List<dynamic>;

        List<FlSpot> dataPoints = prices
            .asMap()
            .entries
            .map((entry) => FlSpot(entry.key.toDouble(), (entry.value[1] as num).toDouble()))
            .toList();

        setState(() {
          _dataPoints = dataPoints;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : _error
        ? const Center(child: Text('Erro ao carregar dados'))
        : Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _dataPoints,
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
