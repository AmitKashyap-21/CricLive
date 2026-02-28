import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env for API keys — must happen before any API calls
  await dotenv.load(fileName: '.env');

  runApp(
    const ProviderScope(
      child: CricLiveApp(),
    ),
  );
}
