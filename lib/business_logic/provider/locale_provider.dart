import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  // Загрузка сохраненной локали 
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  // Установка новой локали
  Future<void> setLocale(Locale loc) async {
    if (_locale?.languageCode == loc.languageCode) return;
    
    _locale = loc;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', loc.languageCode);
    
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void refresh() {
    notifyListeners();
  }
}