import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class PartDetailScreen extends StatelessWidget {
  final CPU? cpu;
  final GPU? gpu;

  const PartDetailScreen({super.key, this.cpu, this.gpu});

  @override
  Widget build(BuildContext context) {
    if (cpu != null) return _CPUDetailView(cpu: cpu!);
    if (gpu != null) return _GPUDetailView(gpu: gpu!);
    return const Scaffold(body: Center(child: Text('No data')));
  }
}

// ─── CPU Detail ───────────────────────────────────────────────────────────────
class _CPUDetailView extends StatelessWidget {
  final CPU cpu;

  const _CPUDetailView({required this.cpu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryDeep,
                      AppTheme.background,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.developer_board_rounded,
                      size: 80, color: AppTheme.primary),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BrandBadge(brand: cpu.brand, fontSize: 12),
                      const SizedBox(width: 8),
                      Text(cpu.generation,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(cpu.name,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(cpu.series,
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('\$${cpu.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.primary.withOpacity(0.3)),
                        ),
                        child: Text('Score: ${cpu.benchmark}',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ScoreBar(score: cpu.benchmark, label: 'Benchmark Score'),
                  const SizedBox(height: 24),
                  const Text('Especificaciones',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  _SpecGrid(specs: [
                    ('Núcleos / Hilos', '${cpu.cores} / ${cpu.threads}'),
                    ('Frecuencia Base', '${cpu.baseClock} GHz'),
                    ('Frecuencia Turbo', '${cpu.boostClock} GHz'),
                    ('TDP', '${cpu.tdp}W'),
                    ('Socket', cpu.socket),
                    ('Proceso', cpu.process),
                    ('Caché L3', cpu.cache),
                    ('Gráficos', cpu.hasIGPU ? 'Integrados' : 'No incluidos'),
                  ]),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── GPU Detail ───────────────────────────────────────────────────────────────
class _GPUDetailView extends StatelessWidget {
  final GPU gpu;

  const _GPUDetailView({required this.gpu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryDeep, AppTheme.background],
                  ),
                ),
                child: Center(
                  child: gpuSeriesImage(gpu) != null
                      ? Image.asset(
                          gpuSeriesImage(gpu)!,
                          width: 220,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.videocam_rounded,
                              size: 80,
                              color: AppTheme.primary),
                        )
                      : const Icon(Icons.videocam_rounded,
                          size: 80, color: AppTheme.primary),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BrandBadge(brand: gpu.brand, fontSize: 12),
                      const SizedBox(width: 8),
                      Text(gpu.architecture,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(gpu.name,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(gpu.series,
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('\$${gpu.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.primary.withOpacity(0.3)),
                        ),
                        child: Text('Score: ${gpu.benchmark}',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ScoreBar(score: gpu.benchmark, label: 'Benchmark Score'),
                  const SizedBox(height: 24),
                  const Text('Especificaciones',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  _SpecGrid(specs: [
                    ('VRAM', '${gpu.vram}GB ${gpu.vramType}'),
                    ('Ancho de Banda', '${gpu.memBandwidth} GB/s'),
                    ('Shader Procs.', '${gpu.cudaCores}'),
                    ('TDP', '${gpu.tdp}W'),
                    ('Arquitectura', gpu.architecture),
                    ('Proceso', gpu.process),
                    ('Slot', gpu.slot),
                    ('Serie', gpu.series),
                  ]),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Spec Grid ────────────────────────────────────────────────────────────────
class _SpecGrid extends StatelessWidget {
  final List<(String, String)> specs;

  const _SpecGrid({required this.specs});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: specs
          .map((s) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.$1,
                        style: const TextStyle(
                            fontSize: 9,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(s.$2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
