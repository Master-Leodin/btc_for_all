import 'package:flutter/material.dart';
import 'package:btc_for_all/screens/price_screen.dart';
import 'package:btc_for_all/screens/news_screen.dart';
import 'package:btc_for_all/screens/charts_screen.dart';
import 'package:btc_for_all/screens/links_screen.dart';
import 'package:btc_for_all/screens/about_screen.dart';
import 'package:window_manager/window_manager.dart';
import 'package:btc_for_all/screens/conversor_de_criptomoeda.dart';
import 'package:btc_for_all/screens/calculadora_de_transacoes.dart';
import 'package:btc_for_all/screens/historico_de_transacoes.dart'; // Importe o histórico de transações
import 'package:btc_for_all/screens/estatisticas_de_rede.dart'; // Importar o novo widget
import 'package:btc_for_all/screens/simulador_de_investimento.dart'; // Importe o simulador

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.maximize();
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitcoin Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: _themeMode,
      home: MyHomePage(toggleTheme: _toggleTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const MyHomePage({super.key, required this.toggleTheme});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentBottomIndex = 0;
  int _currentTopIndex = -1;

  final List<String> _titles = [
    'Preço do Bitcoin',
    'Gráficos',
    'Notícias',
    'Links Úteis e Ganhe Satoshis',
    'Sobre o App',
    'Conversor de Criptomoeda',
    'Calculadora de Transações',
    'Histórico de Transações', // Título para a aba de histórico de transações
    'Estatísticas de Rede',
    'Simulador de Investimento',
  ];

  final List<Widget> _tabs = [
    const PriceScreen(),
    const ChartsScreen(),
    const NewsScreen(),
    const LinksScreen(),
    const AboutScreen(),
    const ConversorDeCriptomoeda(),
    const CalculadoraDeTransacoes(),
    const HistoricoDeTransacoes(),
    const EstatisticasDeRede(),
    const SimuladorDeInvestimento(),  // Agora usando o widget de Simulador de Investimento
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_currentBottomIndex >= 0 ? _currentBottomIndex : _currentTopIndex + 5]),
          actions: [
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: widget.toggleTheme,
            ),
          ],
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _currentTopIndex = index;
                _currentBottomIndex = -1;
              });
            },
            tabs: const [
              Tab(icon: Icon(Icons.swap_horizontal_circle), text: 'Conversor de Criptomoeda'),
              Tab(icon: Icon(Icons.calculate), text: 'Calculadora de Transações'),
              Tab(icon: Icon(Icons.history), text: 'Histórico de Transações'), // Aba de histórico
              Tab(icon: Icon(Icons.bar_chart), text: 'Estatísticas de Rede'),
              Tab(icon: Icon(Icons.pie_chart), text: 'Simulador de Investimento'),
            ],
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            indicator: const BoxDecoration(),
            labelColor: Colors.grey,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: _tabs[_currentBottomIndex >= 0 ? _currentBottomIndex : _currentTopIndex + 5],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentBottomIndex >= 0 ? _currentBottomIndex : 0,
          onTap: (int index) {
            setState(() {
              _currentBottomIndex = index;
              _currentTopIndex = -1;
            });
          },
          selectedItemColor: Colors.grey,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Preço'),
            BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: 'Gráficos'),
            BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Notícias'),
            BottomNavigationBarItem(icon: Icon(Icons.link), label: 'Links. Ganhe Satoshis'),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Sobre e Doações'),
          ],
        ),
      ),
    );
  }
}
