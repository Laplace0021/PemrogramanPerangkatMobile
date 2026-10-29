import 'package:flutter/material.dart';

import '../models/event_item.dart';
import '../models/registration_ticket.dart';
import '../widgets/event_card.dart';

/// Daftar tiket aktif dengan format boarding pass digital yang beradaptasi dengan ColorScheme tema.
class RegisteredTicketsScreen extends StatelessWidget {
  const RegisteredTicketsScreen({
    super.key,
    required this.tickets,
    required this.onCancel,
  });

  final List<RegistrationTicket> tickets;
  final ValueChanged<RegistrationTicket> onCancel;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) return const _EmptyTickets();

    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.swipe_left, size: 18, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Geser tiket ke kiri atau tekan ikon silang untuk membatalkan tiket.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Dismissible(
                        key: ValueKey(ticket.id),
                        direction: DismissDirection.endToStart,
                        background: const _CancelBackground(),
                        confirmDismiss: (_) => confirmCancelTicket(context, ticket),
                        onDismissed: (_) => onCancel(ticket),
                        child: _BoardingPassTicketCard(
                          ticket: ticket,
                          onCancelPressed: () async {
                            final ok = await confirmCancelTicket(context, ticket);
                            if (ok) onCancel(ticket);
                          },
                        ),
                      ),
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

/// Dialog konfirmasi pembatalan pendaftaran tiket
Future<bool> confirmCancelTicket(
  BuildContext context,
  RegistrationTicket ticket,
) async {
  final scheme = Theme.of(context).colorScheme;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.warning_amber_rounded, color: scheme.error, size: 36),
        ),
        title: Text(
          'Batalkan Pendaftaran?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan seminar "${ticket.event.title}" '
          'atas nama ${ticket.name} (NIM: ${ticket.nim})?\n\n'
          'Kursi acara akan dikembalikan ke kuota publik dan tiket ini akan hangus.',
          style: TextStyle(fontSize: 13.5, color: scheme.onSurfaceVariant),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ya, Batalkan Pendaftaran'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

class _CancelBackground extends StatelessWidget {
  const _CancelBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.error,
      ),
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_forever, color: scheme.onError, size: 28),
          const SizedBox(width: 8),
          Text(
            'Batalkan Tiket',
            style: TextStyle(
              color: scheme.onError,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu tiket digital bergaya boarding pass
class _BoardingPassTicketCard extends StatelessWidget {
  const _BoardingPassTicketCard({
    required this.ticket,
    required this.onCancelPressed,
  });

  final RegistrationTicket ticket;
  final VoidCallback onCancelPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final categoryColor = ticket.event.category.color;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Boarding Pass
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              border: Border(
                bottom: BorderSide(
                  color: categoryColor.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CategoryBadge(category: ticket.event.category),
                const SizedBox(width: 8),
                SkpBadge(skp: ticket.event.skp),
                const Spacer(),
                InkWell(
                  onTap: onCancelPressed,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16, color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),

          // Detail Isi Tiket
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),

                // Data Peserta Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, size: 16, color: scheme.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                            Text(
                              'NIM: ${ticket.nim} • ${ticket.participantType}',
                              style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Jadwal & Lokasi
                InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: 'Jadwal: ${formatDate(ticket.attendanceDate)} (${ticket.event.time})',
                ),
                InfoRow(
                  icon: Icons.location_on_outlined,
                  text: 'Lokasi: ${ticket.event.location}',
                ),
                InfoRow(
                  icon: Icons.card_giftcard,
                  text: 'Paket: ${ticket.kitPackage}',
                ),
                InfoRow(
                  icon: Icons.payments_outlined,
                  text: 'Total: ${formatRupiah(ticket.total)}'
                      '${ticket.donation > 0 ? ' (donasi ${formatRupiah(ticket.donation)})' : ''}',
                ),

                const SizedBox(height: 14),

                // QR Check-in Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.qr_code_2, size: 38, color: scheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KODE CHECK-IN RESMI',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              ticket.code,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 12, color: scheme.onSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'AKTIF',
                              style: TextStyle(
                                color: scheme.onSecondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 10.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTickets extends StatelessWidget {
  const _EmptyTickets();

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
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.confirmation_number_outlined,
                size: 60,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Belum Ada Tiket Terdaftar',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih seminar teknologi di tab "Seminar", lalu klik Daftar untuk menerbitkan tiket resmi kegiatan Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
