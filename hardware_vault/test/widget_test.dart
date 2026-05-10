import 'package:flutter_test/flutter_test.dart';
import 'package:hardware_vault/providers/app_state.dart';

void main() {
  group('AppState change notifications', () {
    test('notifyListeners fires when search query changes', () {
      final state = AppState();
      var fired = 0;
      state.addListener(() => fired++);
      state.setSearch('intel');
      expect(fired, 1);
      state.setSearch('amd');
      expect(fired, 2);
    });

    test('notifyListeners fires when sort criteria changes', () {
      final state = AppState();
      var fired = 0;
      state.addListener(() => fired++);
      state.setSortBy('price_asc');
      state.setSortBy('price_desc');
      expect(fired, 2);
    });
  });
}
