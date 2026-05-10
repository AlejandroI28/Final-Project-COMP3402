import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../data/database.dart';

class AppState extends ChangeNotifier {
  int _selectedIndex = 1; // Start on News (center)
  List<PCBuild> _builds = [];
  String _searchQuery = '';
  String _cpuBrandFilter = 'All';
  String _gpuBrandFilter = 'All';
  String _seriesFilter = 'All';
  String _catalogTab = 'All'; // 'All' | 'CPU' | 'GPU'
  String _sortBy = 'newest'; // 'newest' | 'oldest' | 'price_asc' | 'price_desc'
  bool _isLoading = false;
  bool _hasSearched = false;

  int get selectedIndex => _selectedIndex;
  List<PCBuild> get builds => _builds;
  String get searchQuery => _searchQuery;
  String get cpuBrandFilter => _cpuBrandFilter;
  String get gpuBrandFilter => _gpuBrandFilter;
  String get seriesFilter => _seriesFilter;
  String get catalogTab => _catalogTab;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;

  bool get hasActiveCatalogFilters {
    return _searchQuery.isNotEmpty ||
        currentBrandFilter != 'All' ||
        _seriesFilter != 'All';
  }

  String get currentBrandFilter {
    if (_catalogTab == 'CPU') return _cpuBrandFilter;
    if (_catalogTab == 'GPU') return _gpuBrandFilter;
    return _cpuBrandFilter; // synced with _gpuBrandFilter when tab == 'All'
  }

  List<String> get availableBrands {
    if (_catalogTab == 'CPU') return const ['All', 'Intel', 'AMD'];
    if (_catalogTab == 'GPU') return const ['All', 'Nvidia', 'AMD', 'Intel'];
    return const ['All', 'Intel', 'AMD', 'Nvidia'];
  }

  List<String> get availableSeries {
    final Iterable<String> all;
    if (_catalogTab == 'CPU') {
      all = mockCPUs
          .where((c) =>
              _cpuBrandFilter == 'All' || c.brand == _cpuBrandFilter)
          .map((c) => c.series);
    } else if (_catalogTab == 'GPU') {
      all = mockGPUs
          .where((g) =>
              _gpuBrandFilter == 'All' || g.brand == _gpuBrandFilter)
          .map((g) => g.series);
    } else {
      final brand = _cpuBrandFilter;
      final cpuSeries = mockCPUs
          .where((c) => brand == 'All' || c.brand == brand)
          .map((c) => c.series);
      final gpuSeries = mockGPUs
          .where((g) => brand == 'All' || g.brand == brand)
          .map((g) => g.series);
      all = {...cpuSeries, ...gpuSeries};
    }
    final unique = all.toSet().toList()..sort();
    return ['All', ...unique];
  }

  List<CPU> get filteredCPUs {
    final list = mockCPUs.where((cpu) {
      final matchBrand =
          _cpuBrandFilter == 'All' || cpu.brand == _cpuBrandFilter;
      final matchSeries =
          _seriesFilter == 'All' || cpu.series == _seriesFilter;
      final matchSearch = _searchQuery.isEmpty ||
          cpu.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cpu.series.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchBrand && matchSeries && matchSearch;
    }).toList();
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'oldest':
        return list.reversed.toList();
    }
    return list;
  }

  List<GPU> get filteredGPUs {
    final list = mockGPUs.where((gpu) {
      final matchBrand =
          _gpuBrandFilter == 'All' || gpu.brand == _gpuBrandFilter;
      final matchSeries =
          _seriesFilter == 'All' || gpu.series == _seriesFilter;
      final matchSearch = _searchQuery.isEmpty ||
          gpu.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          gpu.series.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchBrand && matchSeries && matchSearch;
    }).toList();
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'oldest':
        return list.reversed.toList();
    }
    return list;
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCpuBrandFilter(String brand) {
    _cpuBrandFilter = brand;
    _seriesFilter = 'All';
    notifyListeners();
  }

  void setGpuBrandFilter(String brand) {
    _gpuBrandFilter = brand;
    _seriesFilter = 'All';
    notifyListeners();
  }

  void setBrandFilter(String brand) {
    if (_catalogTab == 'CPU') {
      setCpuBrandFilter(brand);
    } else if (_catalogTab == 'GPU') {
      setGpuBrandFilter(brand);
    } else {
      _cpuBrandFilter = brand;
      _gpuBrandFilter = brand;
      _seriesFilter = 'All';
      notifyListeners();
    }
  }

  void setSeriesFilter(String series) {
    _seriesFilter = series;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void setCatalogTab(String tab) {
    _catalogTab = tab;
    _searchQuery = '';
    _cpuBrandFilter = 'All';
    _gpuBrandFilter = 'All';
    _seriesFilter = 'All';
    _hasSearched = false;
    notifyListeners();
  }

  void runCatalogSearch() {
    _hasSearched = true;
    notifyListeners();
  }

  void resetCatalogSearch() {
    _hasSearched = false;
    notifyListeners();
  }

  void clearCatalogFilters() {
    _searchQuery = '';
    _catalogTab = 'All';
    _cpuBrandFilter = 'All';
    _gpuBrandFilter = 'All';
    _seriesFilter = 'All';
    _hasSearched = false;
    notifyListeners();
  }

  Future<void> loadBuilds() async {
    _isLoading = true;
    notifyListeners();
    try {
      _builds = await DatabaseHelper.instance.getAllBuilds();
    } catch (_) {
      _builds = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveBuild(PCBuild build) async {
    await DatabaseHelper.instance.upsertBuild(build);
    final existing = _builds.indexWhere((b) => b.id == build.id);
    if (existing >= 0) {
      _builds[existing] = build;
    } else {
      _builds.insert(0, build);
    }
    notifyListeners();
  }

  Future<void> deleteBuild(String id) async {
    await DatabaseHelper.instance.deleteBuild(id);
    _builds.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  CPU? getCpuById(String? id) {
    if (id == null) return null;
    try {
      return mockCPUs.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  GPU? getGpuById(String? id) {
    if (id == null) return null;
    try {
      return mockGPUs.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }
}
