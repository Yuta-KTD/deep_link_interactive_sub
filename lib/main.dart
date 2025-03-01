import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DeepLinkHandler(),
    );
  }
}

class DeepLinkHandler extends StatefulWidget {
  const DeepLinkHandler({super.key});

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  String _message = '待機中...';

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinkListener() async {
    // ディープリンクを監視
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (error) {
        setState(() {
          _message = 'リスナーエラー: $error';
        });
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    // fetchIdパラメータの確認
    final host = uri.host;

    if (host == 'fetchid') {
      setState(() {
        _message = 'fetchidを検出しました。別アプリを呼び出します...';
      });
      _launchDeepLink();
    } else {
      setState(() {
        _message = '予期しない呼び出し: fetchidパラメータがありません';
      });
    }
  }

  Future<void> _launchDeepLink() async {
    const deepLinkUrl = 'deepLinkMainScheme://open?id=123';

    try {
      final uri = Uri.parse(deepLinkUrl);
      await launchUrl(uri);
    } catch (e) {
      setState(() {
        _message = 'エラーが発生しました: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ディープリンクデモ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ディープリンクステータス:'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _message,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _launchDeepLink,
              child: const Text('手動で呼び出す'),
            ),
          ],
        ),
      ),
    );
  }
}
