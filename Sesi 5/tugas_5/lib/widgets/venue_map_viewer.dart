import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/event_item.dart';

/// Denah venue interaktif bergaya arsitektural yang beradaptasi penuh dengan ColorScheme tema.
class VenueMapViewer extends StatefulWidget {
  const VenueMapViewer({super.key});

  @override
  State<VenueMapViewer> createState() => _VenueMapViewerState();
}

class _VenueMapViewerState extends State<VenueMapViewer> {
  static const _planSize = Size(660, 450);

  final _controller = TransformationController();
  Size _viewport = Size.zero;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetZoom() {
    if (_viewport.isEmpty) {
      _controller.value = Matrix4.identity();
      return;
    }
    final scale = math.min(
      _viewport.width / _planSize.width,
      _viewport.height / _planSize.height,
    );
    final dx = (_viewport.width - _planSize.width * scale) / 2;
    final dy = (_viewport.height - _planSize.height * scale) / 2;
    _controller.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);
  }

  void _zoomIn() {
    final matrix = _controller.value.clone();
    matrix.scale(1.25, 1.25);
    _controller.value = matrix;
  }

  void _zoomOut() {
    final matrix = _controller.value.clone();
    matrix.scale(0.8, 0.8);
    _controller.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Helper toolbar bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.touch_app, size: 16, color: scheme.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cubit / scroll untuk zoom • Geser denah untuk eksplorasi ruangan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Interactive Map Canvas
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                if (size != _viewport) {
                  _viewport = size;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _resetZoom();
                  });
                }
                return Stack(
                  children: [
                    InteractiveViewer(
                      transformationController: _controller,
                      constrained: false,
                      minScale: 0.35,
                      maxScale: 4.5,
                      boundaryMargin: const EdgeInsets.all(200),
                      child: const _VenuePlan(),
                    ),

                    // Floating Zoom Controls Bar
                    PositionedDirectional(
                      end: 14,
                      bottom: 14,
                      child: Container(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: scheme.outlineVariant),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.shadow.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Perbesar (Zoom In)',
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: _zoomIn,
                            ),
                            Divider(height: 1, indent: 4, endIndent: 4, color: scheme.outlineVariant),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Perkecil (Zoom Out)',
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: _zoomOut,
                            ),
                            Divider(height: 1, indent: 4, endIndent: 4, color: scheme.outlineVariant),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Reset Tampilan (1.0x)',
                              icon: const Icon(Icons.center_focus_strong, size: 18),
                              color: scheme.primary,
                              onPressed: _resetZoom,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Gambar rancangan denah lantai gedung serbaguna kampus
class _VenuePlan extends StatelessWidget {
  const _VenuePlan();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 660,
      height: 450,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant, width: 2),
      ),
      child: Stack(
        children: [
          // Background blueprint grid
          Positioned.fill(
            child: CustomPaint(
              painter: _ArchitecturalGridPainter(gridColor: scheme.outlineVariant.withValues(alpha: 0.45)),
            ),
          ),

          // 1. PANGGUNG UTAMA (Lokasi Strategis #1)
          _VenueRoomWidget(
            rect: const Rect.fromLTWH(20, 20, 320, 185),
            code: 'PU-01',
            title: 'Panggung Utama',
            subtitle: 'Seminar Akbar, Keynote & Diskusi Panel',
            icon: Icons.mic_external_on,
            color: scheme.primary,
            isStrategic: true,
          ),

          // 2. LAB HANDS-ON: MOBILE (Lokasi Strategis #2a)
          _VenueRoomWidget(
            rect: const Rect.fromLTWH(355, 20, 285, 88),
            code: 'LB-01',
            title: 'Lab Hands-on (Mobile)',
            subtitle: 'Workshop Flutter & Multiplatform',
            icon: Icons.smartphone,
            color: EventCategory.mobile.color,
            isStrategic: true,
          ),

          // 3. LAB HANDS-ON: IOT & CYBER (Lokasi Strategis #2b)
          _VenueRoomWidget(
            rect: const Rect.fromLTWH(355, 117, 285, 88),
            code: 'LB-02',
            title: 'Lab Hands-on (IoT & Cyber)',
            subtitle: 'ESP32 & Ethical Hacking Lab',
            icon: Icons.memory,
            color: EventCategory.iot.color,
            isStrategic: true,
          ),

          // Koridor Utama Lantai 1
          Positioned.fromRect(
            rect: const Rect.fromLTWH(20, 215, 620, 35),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.95),
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.east, size: 14, color: scheme.outline),
                    const SizedBox(width: 8),
                    Text(
                      'KORIDOR UTAMA LANTAI 1',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.east, size: 14, color: scheme.outline),
                  ],
                ),
              ),
            ),
          ),

          // 4. RUANG REGISTRASI (Lokasi Strategis #3)
          _VenueRoomWidget(
            rect: const Rect.fromLTWH(20, 260, 185, 90),
            code: 'RG-01',
            title: 'Ruang Registrasi',
            subtitle: 'Check-in QR & Seminar Kit',
            icon: Icons.how_to_reg,
            color: scheme.secondary,
            isStrategic: true,
          ),

          // 5. BOOTH EKSPO (Lokasi Strategis #4)
          _VenueRoomWidget(
            rect: const Rect.fromLTWH(215, 260, 255, 90),
            code: 'EX-01',
            title: 'Booth Ekspo',
            subtitle: 'Pameran Poster & Riset Kampus',
            icon: Icons.storefront,
            color: scheme.tertiary,
            isStrategic: true,
          ),

          // Food Court & Refreshment
          _VenueRoomWidget(
            rect: const Rect.fromLTWH(480, 260, 160, 90),
            code: 'FC-01',
            title: 'Food Court',
            subtitle: 'Area Istirahat & Makan',
            icon: Icons.restaurant,
            color: scheme.error,
            isStrategic: false,
          ),

          // Pintu Masuk Utama (Grand Entrance)
          Positioned.fromRect(
            rect: const Rect.fromLTWH(215, 365, 255, 55),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                border: Border.all(color: scheme.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.meeting_room, color: scheme.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'PINTU MASUK UTAMA',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Meja Informasi & Helpdesk
          Positioned.fromRect(
            rect: const Rect.fromLTWH(20, 365, 185, 55),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: scheme.outlineVariant),
              ),
              padding: const EdgeInsets.all(6),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        'Meja Informasi & Bantuan',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Toilet & Musala
          Positioned.fromRect(
            rect: const Rect.fromLTWH(480, 365, 160, 55),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: scheme.outlineVariant),
              ),
              padding: const EdgeInsets.all(6),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wc, size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        'Toilet & Musala',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueRoomWidget extends StatelessWidget {
  const _VenueRoomWidget({
    required this.rect,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isStrategic,
  });

  final Rect rect;
  final String code;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isStrategic;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Positioned.fromRect(
      rect: rect,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border.all(
            color: color,
            width: isStrategic ? 2.0 : 1.2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isStrategic ? 0.12 : 0.05),
              blurRadius: isStrategic ? 8 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, color: color, size: 16),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        code,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                    if (isStrategic) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.star, size: 12, color: scheme.tertiary),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchitecturalGridPainter extends CustomPainter {
  const _ArchitecturalGridPainter({required this.gridColor});

  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArchitecturalGridPainter oldDelegate) =>
      oldDelegate.gridColor != gridColor;
}
