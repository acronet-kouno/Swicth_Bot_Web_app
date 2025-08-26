import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiBase = String.fromEnvironment('API_BASE', defaultValue: '/api');

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SwitchBot Controller',
    theme: ThemeData(useMaterial3: true),
    home: const Home(),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String status = 'Ready';
  bool busy = false;

  Future<void> call(String path) async {
    setState(() { busy = true; status = 'Running...'; });
    try {
      final res = await http.post(Uri.parse('$apiBase$path'));
      setState(() => status = res.statusCode < 300 ? 'OK' : 'ERR ${res.statusCode}: ${res.body}');
    } catch (e) {
      setState(() => status = 'ERR $e');
    } finally { setState(() => busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SwitchBot Controller')),
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        FilledButton.icon(
          onPressed: busy ? null : () => call('/lock/unlock'),
          icon: const Icon(Icons.lock_open), label: const Text('Unlock')),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: busy ? null : () => call('/lock/lock'),
          icon: const Icon(Icons.lock), label: const Text('Lock')),
        const SizedBox(height: 16),
        if (busy) const CircularProgressIndicator(),
        const SizedBox(height: 8),
        SelectableText(status),
      ]),
    ),
  );
}
