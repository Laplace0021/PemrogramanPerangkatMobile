import 'package:flutter/material.dart';

import '../models/event_item.dart';

/// Menampilkan bottom sheet filter kategori yang beradaptasi penuh dengan ColorScheme tema.
Future<Set<EventCategory>?> showFilterBottomSheet(
  BuildContext context,
  Set<EventCategory> selected,
) {
  final scheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<Set<EventCategory>>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _FilterSheet(initial: selected),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});

  final Set<EventCategory> initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final Set<EventCategory> _draft = {...widget.initial};

  void _toggle(EventCategory category) {
    setState(() {
      if (!_draft.remove(category)) _draft.add(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Kategori Seminar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih satu atau beberapa bidang teknologi yang diminati. Kosongkan untuk menampilkan seluruh acara.',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: [
                for (final category in EventCategory.values)
                  FilterChip(
                    avatar: Icon(
                      category.icon,
                      size: 16,
                      color: _draft.contains(category)
                          ? category.color
                          : scheme.onSurfaceVariant,
                    ),
                    label: Text(category.label),
                    selected: _draft.contains(category),
                    selectedColor: category.color.withValues(alpha: 0.15),
                    checkmarkColor: category.color,
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _draft.contains(category)
                          ? category.color
                          : scheme.onSurface,
                    ),
                    side: BorderSide(
                      color: _draft.contains(category)
                          ? category.color.withValues(alpha: 0.5)
                          : scheme.outlineVariant,
                    ),
                    onSelected: (_) => _toggle(category),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(_draft.clear),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(_draft),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Terapkan Filter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
