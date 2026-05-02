import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../data/mock_data.dart';

class MyEquipmentScreen extends StatelessWidget {
  const MyEquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, state, __) {
        return Column(
          children: [
            _EquipHeader(buildCount: state.builds.length),
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary))
                  : state.builds.isEmpty
                      ? _EmptyBuilds(
                          onAdd: () => _showBuildDialog(context, state))
                      : _BuildList(
                          builds: state.builds,
                          state: state,
                          onAdd: () => _showBuildDialog(context, state),
                        ),
            ),
          ],
        );
      },
    );
  }

  void _showBuildDialog(BuildContext context, AppState state,
      [PCBuild? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BuildEditor(
        state: state,
        existing: existing,
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _EquipHeader extends StatelessWidget {
  final int buildCount;

  const _EquipHeader({required this.buildCount});

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
            child: const Icon(Icons.computer_rounded,
                color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mi Equipo',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              Text('$buildCount configuración(es) guardada(s)',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textMuted)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              final state =
                  Provider.of<AppState>(context, listen: false);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppTheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => _BuildEditor(state: state),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyBuilds extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyBuilds({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.computer_rounded,
      title: 'Sin configuraciones',
      subtitle: 'Agrega los componentes de tu PC\npara guardar tu build',
      action: ElevatedButton.icon(
        onPressed: onAdd,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.black,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva Configuración',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ─── Build List ───────────────────────────────────────────────────────────────
class _BuildList extends StatelessWidget {
  final List<PCBuild> builds;
  final AppState state;
  final VoidCallback onAdd;

  const _BuildList(
      {required this.builds, required this.state, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: builds.length,
      itemBuilder: (ctx, i) => _BuildCard(
        pcBuild: builds[i],
        state: state,
        onTap: () => showModalBottomSheet(
          context: ctx,
          isScrollControlled: true,
          backgroundColor: AppTheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) =>
              _BuildEditor(state: state, existing: builds[i]),
        ),
      ),
    );
  }
}

// ─── Build Card ───────────────────────────────────────────────────────────────
class _BuildCard extends StatelessWidget {
  final PCBuild pcBuild;
  final AppState state;
  final VoidCallback onTap;

  const _BuildCard(
      {required this.pcBuild, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cpu = state.getCpuById(pcBuild.cpuId);
    final gpu = state.getGpuById(pcBuild.gpuId);

    // Estimate total price
    double total = (cpu?.price ?? 0) + (gpu?.price ?? 0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.computer_rounded,
                      color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pcBuild.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary)),
                      Text(
                        'Actualizado ${_formatDate(pcBuild.updatedAt)}',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (total > 0)
                      Text('\$${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary)),
                    const Icon(Icons.edit_rounded,
                        size: 16, color: AppTheme.textMuted),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppTheme.border, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ComponentRow(
                    icon: Icons.developer_board_rounded,
                    label: 'CPU',
                    value: cpu?.name ?? 'No asignado',
                    hasValue: cpu != null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ComponentRow(
              icon: Icons.videocam_rounded,
              label: 'GPU',
              value: gpu?.name ?? 'No asignado',
              hasValue: gpu != null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _ComponentRow(
                        icon: Icons.memory_rounded,
                        label: 'RAM',
                        value: '${pcBuild.ramGB}GB ${pcBuild.ramType}',
                        hasValue: true)),
                const SizedBox(width: 8),
                Expanded(
                    child: _ComponentRow(
                        icon: Icons.storage_rounded,
                        label: 'Storage',
                        value:
                            '${pcBuild.storageGB >= 1000 ? '${(pcBuild.storageGB / 1000).toStringAsFixed(1)}TB' : '${pcBuild.storageGB}GB'} ${pcBuild.storageType}',
                        hasValue: true)),
              ],
            ),
            if (pcBuild.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notes_rounded,
                        size: 12, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(pcBuild.notes,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _confirmDelete(context),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 8)),
                  icon: const Icon(Icons.delete_outline_rounded, size: 14),
                  label: const Text('Eliminar',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('¿Eliminar build?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Se eliminará "${pcBuild.name}" permanentemente.',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppTheme.textMuted))),
          TextButton(
              onPressed: () {
                state.deleteBuild(pcBuild.id);
                Navigator.pop(context);
              },
              child: const Text('Eliminar',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'hoy';
    if (diff.inDays == 1) return 'ayer';
    return 'hace ${diff.inDays} días';
  }
}

class _ComponentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool hasValue;

  const _ComponentRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.hasValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 12,
            color: hasValue ? AppTheme.primary : AppTheme.textMuted),
        const SizedBox(width: 5),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600)),
        Flexible(
          child: Text(value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  color: hasValue
                      ? AppTheme.textPrimary
                      : AppTheme.textMuted,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// ─── Build Editor Bottom Sheet ────────────────────────────────────────────────
class _BuildEditor extends StatefulWidget {
  final AppState state;
  final PCBuild? existing;

  const _BuildEditor({required this.state, this.existing});

  @override
  State<_BuildEditor> createState() => _BuildEditorState();
}

class _BuildEditorState extends State<_BuildEditor> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;
  String? _selectedCpuId;
  String? _selectedGpuId;
  int _ramGB = 16;
  String _ramType = 'DDR5';
  int _storageGB = 1000;
  String _storageType = 'NVMe SSD';

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl =
        TextEditingController(text: e?.name ?? 'Mi PC ${DateTime.now().year}');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _selectedCpuId = e?.cpuId;
    _selectedGpuId = e?.gpuId;
    _ramGB = e?.ramGB ?? 16;
    _ramType = e?.ramType ?? 'DDR5';
    _storageGB = e?.storageGB ?? 1000;
    _storageType = e?.storageType ?? 'NVMe SSD';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final now = DateTime.now();
    final build = PCBuild(
      id: widget.existing?.id ??
          'build_${now.millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim().isEmpty ? 'Mi PC' : _nameCtrl.text.trim(),
      cpuId: _selectedCpuId,
      gpuId: _selectedGpuId,
      ramGB: _ramGB,
      ramType: _ramType,
      storageGB: _storageGB,
      storageType: _storageType,
      notes: _notesCtrl.text.trim(),
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );
    widget.state.saveBuild(build);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
                widget.existing == null
                    ? 'Nueva Configuración'
                    : 'Editar Configuración',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 20),

            // Name
            _FieldLabel('Nombre del build'),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                  hintText: 'Ej: Gaming Rig 2025'),
            ),
            const SizedBox(height: 16),

            // CPU Picker
            _FieldLabel('Procesador (CPU)'),
            _Dropdown<String?>(
              value: _selectedCpuId,
              items: [
                const DropdownMenuItem(
                    value: null,
                    child: Text('Sin asignar',
                        style: TextStyle(color: AppTheme.textMuted))),
                ...mockCPUs.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13)),
                    )),
              ],
              onChanged: (v) => setState(() => _selectedCpuId = v),
            ),
            const SizedBox(height: 16),

            // GPU Picker
            _FieldLabel('Tarjeta Gráfica (GPU)'),
            _Dropdown<String?>(
              value: _selectedGpuId,
              items: [
                const DropdownMenuItem(
                    value: null,
                    child: Text('Sin asignar',
                        style: TextStyle(color: AppTheme.textMuted))),
                ...mockGPUs.map((g) => DropdownMenuItem(
                      value: g.id,
                      child: Text(g.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13)),
                    )),
              ],
              onChanged: (v) => setState(() => _selectedGpuId = v),
            ),
            const SizedBox(height: 16),

            // RAM
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('RAM (GB)'),
                      _Dropdown<int>(
                        value: _ramGB,
                        items: [8, 16, 32, 64, 128]
                            .map((v) => DropdownMenuItem(
                                  value: v,
                                  child: Text('$v GB',
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _ramGB = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Tipo RAM'),
                      _Dropdown<String>(
                        value: _ramType,
                        items: ['DDR4', 'DDR5']
                            .map((v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(v,
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _ramType = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Storage
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Almacenamiento'),
                      _Dropdown<int>(
                        value: _storageGB,
                        items: [256, 512, 1000, 2000, 4000]
                            .map((v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(
                                      v >= 1000
                                          ? '${v ~/ 1000}TB'
                                          : '${v}GB',
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary)),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _storageGB = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Tipo Storage'),
                      _Dropdown<String>(
                        value: _storageType,
                        items: ['NVMe SSD', 'SATA SSD', 'HDD']
                            .map((v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(v,
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 12)),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _storageType = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes
            _FieldLabel('Notas (opcional)'),
            TextField(
              controller: _notesCtrl,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 13),
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Ej: Build para streaming y gaming 4K...'),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  widget.existing == null
                      ? 'Guardar Configuración'
                      : 'Actualizar Configuración',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _Dropdown(
      {required this.value,
      required this.items,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        dropdownColor: AppTheme.surfaceCard,
        underline: const SizedBox.shrink(),
        iconEnabledColor: AppTheme.primary,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
      ),
    );
  }
}
