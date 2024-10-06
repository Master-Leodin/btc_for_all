import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
import 'package:window_manager/window_manager.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

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
  String _currentVersion = 'BTC for All 0.0.3';
  String? _latestVersion;
  String? _updateUrl;

  @override
  void initState() {
    super.initState();
    checkForUpdates();
  }

  Future<void> checkForUpdates() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/Master-Leodin/btc_for_all/releases/latest'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String latestVersion = data['tag_name'];
        var assets = data['assets'];

        var asset = assets.firstWhere(
              (asset) => asset['name'].toString().contains('btc_for_all'),
          orElse: () => null,
        );

        if (asset != null) {
          String downloadUrl = asset['browser_download_url'];
          setState(() {
            _latestVersion = latestVersion;
            _updateUrl = downloadUrl;
          });
        }
      } else {
        print('Erro ao checar atualizações: Código ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao checar atualizações: $e');
    }
  }

  Future<void> _downloadAndUpdate(String url) async {
    try {
      var dio = Dio();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String zipFilePath = '$tempPath/btc_for_all_update.zip';

      await dio.download(url, zipFilePath);
      await _unzipFile(zipFilePath, tempPath);
      await _replaceFiles(tempPath);
    } catch (e) {
      print('Erro ao atualizar: $e');
    }
  }

  Future<void> _unzipFile(String zipFilePath, String outputPath) async {
    final bytes = File(zipFilePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (var file in archive) {
      final filename = '$outputPath/${file.name}';
      if (file.isFile) {
        final data = file.content as List<int>;
        File(filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(filename).create(recursive: true);
      }
    }
  }

  Future<void> _replaceFiles(String tempPath) async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String appPath = appDir.path;

    Directory tempDir = Directory(tempPath);
    await for (var entity in tempDir.list(recursive: true)) {
      if (entity is File) {
        String newPath = entity.path.replaceFirst(tempPath, appPath);
        entity.copySync(newPath);
      }
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
      home: MyHomePage(
        toggleTheme: _toggleTheme,
        latestVersion: _latestVersion,
        updateUrl: _updateUrl,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String? latestVersion;
  final String? updateUrl;

  const MyHomePage({
    super.key,
    required this.toggleTheme,
    this.latestVersion,
    this.updateUrl,
  });

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
          currentIndex: _currentBottomIndex,
          onTap: (index) {
            setState(() {
              _currentBottomIndex = index;
              _currentTopIndex = -1;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Preço do Bitcoin'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Gráficos'),
            BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Notícias'),
            BottomNavigationBarItem(icon: Icon(Icons.link), label: 'Links Úteis'),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Sobre o App'),
          ],
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Checagem de versão disponível'),
          content: Text(
              'A Última versão (${widget.latestVersion}) está disponível.\n'
                  'Deseja baixar agora?\n'
                  'Confira na aba do valor do BTC a versão atual, se for\n'
                  'abaixo da mostrada aqui, baixe clicando em "sim" e\n'
                  'descompacte na pasta do aplicativo, se for no Android,\n'
                  'baixe e somente clique no APK para atualizar'),
          actions: [
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sim'),
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.updateUrl != null) {
                  launchUrl(Uri.parse(widget.updateUrl!));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
