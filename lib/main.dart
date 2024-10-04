import 'dart:convert';
import 'dart:io';  // Para usar Platform
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // Para fazer requisições HTTP
import 'package:url_launcher/url_launcher.dart';
import 'package:btc_for_all/screens/price_screen.dart';
import 'package:btc_for_all/screens/news_screen.dart';
import 'package:btc_for_all/screens/charts_screen.dart';
import 'package:btc_for_all/screens/links_screen.dart';
import 'package:btc_for_all/screens/about_screen.dart';
import 'package:btc_for_all/screens/conversor_de_criptomoeda.dart';
import 'package:btc_for_all/screens/calculadora_de_transacoes.dart';
import 'package:btc_for_all/screens/historico_de_transacoes.dart';
import 'package:btc_for_all/screens/estatisticas_de_rede.dart';
import 'package:btc_for_all/screens/simulador_de_investimento.dart';
import 'package:window_manager/window_manager.dart';  // Para controle de janelas no desktop

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isAndroid && !Platform.isIOS) {
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
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String _currentVersion = '0.0.2';  // Versão atual do app
  String? _latestVersion;
  String? _updateUrl;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();  // Verifica por atualizações ao iniciar o app
  }

  Future<void> _checkForUpdates() async {
    const String releasesUrl = 'https://api.github.com/repos/Master-Leodin/btc_for_all/releases/latest';
    try {
      final response = await http.get(Uri.parse(releasesUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name'];
        final assets = data['assets'];
        if (latestVersion != _currentVersion) {
          setState(() {
            _latestVersion = latestVersion;
            // Encontrar o link da plataforma correta (Windows, Linux ou Android)
            if (Platform.isWindows) {
              _updateUrl = assets.firstWhere((asset) => asset['name'].contains('.exe'))['browser_download_url'];
            } else if (Platform.isLinux) {
              _updateUrl = assets.firstWhere((asset) => asset['name'].contains('.AppImage'))['browser_download_url'];
            } else if (Platform.isAndroid) {
              _updateUrl = assets.firstWhere((asset) => asset['name'].contains('.apk'))['browser_download_url'];
            }
          });
        }
      } else {
        throw Exception('Falha ao verificar por atualizações');
      }
    } catch (e) {
      print('Erro ao checar atualizações: $e');
    }
  }

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
      home: MyHomePage(toggleTheme: _toggleTheme, latestVersion: _latestVersion, updateUrl: _updateUrl),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String? latestVersion;
  final String? updateUrl;

  const MyHomePage({super.key, required this.toggleTheme, this.latestVersion, this.updateUrl});

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
    'Histórico de Transações',
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
    const SimuladorDeInvestimento(),
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
            if (widget.latestVersion != null)
              IconButton(
                icon: const Icon(Icons.system_update),
                onPressed: () {
                  _showUpdateDialog(context);
                },
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
              Tab(icon: Icon(Icons.history), text: 'Histórico de Transações'),
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

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atualização Disponível'),
          content: const Text('Uma nova versão está disponível para download. Deseja atualizar agora?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (widget.updateUrl != null) {
                  launchUrl(Uri.parse(widget.updateUrl!));
                }
              },
              child: const Text('Atualizar'),
            ),
          ],
        );
      },
    );
  }
}
