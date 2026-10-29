import 'package:flutter/material.dart';

import '../data/sample_events.dart';
import '../models/event_item.dart';
import '../models/registration_ticket.dart';
import '../widgets/event_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/venue_map_viewer.dart';
import 'event_registration_screen.dart';
import 'registered_tickets_screen.dart';

/// Layar utama NusaEvent Hub yang beradaptasi penuh dengan ColorScheme tema:
/// Tab 1: Seminar & Workshop
/// Tab 2: Galeri & Denah Venue
/// Tab 3: Tiket Saya
class HomeEventsScreen extends StatefulWidget {
  const HomeEventsScreen({super.key});

  @override
  State<HomeEventsScreen> createState() => _HomeEventsScreenState();
}

class _HomeEventsScreenState extends State<HomeEventsScreen> {
  static const _titles = [
    'Seminar & Workshop',
    'Galeri & Denah Venue',
    'Tiket Saya',
  ];

  static const _subtitles = [
    'Eksplorasi seminar teknologi & riset kampus',
    'Poster kegiatan & navigasi denah interaktif',
    'Daftar tiket digital & QR check-in aktif',
  ];

  int _tabIndex = 0;
  final Set<EventCategory> _filter = {};
  final List<RegistrationTicket> _tickets = [];

  List<EventItem> get _visibleEvents => _filter.isEmpty
      ? sampleEvents
      : sampleEvents.where((e) => _filter.contains(e.category)).toList();

  int _seatsLeft(EventItem event) {
    final taken = _tickets.where((t) => t.event.id == event.id).length;
    return event.quota - event.registered - taken;
  }

  void _toggleCategory(EventCategory category) {
    setState(() {
      if (!_filter.remove(category)) _filter.add(category);
    });
  }

  Future<void> _openFilterSheet() async {
    final result = await showFilterBottomSheet(context, _filter);
    if (result == null || !mounted) return;
    setState(() {
      _filter
        ..clear()
        ..addAll(result);
    });
  }

  Future<void> _showEventDetail(EventItem event) async {
    final scheme = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _EventDetailSheet(
        event: event,
        seatsLeft: _seatsLeft(event),
        onRegister: () {
          Navigator.of(sheetContext).pop();
          _openRegistration(event);
        },
      ),
    );
  }

  Future<void> _openRegistration(EventItem event) async {
    final messenger = ScaffoldMessenger.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (_seatsLeft(event) <= 0) {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: scheme.error,
          content: Text(
            'Maaf, kuota seminar ini sudah penuh / habis terjual.',
            style: TextStyle(color: scheme.onError),
          ),
        ),
      );
      return;
    }

    final ticket = await Navigator.of(context).push<RegistrationTicket>(
      MaterialPageRoute(
        builder: (_) => EventRegistrationScreen(event: event),
      ),
    );
    if (ticket == null || !mounted) return;

    setState(() {
      _tickets.add(ticket);
      _tabIndex = 2; // Auto-redirect ke tab Tiket Terdaftar
    });

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: scheme.surfaceContainerHighest,
          content: Row(
            children: [
              Icon(Icons.check_circle, color: scheme.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pendaftaran berhasil! Tiket Anda telah diterbitkan (${ticket.code}).',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  void _cancelTicket(RegistrationTicket ticket) {
    setState(() => _tickets.removeWhere((t) => t.id == ticket.id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Tiket ${ticket.code} telah dibatalkan.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.hub, color: scheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titles[_tabIndex],
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  _subtitles[_tabIndex],
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _SeminarTab(
            events: _visibleEvents,
            selected: _filter,
            seatsLeftOf: _seatsLeft,
            onToggle: _toggleCategory,
            onClear: () => setState(_filter.clear),
            onOpenFilter: _openFilterSheet,
            onTapEvent: _showEventDetail,
          ),
          _GalleryTab(events: sampleEvents, onTapEvent: _showEventDetail),
          RegisteredTicketsScreen(tickets: _tickets, onCancel: _cancelTicket),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outlineVariant, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (index) => setState(() => _tabIndex = index),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note),
              label: 'Seminar',
            ),
            const NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library),
              label: 'Galeri & Denah',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: _tickets.isNotEmpty,
                label: Text('${_tickets.length}'),
                child: const Icon(Icons.confirmation_number_outlined),
              ),
              selectedIcon: const Icon(Icons.confirmation_number),
              label: 'Tiket Saya',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Tab 1: Seminar

class _SeminarTab extends StatelessWidget {
  const _SeminarTab({
    required this.events,
    required this.selected,
    required this.seatsLeftOf,
    required this.onToggle,
    required this.onClear,
    required this.onOpenFilter,
    required this.onTapEvent,
  });

  final List<EventItem> events;
  final Set<EventCategory> selected;
  final int Function(EventItem) seatsLeftOf;
  final ValueChanged<EventCategory> onToggle;
  final VoidCallback onClear;
  final VoidCallback onOpenFilter;
  final ValueChanged<EventItem> onTapEvent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          children: [
            _CategoryFilterBar(
              selected: selected,
              onToggle: onToggle,
              onClear: onClear,
              onOpenFilter: onOpenFilter,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Menampilkan ${events.length} kegiatan aktif',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (selected.isNotEmpty) ...[
                    const Spacer(),
                    InkWell(
                      onTap: onClear,
                      child: Text(
                        'Reset Filter',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? const _EmptyEvents()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: EventCard(
                            event: event,
                            seatsLeft: seatsLeftOf(event),
                            onTap: () => onTapEvent(event),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.selected,
    required this.onToggle,
    required this.onClear,
    required this.onOpenFilter,
  });

  final Set<EventCategory> selected;
  final ValueChanged<EventCategory> onToggle;
  final VoidCallback onClear;
  final VoidCallback onOpenFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 8, 10),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: selected.isEmpty,
                  onSelected: (_) => onClear(),
                ),
                for (final category in EventCategory.values)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: FilterChip(
                      avatar: Icon(category.icon, size: 16),
                      label: Text(category.label),
                      selected: selected.contains(category),
                      onSelected: (_) => onToggle(category),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 14),
          child: IconButton.filledTonal(
            tooltip: 'Filter kategori',
            onPressed: onOpenFilter,
            icon: Badge(
              isLabelVisible: selected.isNotEmpty,
              label: Text('${selected.length}'),
              child: const Icon(Icons.tune, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyEvents extends StatelessWidget {
  const _EmptyEvents();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 52,
                color: scheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada seminar pada kategori ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Coba pilih kategori filter lainnya atau tekan tombol Reset.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Tab 2: Galeri & Denah

class _GalleryTab extends StatefulWidget {
  const _GalleryTab({required this.events, required this.onTapEvent});

  final List<EventItem> events;
  final ValueChanged<EventItem> onTapEvent;

  @override
  State<_GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<_GalleryTab> {
  bool _showMap = false;
  final Set<String> _bookmarkedIds = {};

  void _toggleBookmark(String eventId) {
    setState(() {
      if (!_bookmarkedIds.remove(eventId)) {
        _bookmarkedIds.add(eventId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  style: SegmentedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  segments: const [
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.grid_view, size: 18),
                      label: Text('Poster Seminar'),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.map_outlined, size: 18),
                      label: Text('Denah Venue'),
                    ),
                  ],
                  selected: {_showMap},
                  onSelectionChanged: (value) =>
                      setState(() => _showMap = value.first),
                ),
              ),
            ),
            Expanded(
              child: _showMap
                  ? const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: VenueMapViewer(),
                    )
                  : _PosterGrid(
                      events: widget.events,
                      bookmarkedIds: _bookmarkedIds,
                      onToggleBookmark: _toggleBookmark,
                      onTapEvent: widget.onTapEvent,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterGrid extends StatelessWidget {
  const _PosterGrid({
    required this.events,
    required this.bookmarkedIds,
    required this.onToggleBookmark,
    required this.onTapEvent,
  });

  final List<EventItem> events;
  final Set<String> bookmarkedIds;
  final ValueChanged<String> onToggleBookmark;
  final ValueChanged<EventItem> onTapEvent;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.67,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isBookmarked = bookmarkedIds.contains(event.id);
        return _PosterTile(
          event: event,
          isBookmarked: isBookmarked,
          onBookmarkPressed: () => onToggleBookmark(event.id),
          onTap: () => onTapEvent(event),
        );
      },
    );
  }
}

class _PosterTile extends StatelessWidget {
  const _PosterTile({
    required this.event,
    required this.isBookmarked,
    required this.onBookmarkPressed,
    required this.onTap,
  });

  final EventItem event;
  final bool isBookmarked;
  final VoidCallback onBookmarkPressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = event.category.color;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster Image or Vector Gradient
              if (event.posterAsset != null)
                Image.asset(
                  event.posterAsset!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _DefaultPosterContent(
                    event: event,
                    color: color,
                  ),
                )
              else
                _DefaultPosterContent(event: event, color: color),

              // Gradient overlays for text protection
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Overlay interactive elements
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Category badge & bookmark icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            event.category.label.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        InkResponse(
                          radius: 20,
                          onTap: onBookmarkPressed,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: isBookmarked ? Colors.amberAccent : Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Bottom: Title, date & SKP
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.event, size: 12, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            formatDate(event.startDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${event.skp} SKP',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultPosterContent extends StatelessWidget {
  const _DefaultPosterContent({required this.event, required this.color});

  final EventItem event;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    final dark = hsl.withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0)).toColor();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, dark],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Icon(event.category.icon, size: 38, color: Colors.white),
        ),
      ),
    );
  }
}

// ------------------------------------------------------ Detail Bottom Sheet

class _EventDetailSheet extends StatelessWidget {
  const _EventDetailSheet({
    required this.event,
    required this.seatsLeft,
    required this.onRegister,
  });

  final EventItem event;
  final int seatsLeft;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isFull = seatsLeft <= 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: event.isFree
                          ? scheme.onSecondaryContainer
                          : scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              event.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 14),

            // Info box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.person_outline,
                    text: 'Pemateri: ${event.speaker}',
                    isHighlighted: true,
                  ),
                  InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: 'Tanggal: ${event.dateLabel}',
                  ),
                  InfoRow(
                    icon: Icons.schedule_outlined,
                    text: 'Waktu: ${event.time}',
                  ),
                  InfoRow(
                    icon: Icons.place_outlined,
                    text: 'Lokasi: ${event.location}',
                  ),
                  InfoRow(
                    icon: Icons.event_seat_outlined,
                    text: isFull
                        ? 'Status: Kuota Penuh / Habis Terjual'
                        : 'Sisa Kursi: $seatsLeft dari ${event.quota} kursi',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Deskripsi Acara',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              event.description,
              style: TextStyle(
                fontSize: 13.5,
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: isFull
                      ? scheme.surfaceContainerHighest
                      : scheme.primary,
                  foregroundColor: isFull
                      ? scheme.outline
                      : scheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isFull ? null : onRegister,
                icon: Icon(
                  isFull ? Icons.block : Icons.confirmation_number_outlined,
                ),
                label: Text(
                  isFull ? 'Kuota Penuh / Habis Terjual' : 'Daftar Sekarang',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
