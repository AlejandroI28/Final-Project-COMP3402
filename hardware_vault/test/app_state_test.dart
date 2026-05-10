import 'package:flutter_test/flutter_test.dart';
import 'package:hardware_vault/providers/app_state.dart';
import 'package:hardware_vault/data/mock_data.dart';

void main() {
  group('Catalog filtering — CPUs', () {
    test('returns all CPUs when no filter or search is set', () {
      final state = AppState();
      expect(state.filteredCPUs.length, mockCPUs.length);
    });

    test('filters CPUs by brand', () {
      final state = AppState();
      state.setCpuBrandFilter('Intel');
      expect(state.filteredCPUs, isNotEmpty);
      expect(
        state.filteredCPUs.every((c) => c.brand == 'Intel'),
        isTrue,
      );
    });

    test('search query is case-insensitive and matches name or series', () {
      final state = AppState();
      state.setSearch('RYZEN');
      expect(state.filteredCPUs, isNotEmpty);
      for (final c in state.filteredCPUs) {
        final hit = c.name.toLowerCase().contains('ryzen') ||
            c.series.toLowerCase().contains('ryzen');
        expect(hit, isTrue, reason: '${c.name} should match "ryzen"');
      }
    });
  });

  group('Catalog filtering — GPUs', () {
    test('filters GPUs by brand Nvidia', () {
      final state = AppState();
      state.setCatalogTab('GPU');
      state.setGpuBrandFilter('Nvidia');
      expect(state.filteredGPUs, isNotEmpty);
      expect(
        state.filteredGPUs.every((g) => g.brand == 'Nvidia'),
        isTrue,
      );
    });

    test('sorting by price_asc returns GPUs in ascending price order', () {
      final state = AppState();
      state.setCatalogTab('GPU');
      state.setSortBy('price_asc');
      final prices = state.filteredGPUs.map((g) => g.price).toList();
      final sorted = [...prices]..sort();
      expect(prices, equals(sorted));
    });
  });

  group('Catalog search state machine', () {
    test('hasSearched is false on initialization', () {
      final state = AppState();
      expect(state.hasSearched, isFalse);
    });

    test('runCatalogSearch sets hasSearched to true', () {
      final state = AppState();
      state.runCatalogSearch();
      expect(state.hasSearched, isTrue);
    });

    test('clearCatalogFilters resets search, filters, and hasSearched', () {
      final state = AppState();
      state.setSearch('intel');
      state.setCpuBrandFilter('Intel');
      state.setSeriesFilter('Core Ultra 200');
      state.runCatalogSearch();

      state.clearCatalogFilters();

      expect(state.searchQuery, isEmpty);
      expect(state.cpuBrandFilter, 'All');
      expect(state.gpuBrandFilter, 'All');
      expect(state.seriesFilter, 'All');
      expect(state.hasSearched, isFalse);
    });

    test('hasActiveCatalogFilters reflects active filter or query', () {
      final state = AppState();
      expect(state.hasActiveCatalogFilters, isFalse);
      state.setSearch('amd');
      expect(state.hasActiveCatalogFilters, isTrue);
      state.clearCatalogFilters();
      expect(state.hasActiveCatalogFilters, isFalse);
      state.setCpuBrandFilter('AMD');
      expect(state.hasActiveCatalogFilters, isTrue);
    });

    test('switching catalog tab resets filters and search state', () {
      final state = AppState();
      state.setSearch('test');
      state.setCpuBrandFilter('Intel');
      state.runCatalogSearch();

      state.setCatalogTab('GPU');

      expect(state.searchQuery, isEmpty);
      expect(state.cpuBrandFilter, 'All');
      expect(state.hasSearched, isFalse);
    });
  });

  group('Catalog combined "All" tab', () {
    test('availableBrands in All tab includes Intel, AMD, and Nvidia', () {
      final state = AppState();
      state.setCatalogTab('All');
      expect(state.availableBrands, containsAll(['All', 'Intel', 'AMD', 'Nvidia']));
    });

    test('setBrandFilter in All tab syncs both CPU and GPU brand filters', () {
      final state = AppState();
      state.setCatalogTab('All');
      state.setBrandFilter('AMD');
      expect(state.cpuBrandFilter, 'AMD');
      expect(state.gpuBrandFilter, 'AMD');
    });
  });
}
