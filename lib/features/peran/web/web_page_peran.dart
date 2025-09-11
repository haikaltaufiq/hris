// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/data/models/fitur_model.dart';
import 'package:hr/data/models/peran_model.dart';
import 'package:hr/data/services/fitur_service.dart';
import 'package:hr/data/services/peran_service.dart';

class WebPagePeran extends StatefulWidget {
  const WebPagePeran({super.key});

  @override
  State<WebPagePeran> createState() => _WebPagePeranState();
}

class _WebPagePeranState extends State<WebPagePeran> with TickerProviderStateMixin {
  List<PeranModel> _peranList = [];
  List<Fitur> _allFitur = [];
  bool _isLoading = true;
  String _searchQuery = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadPeran();
    _loadAllFitur();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // -------------------- LOAD DATA --------------------
  Future<void> _loadPeran() async {
    setState(() => _isLoading = true);
    try {
      final data = await PeranService.fetchPeran();
      if (!mounted) return;
      setState(() {
        _peranList = data;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackBar("Gagal memuat data peran: $e");
    }
  }

  Future<void> _loadAllFitur() async {
    try {
      _allFitur = await FiturService.fetchFitur();
    } catch (e) {
      _showErrorSnackBar('Gagal memuat fitur: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // -------------------- FORM TAMBAH / EDIT --------------------
  Future<void> _showPeranForm({PeranModel? peran}) async {
    final namaController = TextEditingController(text: peran?.namaPeran ?? '');
    List<Fitur> selectedFitur = List.from(peran?.fitur ?? []);
    bool saving = false;
    String searchFitur = '';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final filteredFitur = _allFitur.where((f) =>
              f.namaFitur.toLowerCase().contains(searchFitur.toLowerCase())).toList();

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          peran == null ? Icons.add_circle : Icons.edit,
                          color: AppColors.secondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              peran == null ? 'Tambah Peran Baru' : 'Edit Peran',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              peran == null 
                                  ? 'Buat peran baru dengan fitur yang sesuai'
                                  : 'Perbarui informasi peran',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: saving ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Form Nama Peran
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Peran',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: namaController,
                          decoration: InputDecoration(
                            labelText: 'Nama Peran',
                            hintText: 'Masukkan nama peran...',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: AppColors.secondary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Fitur Selection
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Pilih Fitur',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${selectedFitur.length} dipilih',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Search Fitur
                          TextField(
                            onChanged: (value) => setStateDialog(() => searchFitur = value),
                            decoration: InputDecoration(
                              hintText: 'Cari fitur...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.secondary, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Fitur List
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: filteredFitur.isEmpty
                                  ? const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.search_off, size: 48, color: Colors.grey),
                                          SizedBox(height: 16),
                                          Text(
                                            'Tidak ada fitur ditemukan',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: filteredFitur.length,
                                      separatorBuilder: (context, index) => const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final fitur = filteredFitur[index];
                                        final isSelected = selectedFitur.any((f) => f.id == fitur.id);
                                        
                                        return Container(
                                          margin: const EdgeInsets.symmetric(vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isSelected 
                                                ? AppColors.secondary.withOpacity(0.1) 
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: CheckboxListTile(
                                            title: Text(
                                              fitur.namaFitur,
                                              style: TextStyle(
                                                fontWeight: isSelected 
                                                    ? FontWeight.w600 
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            subtitle: Text(
                                              fitur.deskripsiFitur,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            value: isSelected,
                                            onChanged: (val) {
                                              setStateDialog(() {
                                                if (val == true) {
                                                  if (!selectedFitur.any((f) => f.id == fitur.id)) {
                                                    selectedFitur.add(fitur);
                                                  }
                                                } else {
                                                  selectedFitur.removeWhere((f) => f.id == fitur.id);
                                                }
                                              });
                                            },
                                            activeColor: AppColors.secondary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: saving ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: saving || namaController.text.isEmpty
                            ? null
                            : () async {
                                setStateDialog(() => saving = true);
                                try {
                                  if (peran == null) {
                                    await PeranService.createPeran(
                                      namaController.text,
                                      selectedFitur.map((f) => f.id).toList(),
                                    );
                                    _showSuccessSnackBar('Peran berhasil ditambahkan');
                                  } else {
                                    await PeranService.updatePeran(
                                      peran.id,
                                      namaController.text,
                                      selectedFitur.map((f) => f.id).toList(),
                                    );
                                    _showSuccessSnackBar('Peran berhasil diperbarui');
                                  }
                                  await _loadPeran();
                                  Navigator.pop(context);
                                } catch (e) {
                                  setStateDialog(() => saving = false);
                                  _showErrorSnackBar('Gagal menyimpan: $e');
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------- HAPUS PERAN --------------------
  Future<void> _hapusPeran(int id, String namaPeran) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Hapus Peran?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  children: [
                    const TextSpan(text: 'Apakah Anda yakin ingin menghapus peran '),
                    TextSpan(
                      text: '"$namaPeran"',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tindakan ini tidak dapat dibatalkan',
                        style: TextStyle(color: Colors.orange, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await PeranService.deletePeran(id);
        await _loadPeran();
        _showSuccessSnackBar('Peran berhasil dihapus');
      } catch (e) {
        _showErrorSnackBar('Gagal menghapus: $e');
      }
    }
  }

  List<PeranModel> get _filteredPeran {
    if (_searchQuery.isEmpty) return _peranList;
    return _peranList.where((peran) =>
        peran.namaPeran.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  // -------------------- BUILD --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          "Manajemen Peran",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.secondary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Cari peran...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _loadPeran,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Refresh Data',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPeranForm(),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Peran',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.secondary),
                  const SizedBox(height: 16),
                  const Text(
                    'Memuat data peran...',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : _filteredPeran.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isEmpty ? Icons.group_off : Icons.search_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty 
                            ? 'Belum ada peran yang dibuat'
                            : 'Tidak ada peran ditemukan',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Tekan tombol + untuk menambah peran baru'
                            : 'Coba kata kunci lain',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _animationController,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredPeran.length,
                        itemBuilder: (context, index) {
                          final peran = _filteredPeran[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: Colors.black.withOpacity(0.1),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    AppColors.secondary.withOpacity(0.03),
                                  ],
                                ),
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                                title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.badge,
                                        color: AppColors.secondary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            peran.namaPeran,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${peran.fitur.length} fitur tersedia',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: peran.fitur.isNotEmpty 
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        peran.fitur.isNotEmpty ? 'Aktif' : 'Kosong',
                                        style: TextStyle(
                                          color: peran.fitur.isNotEmpty 
                                              ? Colors.green[700]
                                              : Colors.orange[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PopupMenuButton<String>(
                                      onSelected: (val) {
                                        if (val == 'edit') _showPeranForm(peran: peran);
                                        if (val == 'hapus') _hapusPeran(peran.id, peran.namaPeran);
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 18, color: AppColors.secondary),
                                              const SizedBox(width: 12),
                                              const Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'hapus',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, size: 18, color: Colors.red),
                                              SizedBox(width: 12),
                                              Text('Hapus', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.more_vert,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                children: peran.fitur.isNotEmpty
                                    ? [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Fitur yang Tersedia:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              ...peran.fitur.map((fitur) => Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.grey[200]!),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.secondary.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Icon(
                                                        Icons.check_circle,
                                                        color: AppColors.secondary,
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            fitur.namaFitur,
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          if (fitur.deskripsiFitur.isNotEmpty) ...[
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              fitur.deskripsiFitur,
                                                              style: TextStyle(
                                                                color: Colors.grey[600],
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )).toList(),
                                            ],
                                          ),
                                        ),
                                      ]
                                    : [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.orange,
                                                size: 20,
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'Belum ada fitur yang ditetapkan untuk peran ini',
                                                  style: TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                ), 
                            ), 
                          ); 
                        }, 
                      ),
                    );
                  }, 
                ),
    ); 
  } 
} 
