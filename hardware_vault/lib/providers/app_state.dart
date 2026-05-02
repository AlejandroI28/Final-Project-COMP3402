import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

class AppState extends ChangeNotifier {
  int _selectedIndex = 1; // Start on News (center)
  List<PCBuild> _builds = [];
  String _searchQuery = '';
  String _cpuBrandFilter = 'All';
  String _gpuBrandFilter = 'All';
  String _seriesFilter = 'All';
  String _catalogTab = 'CPU'; // 'CPU' | 'GPU'
  bool _isLoading = false;

  int get selectedIndex => _selectedIndex;
  List<PCBuild> get builds => _builds;
  String get searchQuery => _searchQuery;
  String get cpuBrandFilter => _cpuBrandFilter;
  String get gpuBrandFilter => _gpuBrandFilter;
  String get seriesFilter => _seriesFilter;
  String get catalogTab => _catalogTab;
  bool get isLoading => _isLoading;

  String get currentBrandFilter =>
      _catalogTab == 'CPU' ? _cpuBrandFilter : _gpuBrandFilter;

  List<String> get availableBrands => _catalogTab == 'CPU'
      ? const ['All', 'Intel', 'AMD']
      : const ['All', 'Nvidia', 'AMD', 'Intel'];

  List<String> get availableSeries {
    final Iterable<String> all;
    if (_catalogTab == 'CPU') {
      all = mockCPUs
          .where((c) =>
              _cpuBrandFilter == 'All' || c.brand == _cpuBrandFilter)
          .map((c) => c.series);
    } else {
      all = mockGPUs
          .where((g) =>
              _gpuBrandFilter == 'All' || g.brand == _gpuBrandFilter)
          .map((g) => g.series);
    }
    final unique = all.toSet().toList()..sort();
    return ['All', ...unique];
  }

  List<CPU> get filteredCPUs {
    return mockCPUs.where((cpu) {
      final matchBrand =
          _cpuBrandFilter == 'All' || cpu.brand == _cpuBrandFilter;
      final matchSeries =
          _seriesFilter == 'All' || cpu.series == _seriesFilter;
      final matchSearch = _searchQuery.isEmpty ||
          cpu.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cpu.series.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchBrand && matchSeries && matchSearch;
    }).toList();
  }

  List<GPU> get filteredGPUs {
    return mockGPUs.where((gpu) {
      final matchBrand =
          _gpuBrandFilter == 'All' || gpu.brand == _gpuBrandFilter;
      final matchSeries =
          _seriesFilter == 'All' || gpu.series == _seriesFilter;
      final matchSearch = _searchQuery.isEmpty ||
          gpu.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          gpu.series.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchBrand && matchSeries && matchSearch;
    }).toList();
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
    } else {
      setGpuBrandFilter(brand);
    }
  }

  void setSeriesFilter(String series) {
    _seriesFilter = series;
    notifyListeners();
  }

  void setCatalogTab(String tab) {
    _catalogTab = tab;
    _searchQuery = '';
    _cpuBrandFilter = 'All';
    _gpuBrandFilter = 'All';
    _seriesFilter = 'All';
    notifyListeners();
  }

  Future<void> loadBuilds() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList('pc_builds') ?? [];
      _builds = raw
          .map((s) => PCBuild.fromMap(json.decode(s) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _builds = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveBuild(PCBuild build) async {
    final existing = _builds.indexWhere((b) => b.id == build.id);
    if (existing >= 0) {
      _builds[existing] = build;
    } else {
      _builds.insert(0, build);
    }
    await _persistBuilds();
    notifyListeners();
  }

  Future<void> deleteBuild(String id) async {
    _builds.removeWhere((b) => b.id == id);
    await _persistBuilds();
    notifyListeners();
  }

  Future<void> _persistBuilds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _builds.map((b) => json.encode(b.toMap())).toList();
    await prefs.setStringList('pc_builds', raw);
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
