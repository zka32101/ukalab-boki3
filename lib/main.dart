import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const UkalabBoki3App());
}

class UkalabBoki3App extends StatelessWidget {
  const UkalabBoki3App({super.key});

  static const _field = UkalabField.biz;
  static const _cert = UkalabCert.boki3;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'うかラボ 簿記3級',
      theme: UkalabTheme.light(field: _field, cert: _cert),
      darkTheme: UkalabTheme.dark(field: _field, cert: _cert),
      home: UkalabShell(
        pages: const [
          _HomePage(),
          _PlaceholderPage(label: '学ぶ'),
          _PlaceholderPage(label: '模擬'),
          _PlaceholderPage(label: '記録'),
          _AboutPage(),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('うかラボ 簿記3級'));
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$label（準備中）'));
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'このアプリについて',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          '「うかラボ 簿記3級」は、日本商工会議所および各地商工会議所とは一切関係のない、'
          '非公式の学習アプリです。「日商簿記」は各団体の商標・登録商標である可能性があります。',
        ),
      ],
    );
  }
}
