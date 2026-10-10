import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/kost.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/kost_card.dart';
import '../../widgets/primary_button.dart';

const List<String> _daftarFasilitas = [
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

const _bentukSheet = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
);

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchC = TextEditingController();
  Timer? _debounce;

  String _area = '';
  int? _hargaMin;
  int? _hargaMax;
  Set<String> _fasilitas = {};
  String _sort = ''; // '' | 'harga_asc' | 'harga_desc'

  late Future<List<Kost>> _futureHasil;

  @override
  void initState() {
    super.initState();
    _futureHasil = _ambilData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchC.dispose();
    super.dispose();
  }

  bool get _adaFilter =>
      _searchC.text.trim().isNotEmpty ||
      _area.isNotEmpty ||
      _hargaMin != null ||
      _hargaMax != null ||
      _fasilitas.isNotEmpty ||
      _sort.isNotEmpty;

  // Menyusun query dari keadaan filter saat ini, hanya yang terisi
  Future<List<Kost>> _ambilData() {
    final query = <String, String>{};
    final teks = _searchC.text.trim();
    if (teks.isNotEmpty) query['q'] = teks;
    if (_area.isNotEmpty) query['area'] = _area;
    if (_hargaMin != null) query['hargaMin'] = '$_hargaMin';
    if (_hargaMax != null) query['hargaMax'] = '$_hargaMax';
    if (_fasilitas.isNotEmpty) query['fasilitas'] = _fasilitas.join(',');
    if (_sort.isNotEmpty) query['sort'] = _sort;

    return ApiService.fetchKostList(query: query.isEmpty ? null : query);
  }

  void _cari() {
    setState(() {
      _futureHasil = _ambilData();
    });
  }

  void _saatTeksBerubah(String _) {
    setState(() {}); // memperbarui tombol hapus di kolom pencarian
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _cari);
  }

  void _resetSemua() {
    _debounce?.cancel();
    setState(() {
      _searchC.clear();
      _area = '';
      _hargaMin = null;
      _hargaMax = null;
      _fasilitas = {};
      _sort = '';
      _futureHasil = _ambilData();
    });
  }

  // ---------- Pembuka panel filter ----------

  Future<void> _bukaFilterHarga() async {
    final hasil = await showModalBottomSheet<(int?, int?)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: _bentukSheet,
      builder: (_) => _HargaSheet(min: _hargaMin, max: _hargaMax),
    );
    if (hasil == null || !mounted) return;
    setState(() {
      _hargaMin = hasil.$1;
      _hargaMax = hasil.$2;
      _futureHasil = _ambilData();
    });
  }

  Future<void> _bukaFilterFasilitas() async {
    final hasil = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: _bentukSheet,
      builder: (_) => _FasilitasSheet(terpilih: _fasilitas),
    );
    if (hasil == null || !mounted) return;
    setState(() {
      _fasilitas = hasil;
      _futureHasil = _ambilData();
    });
  }

  Future<void> _bukaFilterArea() async {
    final hasil = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: _bentukSheet,
      builder: (_) => _AreaSheet(nilaiAwal: _area),
    );
    if (hasil == null || !mounted) return;
    setState(() {
      _area = hasil;
      _futureHasil = _ambilData();
    });
  }

  Future<void> _bukaUrutkan() async {
    final hasil = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: _bentukSheet,
      builder: (_) => _UrutSheet(sekarang: _sort),
    );
    if (hasil == null || !mounted) return;
    setState(() {
      _sort = hasil;
      _futureHasil = _ambilData();
    });
  }

  // ---------- Tampilan ----------

  Widget _tampilanError(Object? error) {
    debugPrint('Gagal memuat hasil pencarian: $error');
    final pesan = error is ApiException
        ? error.message
        : 'Tidak dapat terhubung ke server. Pastikan server API sedang berjalan.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _cari, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }

  Widget _tampilanKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 44,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada kost yang cocok dengan pencarianmu.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bagianHasil() {
    return FutureBuilder<List<Kost>>(
      future: _futureHasil,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _tampilanError(snapshot.error);
        }

        final hasil = snapshot.data ?? <Kost>[];

        return Column(
          children: [
            // Info jumlah hasil, angka ditonjolkan dengan warna primary
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: '${hasil.length} kost ',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const TextSpan(text: 'ditemukan'),
                        ],
                      ),
                    ),
                  ),
                  if (_adaFilter)
                    TextButton(
                      onPressed: _resetSemua,
                      child: Text(
                        'Reset filter',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: hasil.isEmpty
                  ? _tampilanKosong()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: hasil.length,
                      itemBuilder: (context, index) {
                        final kost = hasil[index];
                        return KostCard(
                          kost: kost,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.detailKost,
                              arguments: kost,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Hasil Pencarian',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                TextField(
                  controller: _searchC,
                  onChanged: _saatTeksBerubah,
                  onSubmitted: (_) {
                    _debounce?.cancel();
                    _cari();
                  },
                  textInputAction: TextInputAction.search,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari nama kost, area...',
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    suffixIcon: _searchC.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              _debounce?.cancel();
                              _searchC.clear();
                              _cari();
                            },
                          ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter chips
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'Harga',
                        icon: Icons.sell_outlined,
                        aktif: _hargaMin != null || _hargaMax != null,
                        onTap: _bukaFilterHarga,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Fasilitas',
                        icon: Icons.checklist_rounded,
                        aktif: _fasilitas.isNotEmpty,
                        onTap: _bukaFilterFasilitas,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Area',
                        icon: Icons.location_on_outlined,
                        aktif: _area.isNotEmpty,
                        onTap: _bukaFilterArea,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Urutkan',
                        icon: Icons.swap_vert_rounded,
                        aktif: _sort.isNotEmpty,
                        onTap: _bukaUrutkan,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(child: _bagianHasil()),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool aktif;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.aktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final warnaTeks = aktif ? Colors.white : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: aktif
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: aktif
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: warnaTeks),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: warnaTeks,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: warnaTeks.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= Panel filter =======================

class _SheetContainer extends StatelessWidget {
  final String judul;
  final Widget child;

  const _SheetContainer({required this.judul, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

InputDecoration _dekorasiKolom(String hint, {String? prefixText}) {
  return InputDecoration(
    hintText: hint,
    prefixText: prefixText,
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}

class _HargaSheet extends StatefulWidget {
  final int? min;
  final int? max;

  const _HargaSheet({this.min, this.max});

  @override
  State<_HargaSheet> createState() => _HargaSheetState();
}

class _HargaSheetState extends State<_HargaSheet> {
  late final TextEditingController _minC = TextEditingController(
    text: widget.min?.toString() ?? '',
  );
  late final TextEditingController _maxC = TextEditingController(
    text: widget.max?.toString() ?? '',
  );
  String? _error;

  @override
  void dispose() {
    _minC.dispose();
    _maxC.dispose();
    super.dispose();
  }

  void _terapkan() {
    final minTeks = _minC.text.trim();
    final maxTeks = _maxC.text.trim();
    final min = minTeks.isEmpty ? null : int.tryParse(minTeks);
    final max = maxTeks.isEmpty ? null : int.tryParse(maxTeks);

    if ((minTeks.isNotEmpty && min == null) ||
        (maxTeks.isNotEmpty && max == null)) {
      setState(() => _error = 'Harga harus berupa angka');
      return;
    }
    if (min != null && max != null && min > max) {
      setState(
        () => _error = 'Harga minimum tidak boleh lebih besar dari maksimum',
      );
      return;
    }
    Navigator.pop(context, (min, max));
  }

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      judul: 'Rentang Harga per Bulan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minC,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _dekorasiKolom('Minimum', prefixText: 'Rp '),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxC,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _dekorasiKolom('Maksimum', prefixText: 'Rp '),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.statusFull,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, (null, null)),
                child: const Text('Reset'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryButton(label: 'Terapkan', onPressed: _terapkan),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FasilitasSheet extends StatefulWidget {
  final Set<String> terpilih;

  const _FasilitasSheet({required this.terpilih});

  @override
  State<_FasilitasSheet> createState() => _FasilitasSheetState();
}

class _FasilitasSheetState extends State<_FasilitasSheet> {
  late final Set<String> _pilihan = {...widget.terpilih};

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      judul: 'Fasilitas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kost harus memiliki semua fasilitas yang dipilih.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _daftarFasilitas.map((nama) {
              final selected = _pilihan.contains(nama);
              return GestureDetector(
                onTap: () => setState(() {
                  if (!_pilihan.remove(nama)) _pilihan.add(nama);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    nama,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, <String>{}),
                child: const Text('Reset'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryButton(
                  label: 'Terapkan',
                  onPressed: () => Navigator.pop(context, {..._pilihan}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AreaSheet extends StatefulWidget {
  final String nilaiAwal;

  const _AreaSheet({required this.nilaiAwal});

  @override
  State<_AreaSheet> createState() => _AreaSheetState();
}

class _AreaSheetState extends State<_AreaSheet> {
  late final TextEditingController _areaC = TextEditingController(
    text: widget.nilaiAwal,
  );

  @override
  void dispose() {
    _areaC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      judul: 'Area atau Jalan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _areaC,
            autofocus: true,
            onSubmitted: (_) => Navigator.pop(context, _areaC.text.trim()),
            decoration: _dekorasiKolom('Contoh: Ketintang, Gebang, Kertajaya'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: const Text('Reset'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryButton(
                  label: 'Terapkan',
                  onPressed: () => Navigator.pop(context, _areaC.text.trim()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UrutSheet extends StatelessWidget {
  final String sekarang;

  const _UrutSheet({required this.sekarang});

  @override
  Widget build(BuildContext context) {
    const pilihan = [
      ('', 'Bawaan'),
      ('harga_asc', 'Harga terendah'),
      ('harga_desc', 'Harga tertinggi'),
    ];

    return _SheetContainer(
      judul: 'Urutkan',
      child: Column(
        children: [
          for (final (nilai, label) in pilihan)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: nilai == sekarang
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
              trailing: nilai == sekarang
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.pop(context, nilai),
            ),
        ],
      ),
    );
  }
}