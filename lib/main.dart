import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'ui/screens/json_upload_page.dart';
import 'core/constants/index.dart';
import 'business_logic/provider/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  runApp(
    ChangeNotifierProvider.value(
      value: localeProvider, // Предоставление провайдера всему приложению
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: true);

    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider.locale ?? const Locale('ru'),
      title: 'Decions Roots',
      theme: AppThemes.mainTheme,
      home: const JsonUploadPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
