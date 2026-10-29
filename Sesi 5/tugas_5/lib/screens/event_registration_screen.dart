import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/event_item.dart';
import '../models/registration_ticket.dart';
import '../widgets/event_card.dart';

/// Formulir pendaftaran seminar & workshop yang beradaptasi penuh dengan ColorScheme tema.
class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key, required this.event});

  final EventItem event;

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  static const _participantTypes = [
    'Mahasiswa Aktif',
    'Alumni',
    'Umum',
  ];

  static const _kitPackages = [
    _KitOption(
      'Reguler (Gratis)',
      0,
      'E-Sertifikat bernomor SKP & materi presentasi PDF',
      Icons.description_outlined,
    ),
    _KitOption(
      'Premium (+Rp 45.000)',
      45000,
      'Sertifikat cetak, eksklusif lanyard, totebag & notes',
      Icons.card_giftcard,
    ),
    _KitOption(
      'VIP (+Rp 85.000)',
      85000,
      'Semua fasilitas Premium + Kaos event & Goodie bag',
      Icons.workspace_premium,
    ),
  ];

  static const _maxDonation = 100000.0;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _dateController = TextEditingController();

  String _participantType = _participantTypes.first;
  _KitOption _selectedKit = _kitPackages.first;
  DateTime? _attendanceDate;
  double _donation = 0;
  bool _isSubmitting = false;

  int get _kitPrice => _selectedKit.price;
  int get _donationAmount => _donation.round();
  int get _total => widget.event.price + _kitPrice + _donationAmount;

  @override
  void initState() {
    super.initState();
    _attendanceDate = widget.event.startDate;
    _dateController.text = formatDate(widget.event.startDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _attendanceDate ?? widget.event.startDate,
      firstDate: widget.event.startDate,
      lastDate: widget.event.endDate,
      helpText: 'Pilih Tanggal Sesi Kehadiran',
      confirmText: 'PILIH',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _attendanceDate = picked;
      _dateController.text = formatDate(picked);
    });
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (!_formKey.currentState!.validate()) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: scheme.error,
            content: Row(
              children: [
                Icon(Icons.error_outline, color: scheme.onError),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Periksa kembali formulir! Masih ada data yang belum valid.',
                    style: TextStyle(color: scheme.onError),
                  ),
                ),
              ],
            ),
          ),
        );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final now = DateTime.now();
    final ticket = RegistrationTicket(
      id: 'T${now.microsecondsSinceEpoch}',
      event: widget.event,
      name: _nameController.text.trim(),
      nim: _nimController.text.trim(),
      email: _emailController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      participantType: _participantType,
      attendanceDate: _attendanceDate!,
      kitPackage: _selectedKit.name,
      donation: _donationAmount,
      total: _total,
      createdAt: now,
    );
    Navigator.of(context).pop(ticket);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Formulir Pendaftaran'),
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _EventHeaderCard(event: widget.event),
                          const SizedBox(height: 22),

                          _StepHeader(
                            number: '1',
                            title: 'Identitas Diri Peserta',
                            subtitle: 'Gunakan nama lengkap dan NIM resmi untuk e-sertifikat',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.name,
                            decoration: _formInputDecoration(
                              'Nama Lengkap',
                              Icons.person_outline,
                              hint: 'Contoh: Ahmad Fauzi',
                            ),
                            validator: _validateName,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _nimController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _formInputDecoration(
                              'NIM / Nomor Identitas (KTP)',
                              Icons.badge_outlined,
                              hint: '8–12 digit angka',
                            ),
                            validator: _validateNim,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _formInputDecoration(
                              'Email Institusi / Pribadi',
                              Icons.email_outlined,
                              hint: 'nama@nusaputra.ac.id',
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _whatsappController,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                            ],
                            decoration: _formInputDecoration(
                              'Nomor WhatsApp Aktif',
                              Icons.chat_outlined,
                              hint: '08123456789 atau +628123456789',
                            ),
                            validator: _validateWhatsapp,
                          ),
                          const SizedBox(height: 24),

                          _StepHeader(
                            number: '2',
                            title: 'Status Kepesertaan',
                            subtitle: 'Pilih kategori keikutsertaan Anda',
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final type in _participantTypes)
                                ChoiceChip(
                                  label: Text(type),
                                  selected: _participantType == type,
                                  onSelected: (_) =>
                                      setState(() => _participantType = type),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _StepHeader(
                            number: '3',
                            title: 'Tanggal Kehadiran',
                            subtitle: 'Tentukan tanggal sesi seminar yang akan Anda ikuti',
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: _pickDate,
                            decoration: _formInputDecoration(
                              'Tanggal Kehadiran',
                              Icons.event,
                              hint: widget.event.dateLabel,
                            ),
                            validator: (val) => (val == null || val.isEmpty)
                                ? 'Tanggal kehadiran wajib dipilih'
                                : null,
                          ),
                          const SizedBox(height: 24),

                          _StepHeader(
                            number: '4',
                            title: 'Pilihan Paket Seminar Kit',
                            subtitle: 'Fasilitas fisik & merchandise resmi kegiatan',
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              for (final kit in _kitPackages)
                                _KitOptionTile(
                                  kit: kit,
                                  isSelected: _selectedKit == kit,
                                  onSelect: () =>
                                      setState(() => _selectedKit = kit),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _StepHeader(
                            number: '5',
                            title: 'Donasi Komunitas Riset',
                            subtitle: 'Dukungan sukarela: ${formatRupiah(_donationAmount)}',
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: scheme.outlineVariant),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nominal Donasi:',
                                      style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                                    ),
                                    Text(
                                      formatRupiah(_donationAmount),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: scheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: _donation,
                                  max: _maxDonation,
                                  divisions: 10,
                                  activeColor: scheme.primary,
                                  label: formatRupiah(_donationAmount),
                                  onChanged: (val) => setState(() => _donation = val),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          FormField<bool>(
                            initialValue: false,
                            validator: (val) => val == true
                                ? null
                                : 'Anda wajib menyetujui tata tertib sebelum mendaftar',
                            builder: (field) => _AgreementCheckbox(field: field),
                          ),
                          const SizedBox(height: 20),

                          _ReceiptSummary(
                            ticketPrice: widget.event.price,
                            kitPrice: _kitPrice,
                            donation: _donationAmount,
                            total: _total,
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            height: 52,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: scheme.primary,
                                foregroundColor: scheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isSubmitting ? null : _submit,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text(
                                'Konfirmasi & Terbitkan Tiket',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isSubmitting) const _LoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _KitOption {
  const _KitOption(this.name, this.price, this.description, this.icon);
  final String name;
  final int price;
  final String description;
  final IconData icon;
}

InputDecoration _formInputDecoration(String label, IconData icon, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, size: 20),
  );
}

String? _validateName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Nama lengkap wajib diisi';
  if (text.length < 3) return 'Nama minimal 3 karakter';
  if (!RegExp(r"^[a-zA-Z\s.'-]+$").hasMatch(text)) {
    return 'Nama hanya boleh berupa karakter alfabet';
  }
  return null;
}

String? _validateNim(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'NIM / Nomor Identitas wajib diisi';
  if (!RegExp(r'^\d{8,12}$').hasMatch(text)) {
    return 'Panjang NIM / KTP harus antara 8–12 digit angka';
  }
  return null;
}

String? _validateEmail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Email wajib diisi';
  if (!RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(text)) {
    return 'Format email tidak valid (contoh: nama@kampus.ac.id)';
  }
  return null;
}

String? _validateWhatsapp(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Nomor WhatsApp wajib diisi';
  if (!RegExp(r'^(\+62|62|0)8\d{8,11}$').hasMatch(text)) {
    return 'Gunakan format nomor Indonesia: 08xxxxxxxxxx atau +628xxxxxxxxxx';
  }
  return null;
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final String number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventHeaderCard extends StatelessWidget {
  const _EventHeaderCard({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: event.category.color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: event.category.color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: event.category.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(event.category.icon, size: 26, color: event.category.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CategoryBadge(category: event.category),
                    const SizedBox(width: 6),
                    SkpBadge(skp: event.skp),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.dateLabel} • Biaya: ${event.priceLabel}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
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

class _KitOptionTile extends StatelessWidget {
  const _KitOptionTile({
    required this.kit,
    required this.isSelected,
    required this.onSelect,
  });

  final _KitOption kit;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? scheme.primaryContainer : scheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? scheme.primary : scheme.outlineVariant,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? scheme.primary : scheme.outline,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kit.name,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? scheme.onPrimaryContainer : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kit.description,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: scheme.onSurfaceVariant,
                      ),
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

class _AgreementCheckbox extends StatelessWidget {
  const _AgreementCheckbox({required this.field});

  final FormFieldState<bool> field;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasError = field.hasError;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? scheme.error : scheme.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: field.value ?? false,
            onChanged: field.didChange,
            activeColor: scheme.primary,
            title: Text(
              'Saya menyetujui seluruh tata tertib kegiatan seminar kampus dan berkomitmen untuk hadir tepat waktu.',
              style: TextStyle(fontSize: 12.5, color: scheme.onSurface),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Text(
                field.errorText ?? '',
                style: TextStyle(
                  color: scheme.error,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReceiptSummary extends StatelessWidget {
  const _ReceiptSummary({
    required this.ticketPrice,
    required this.kitPrice,
    required this.donation,
    required this.total,
  });

  final int ticketPrice;
  final int kitPrice;
  final int donation;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Pembayaran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          _ReceiptLine(label: 'Tiket Seminar', value: formatRupiah(ticketPrice)),
          _ReceiptLine(label: 'Paket Seminar Kit', value: formatRupiah(kitPrice)),
          _ReceiptLine(label: 'Donasi Riset', value: formatRupiah(donation)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: scheme.outlineVariant),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                formatRupiah(total),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: scheme.primary),
                const SizedBox(height: 18),
                Text(
                  'Memproses Pendaftaran Tiket...',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mohon tunggu sebentar',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
