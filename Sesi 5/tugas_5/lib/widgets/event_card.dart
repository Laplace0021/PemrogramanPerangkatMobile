import 'package:flutter/material.dart';

import '../models/event_item.dart';

/// Lencana kecil berisi ikon dan nama kategori dengan adaptasi warna tema.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category});

  final EventCategory category;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.28), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            category.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lencana poin SKP Mandiri beradaptasi dengan warna tertiary/secondary tema.
class SkpBadge extends StatelessWidget {
  const SkpBadge({super.key, required this.skp});

  final int skp;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.3), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, size: 14, color: scheme.onTertiaryContainer),
          const SizedBox(width: 4),
          Text(
            '$skp SKP',
            style: TextStyle(
              color: scheme.onTertiaryContainer,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris informasi teks + ikon dengan warna onSurfaceVariant tema.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String text;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = isHighlighted ? scheme.primary : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontSize: 13,
                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu interaktif seminar beradaptasi penuh dengan ColorScheme tema.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.seatsLeft,
    required this.onTap,
  });

  final EventItem event;
  final int seatsLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isFull = seatsLeft <= 0;
    final isAlmostFull = seatsLeft > 0 && seatsLeft <= 5;
    final filledFraction = ((event.quota - seatsLeft) / event.quota).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFull
              ? scheme.error.withValues(alpha: 0.35)
              : scheme.outlineVariant,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: scheme.primary.withValues(alpha: 0.08),
        highlightColor: scheme.primary.withValues(alpha: 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Accent Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                border: Border(
                  bottom: BorderSide(
                    color: scheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CategoryBadge(category: event.category),
                  const SizedBox(width: 8),
                  SkpBadge(skp: event.skp),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: event.isFree
                          ? scheme.secondaryContainer
                          : scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.priceLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: event.isFree
                            ? scheme.onSecondaryContainer
                            : scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Speaker info
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, size: 14, color: scheme.primary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.speaker,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Date & Schedule
                  InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: '${event.dateLabel} • ${event.time}',
                  ),
                  // Location
                  InfoRow(
                    icon: Icons.location_on_outlined,
                    text: event.location,
                  ),

                  const SizedBox(height: 14),

                  // Quota Bar & Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isFull
                            ? 'Kuota Penuh / Habis Terjual'
                            : (isAlmostFull
                                ? 'Hampir Penuh • Sisa $seatsLeft kursi'
                                : 'Sisa $seatsLeft dari ${event.quota} kursi'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: (isFull || isAlmostFull)
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isFull
                              ? scheme.error
                              : (isAlmostFull
                                  ? scheme.error
                                  : scheme.onSurfaceVariant),
                        ),
                      ),
                      Text(
                        '${(filledFraction * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isFull ? scheme.error : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: filledFraction,
                      minHeight: 6,
                      backgroundColor: scheme.surfaceContainerHighest,
                      color: isFull
                          ? scheme.error
                          : (isAlmostFull
                              ? scheme.error
                              : scheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
