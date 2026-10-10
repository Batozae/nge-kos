import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../models/kost.dart';
import '../../services/api_service.dart';
import '../../widgets/primary_button.dart';

/// Halaman Posting / Edit Kost.
/// - `kost == null` -> mode Posting (form kosong)
/// - `kost != null` -> mode Edit (form diisi dari data kost)
/// Menutup dengan hasil `true` kalau data berubah, supaya halaman sebelumnya memuat ulang.
class PostingEditKostScreen extends StatefulWidget {
  final Kost? kost;

  const PostingEditKostScreen({super.key, this.kost});

  @override
  State<PostingEditKostScreen> createState() => _PostingEditKostScreenState();
}

class _PostingEditKostScreenState extends State<PostingEditKostScreen> {
  static const List<String> _semuaFasilitas = [
    'WiFi',
    'AC',
    'Kamar Mandi Dalam',
    'Kamar Mandi Luar',
    'Kasur',
    'Lemari',
    'Meja Belajar',
    'Laundry',
    'Parkir Motor',
    'Dapur Bersama',
  ];

  final _namaC = TextEditingController();
  final _alamatC = TextEditingController();
  final _mapsC = TextEditingController();
  final _patokanC = TextEditingController();
  final _waC = TextEditingController();
  final _ukuranC = TextEditingController();
  final _totalC = TextEditingController();
  final _kosongC = TextEditingController();
  final _terisiC = TextEditingController();
  final _hargaC = TextEditingController();

  String _kategori = 'campur';
  final Set<String> _fasilitas = {};
  bool _sedangMemproses = false;
  String? _pesanError;

  bool get _isEdit => widget.kost != null;

  @override
  void initState() {
    super.initState();
    final k = widget.kost;
    if (k != null) {
      _namaC.text = k.nama;
      _alamatC.text = k.alamat;
      _mapsC.text = k.mapsUrl;
      _patokanC.text = k.patokan ?? '';
      _waC.text = k.whatsappNumber;
      _ukuranC.text = k.ukuranKamar == '-' ? '' : k.ukuranKamar;
      _totalC.text = k.jumlahKamarTotal.toString();
      _kosongC.text = k.jumlahKamarKosong.toString();
      _hargaC.text = k.harga.toString();
      _kategori = k.kategoriPenyewa;
      _fasilitas.addAll(k.fasilitas);
      _hitungTerisi();
    }
  }

  @override
  void dispose() {
    for (final c in [
      _namaC,
      _alamatC,
      _mapsC,
      _patokanC,
      _waC,
      _ukuranC,
      _totalC,
      _kosongC,
      _terisiC,
      _hargaC,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int? _angka(String teks) => int.tryParse(teks.trim().replaceAll('.', ''));

  void _hitungTerisi() {
    final total = _angka(_totalC.text);
    final kosong = _angka(_kosongC.text);
    _terisiC.text = (total != null && kosong != null && kosong <= total)
        ? '${total - kosong}'
        : '';
  }

  // 0812... atau 812... atau 62812... -> 62812...
  String _normalisasiWa(String input) {
    var digit = input.replaceAll(RegExp(r'\D'), '');
    if (digit.isEmpty) return '';
    if (digit.startsWith('0')) {
      digit = '62${digit.substring(1)}';
    } else if (!digit.startsWith('62')) {
      digit = '62$digit';
    }
    return digit;
  }

  // Menjalankan aksi ke server dengan penanganan loading dan error yang sama
  Future<void> _jalankan(Future<void> Function() aksi) async {
    if (_sedangMemproses) return;
    setState(() {
      _sedangMemproses = true;
      _pesanError = null;
    });

    try {
      await aksi();
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(
        () => _pesanError = e.sesiBerakhir
            ? 'Sesi login berakhir. Silakan keluar lalu masuk lagi.'
            : e.message,
      );
    } catch (e) {
      debugPrint('Aksi gagal: $e');
      if (!mounted) return;
      setState(
        () => _pesanError = 'Tidak dapat terhubung ke server. Pastikan server API sedang berjalan.',
      );
    } finally {
      if (mounted) setState(() => _sedangMemproses = false);
    }
  }

  Future<void> _simpan() async {
    final harga = _angka(_hargaC.text);
    final total = _angka(_totalC.text);
    final kosong = _angka(_kosongC.text);
    final wa = _normalisasiWa(_waC.text);

    if (total == null || kosong == null) {
      setState(
        () => _pesanError = 'Jumlah kamar total dan kosong harus berupa angka',
      );
      return;
    }
    if (harga == null) {
      setState(() => _pesanError = 'Harga harus berupa angka');
      return;
    }
    if (wa.isEmpty) {
      setState(() => _pesanError = 'Nomor WhatsApp wajib diisi');
      return;
    }

    final gambarLama = widget.kost?.imageUrl ?? '';
    final data = <String, dynamic>{
      'nama': _namaC.text.trim(),
      'alamat': _alamatC.text.trim(),
      'patokan': _patokanC.text.trim(),
      'mapsUrl': _mapsC.text.trim(),
      'kategoriPenyewa': _kategori,
      'ukuranKamar': _ukuranC.text.trim(),
      'jumlahKamarTotal': total,
      'jumlahKamarKosong': kosong,
      'harga': harga,
      'whatsappNumber': wa,
      'imageUrl': gambarLama.isEmpty ? null : gambarLama,
      'fasilitas': _semuaFasilitas.where(_fasilitas.contains).toList(),
    };

    await _jalankan(() async {
      if (_isEdit) {
        await ApiService.ubahKost(widget.kost!.id, data);
      } else {
        await ApiService.buatKost(data);
      }
    });
  }

  Future<void> _hapus() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus kost ini?'),
        content: const Text(
          'Listing akan dihapus permanen dan tidak bisa dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true || !mounted) return;

    await _jalankan(() => ApiService.hapusKost(widget.kost!.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          _isEdit ? 'Edit Kost' : 'Posting Kost',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepBadgeRow(),
            const SizedBox(height: 24),

            // TAHAP 1
            const _SectionHeader(step: '1', title: 'Informasi Dasar Kost'),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Nama Kost',
              hint: 'Contoh: Kost Melati Asri',
              icon: Icons.home_outlined,
              controller: _namaC,
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Alamat Kost',
              hint: 'Nama jalan, nomor, kecamatan, kota',
              icon: Icons.location_on_outlined,
              maxLines: 2,
              controller: _alamatC,
            ),
            const SizedBox(height: 16),
            _MapsPickerField(controller: _mapsC),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Patokan (opsional)',
              hint: 'Contoh: Sebelah minimarket, depan gang III',
              icon: Icons.signpost_outlined,
              controller: _patokanC,
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Nomor WhatsApp',
              hint: 'Contoh: 081234567890',
              icon: Icons.chat_outlined,
              keyboardType: TextInputType.phone,
              controller: _waC,
            ),

            const SizedBox(height: 32),
            const Divider(color: Color(0xFFE5E7EB)),
            const SizedBox(height: 24),

            // TAHAP 2
            const _SectionHeader(step: '2', title: 'Detail Kamar & Harga'),
            const SizedBox(height: 16),
            Text(
              'Kategori Penyewa',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _KategoriPenyewaSelector(
              terpilih: _kategori,
              onChanged: (nilai) => setState(() => _kategori = nilai),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Ukuran Kamar',
              hint: 'Contoh: 3 x 4 m',
              icon: Icons.straighten_outlined,
              controller: _ukuranC,
            ),
            const SizedBox(height: 16),
            Text(
              'Jumlah Kamar',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    label: 'Total',
                    hint: '0',
                    controller: _totalC,
                    onChanged: (_) => _hitungTerisi(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    label: 'Kosong',
                    hint: '0',
                    controller: _kosongC,
                    onChanged: (_) => _hitungTerisi(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    label: 'Terisi',
                    hint: '0',
                    controller: _terisiC,
                    enabled: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Harga Sewa / Bulan',
              hint: '850000',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
              prefixText: 'Rp ',
              controller: _hargaC,
            ),

            const SizedBox(height: 32),
            const Divider(color: Color(0xFFE5E7EB)),
            const SizedBox(height: 24),

            // TAHAP 3
            const _SectionHeader(step: '3', title: 'Foto & Fasilitas'),
            const SizedBox(height: 16),
            Text(
              'Foto Kamar (min. 4 sudut pandang)',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Unggah foto dari sudut berbeda: tampak depan kamar, kamar mandi, jendela/ventilasi, dan akses pintu masuk.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            const _PhotoUploadGrid(minPhotos: 4),
            const SizedBox(height: 24),
            Text(
              'Fasilitas',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _FasilitasChips(
              semua: _semuaFasilitas,
              terpilih: _fasilitas,
              onToggle: (nama) => setState(() {
                if (!_fasilitas.remove(nama)) _fasilitas.add(nama);
              }),
            ),

            if (_pesanError != null) ...[
              const SizedBox(height: 16),
              Text(
                _pesanError!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.statusFull,
                ),
              ),
            ],

            const SizedBox(height: 28),
            PrimaryButton(
              label: _sedangMemproses
                  ? 'Memproses...'
                  : (_isEdit ? 'Simpan Perubahan' : 'Simpan & Posting Kost'),
              onPressed: _simpan,
            ),

            if (_isEdit) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _hapus,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.statusFull,
                  ),
                  label: Text(
                    'Hapus Kost',
                    style: GoogleFonts.inter(
                      color: AppColors.statusFull,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepBadgeRow extends StatelessWidget {
  const _StepBadgeRow();

  @override
  Widget build(BuildContext context) {
    Widget badge(String number, String label) {
      return Expanded(
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.primary,
              child: Text(
                number,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [badge('1', 'Dasar'), badge('2', 'Kamar'), badge('3', 'Foto')],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String step;
  final String title;

  const _SectionHeader({required this.step, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Tahap $step',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;
  final String? prefixText;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            prefixText: prefixText,
            prefixIcon: maxLines == 1
                ? Icon(icon, color: AppColors.textSecondary, size: 20)
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const _NumberField({
    required this.label,
    required this.hint,
    required this.controller,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF3F4F6),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapsPickerField extends StatelessWidget {
  final TextEditingController controller;

  const _MapsPickerField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Titik Lokasi di Google Maps',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*wajib',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.statusFull,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.map_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Buka Google Maps untuk Tandai Lokasi',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Tempel link lokasi Maps di sini',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KategoriPenyewaSelector extends StatelessWidget {
  final String terpilih; // 'putra' | 'putri' | 'campur'
  final ValueChanged<String> onChanged;

  const _KategoriPenyewaSelector({
    required this.terpilih,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(
      String label,
      IconData icon,
      String nilai, {
      bool terakhir = false,
    }) {
      final selected = terpilih == nilai;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(nilai),
          child: Container(
            margin: EdgeInsets.only(right: terakhir ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('Putra', Icons.man_outlined, 'putra'),
        chip('Putri', Icons.woman_outlined, 'putri'),
        chip('Campur', Icons.people_outline, 'campur', terakhir: true),
      ],
    );
  }
}

class _PhotoUploadGrid extends StatelessWidget {
  final int minPhotos;

  const _PhotoUploadGrid({required this.minPhotos});

  @override
  Widget build(BuildContext context) {
    final labels = ['Tampak Depan', 'Kamar Mandi', 'Jendela', 'Pintu Masuk'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: minPhotos,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                labels[index],
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FasilitasChips extends StatelessWidget {
  final List<String> semua;
  final Set<String> terpilih;
  final ValueChanged<String> onToggle;

  const _FasilitasChips({
    required this.semua,
    required this.terpilih,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: semua.map((label) {
        final selected = terpilih.contains(label);
        return GestureDetector(
          onTap: () => onToggle(label),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
