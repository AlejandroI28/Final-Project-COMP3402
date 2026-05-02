import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'part_detail_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _CatalogHeader(),
        _SearchBar(),
        _FilterBar(),
        Expanded(child: _CatalogBody()),
      ],
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: const Icon(Icons.memory_rounded,
                color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Catálogo',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              Text('CPUs & GPUs',
                  style:
                      TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        onChanged: (v) => context.read<AppState>().setSearch(v),
        style:
            const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Buscar procesador o tarjeta gráfica...',
          prefixIcon: Icon(Icons.search_rounded, size: 20),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, state, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                  child: _FilterChip(
                      label: 'Tipo',
                      value: state.catalogTab,
                      options: const ['CPU', 'GPU'],
                      onSelect: state.setCatalogTab)),
              const SizedBox(width: 8),
              Expanded(
                  child: _FilterChip(
                      label: 'Marca',
                      value: state.currentBrandFilter,
                      options: state.availableBrands,
                      onSelect: state.setBrandFilter)),
              const SizedBox(width: 8),
              Expanded(
                  child: _FilterChip(
                      label: 'Serie',
                      value: state.seriesFilter,
                      options: state.availableSeries,
                      onSelect: state.setSeriesFilter)),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelect;

  const _FilterChip(
      {required this.label,
      required this.value,
      required this.options,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelect,
      color: AppTheme.surfaceCard,
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppTheme.border),
      ),
      itemBuilder: (_) => options
          .map((o) => PopupMenuItem<String>(
                value: o,
                height: 36,
                child: Text(o,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            o == value ? FontWeight.w700 : FontWeight.w500,
                        color: o == value
                            ? AppTheme.primary
                            : AppTheme.textPrimary)),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 9,
                          letterSpacing: 0.6,
                          color: AppTheme.textMuted)),
                  const SizedBox(height: 1),
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                ],
              ),
            ),
            const Icon(Icons.expand_more_rounded,
                size: 16, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _CatalogBody extends StatelessWidget {
  const _CatalogBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, state, __) {
        if (state.catalogTab == 'CPU') {
          return _CPUList(cpus: state.filteredCPUs, state: state);
        } else {
          return _GPUList(gpus: state.filteredGPUs, state: state);
        }
      },
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Map<String, List<T>> _groupBySeries<T>(List<T> items, String Function(T) getSeries) {
  final map = <String, List<T>>{};
  for (final item in items) {
    final series = getSeries(item);
    map.putIfAbsent(series, () => []).add(item);
  }
  return map;
}

SliverToBoxAdapter _buildBrandHeader(String brand, Color color) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(brand,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color)),
        ],
      ),
    ),
  );
}

SliverToBoxAdapter _buildSeriesHeader(String series) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 16, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
            ),
            child: Text(series,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary)),
          ),
        ],
      ),
    ),
  );
}

List<Widget> _buildBrandWithSeries<T>({
  required List<T> items,
  required String brand,
  required Color brandColor,
  required String Function(T) getSeries,
  required Widget Function(T) buildCard,
}) {
  if (items.isEmpty) return [];
  final seriesMap = _groupBySeries(items, getSeries);
  final slivers = <Widget>[_buildBrandHeader(brand, brandColor)];
  for (final entry in seriesMap.entries) {
    slivers.add(_buildSeriesHeader(entry.key));
    slivers.add(SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => buildCard(entry.value[i]),
        childCount: entry.value.length,
      ),
    ));
  }
  return slivers;
}

// ─── CPU LIST ─────────────────────────────────────────────────────────────────
class _CPUList extends StatelessWidget {
  final List<CPU> cpus;
  final AppState state;

  const _CPUList({required this.cpus, required this.state});

  @override
  Widget build(BuildContext context) {
    final intelCPUs = cpus.where((c) => c.brand == 'Intel').toList();
    final amdCPUs = cpus.where((c) => c.brand == 'AMD').toList();

    return CustomScrollView(
      slivers: [
        if (cpus.isEmpty)
          const SliverFillRemaining(
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Sin resultados',
              subtitle: 'Intenta con otro término de búsqueda',
            ),
          ),
        if (state.cpuBrandFilter != 'AMD')
          ..._buildBrandWithSeries<CPU>(
            items: intelCPUs,
            brand: 'Intel',
            brandColor: AppTheme.intelBlue,
            getSeries: (c) => c.series,
            buildCard: (c) => _CPUCard(cpu: c),
          ),
        if (state.cpuBrandFilter != 'Intel')
          ..._buildBrandWithSeries<CPU>(
            items: amdCPUs,
            brand: 'AMD',
            brandColor: AppTheme.amdRed,
            getSeries: (c) => c.series,
            buildCard: (c) => _CPUCard(cpu: c),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _CPUCard extends StatelessWidget {
  final CPU cpu;

  const _CPUCard({required this.cpu});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PartDetailScreen(cpu: cpu))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.developer_board_rounded,
                  color: AppTheme.primary, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BrandBadge(brand: cpu.brand),
                      const SizedBox(width: 6),
                      Flexible(
                          child: Text(cpu.generation,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textMuted))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(cpu.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _specTag('${cpu.cores}C/${cpu.threads}T'),
                      const SizedBox(width: 6),
                      _specTag('${cpu.boostClock}GHz'),
                      const SizedBox(width: 6),
                      _specTag(cpu.socket),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${cpu.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary)),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textMuted, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _specTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(text,
          style:
              const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
    );
  }
}

// ─── GPU LIST ─────────────────────────────────────────────────────────────────
class _GPUList extends StatelessWidget {
  final List<GPU> gpus;
  final AppState state;

  const _GPUList({required this.gpus, required this.state});

  @override
  Widget build(BuildContext context) {
    final nvidiaGPUs = gpus.where((g) => g.brand == 'Nvidia').toList();
    final amdGPUs = gpus.where((g) => g.brand == 'AMD').toList();
    final intelGPUs = gpus.where((g) => g.brand == 'Intel').toList();

    return CustomScrollView(
      slivers: [
        if (gpus.isEmpty)
          const SliverFillRemaining(
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Sin resultados',
              subtitle: 'Intenta con otro término de búsqueda',
            ),
          ),
        if (state.gpuBrandFilter == 'All' || state.gpuBrandFilter == 'Nvidia')
          ..._buildBrandWithSeries<GPU>(
            items: nvidiaGPUs,
            brand: 'Nvidia',
            brandColor: AppTheme.nvidiaGreen,
            getSeries: (g) => g.series,
            buildCard: (g) => _GPUCard(gpu: g),
          ),
        if (state.gpuBrandFilter == 'All' || state.gpuBrandFilter == 'AMD')
          ..._buildBrandWithSeries<GPU>(
            items: amdGPUs,
            brand: 'AMD',
            brandColor: AppTheme.amdRed,
            getSeries: (g) => g.series,
            buildCard: (g) => _GPUCard(gpu: g),
          ),
        if (state.gpuBrandFilter == 'All' || state.gpuBrandFilter == 'Intel')
          ..._buildBrandWithSeries<GPU>(
            items: intelGPUs,
            brand: 'Intel',
            brandColor: AppTheme.intelBlue,
            getSeries: (g) => g.series,
            buildCard: (g) => _GPUCard(gpu: g),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _GPUCard extends StatelessWidget {
  final GPU gpu;

  const _GPUCard({required this.gpu});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PartDetailScreen(gpu: gpu))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: gpuSeriesImage(gpu) != null
                  ? Image.asset(
                      gpuSeriesImage(gpu)!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.videocam_rounded,
                          color: AppTheme.primary,
                          size: 26),
                    )
                  : const Icon(Icons.videocam_rounded,
                      color: AppTheme.primary, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BrandBadge(brand: gpu.brand),
                      const SizedBox(width: 6),
                      Flexible(
                          child: Text(gpu.architecture,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10, color: AppTheme.textMuted))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(gpu.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _specTag('${gpu.vram}GB ${gpu.vramType}'),
                      const SizedBox(width: 6),
                      _specTag('${gpu.tdp}W'),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${gpu.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary)),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textMuted, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _specTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(text,
          style:
              const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
    );
  }
}

