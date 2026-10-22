import 'package:flutter/material.dart';
import '../models/tour_package.dart';
import 'home_screen.dart' show formatRupiah;

class BookingScreen extends StatefulWidget {
  final TourPackage tour;
  const BookingScreen({super.key, required this.tour});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  int _participants = 1;
  DateTime? _date;

  bool get _isDirty =>
      _nameCtrl.text.trim().isNotEmpty || _participants > 1 || _date != null;

  @override
  void initState() {
    super.initState();
    // Rebuild so PopScope.canPop is re-evaluated as the user types.
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<bool> _confirmCancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pemesanan?'),
        content: const Text('Data yang sudah diisi akan hilang.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Lanjutkan Mengisi')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, Batalkan',
                  style: TextStyle(color: Color(0xFFDC2626)))),
        ],
      ),
    );
    return ok ?? false;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tanggal keberangkatan')));
      return;
    }
    Navigator.pop(context, {
      'name': _nameCtrl.text.trim(),
      'participants': _participants,
      'date': _date,
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.tour.price * _participants;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await _confirmCancel();
        if (leave && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Pesan ${widget.tour.title}')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Text('Jumlah Peserta')),
                  IconButton(
                    onPressed: _participants > 1
                        ? () => setState(() => _participants--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_participants',
                      style: const TextStyle(fontSize: 18)),
                  IconButton(
                    onPressed: () => setState(() => _participants++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(_date == null
                    ? 'Pilih Tanggal Keberangkatan'
                    : '${_date!.day}/${_date!.month}/${_date!.year}'),
              ),
              const SizedBox(height: 24),
              Text('Estimasi Total: ${formatRupiah(total)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                onPressed: _submit,
                child: const Text('Konfirmasi Pemesanan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}