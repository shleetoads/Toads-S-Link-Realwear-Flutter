import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleViewModel extends StateNotifier<String> {
  LocaleViewModel() : super("KOR");

  setLocale(String value) {
    state = value;
  }
}

final localeViewModelProvider =
    StateNotifierProvider<LocaleViewModel, String>((ref) => LocaleViewModel());
