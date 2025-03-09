import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

void main() {
  runApp(const MainApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DeepLinkHandler(),
    ),
  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'ディープリンクサブアプリ',
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

  void _initDeepLinkListener() {
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
    final id = Random().nextInt(900) + 100;
    final deepLinkUrl = Platform.isIOS
        ? 'deepLinkMainScheme://open?id=$id'
        : 'deeplinkmainscheme://open?id=$id';

    await Future.delayed(const Duration(milliseconds: 1500));

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
        centerTitle: true,
        title: const Text('アプリB'),
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
