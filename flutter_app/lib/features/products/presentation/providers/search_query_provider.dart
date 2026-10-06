import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tipos: controlador SearchQueryNotifier y estado String.
final searchQueryProvider =
    NotifierProvider.autoDispose<SearchQueryNotifier, String>(
      SearchQueryNotifier.new,
    );

class SearchQueryNotifier extends Notifier<String> {
  // ? permite null; ?. cancela únicamente cuando existe un timer.
  Timer? _debounce;

  @override
  String build() {
    // Cancela trabajo pendiente al desechar el notifier.
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  void updateQuery(String value) {
    // Debounce: publica tras 400 ms sin nuevas pulsaciones.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      // Asignar state notifica a quienes observan la consulta.
      state = value.trim();
    });
  }
}
