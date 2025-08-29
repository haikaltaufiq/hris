// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:hr/data/models/gaji_model.dart';
import 'package:hr/data/models/potongan_gaji.dart';
import 'package:hr/data/services/gaji_service.dart';

class WebPageGaji extends StatefulWidget {
  const WebPageGaji({super.key});

  @override
  State<WebPageGaji> createState() => _WebPageGajiState();
}

class _WebPageGajiState extends State<WebPageGaji> {
  String _searchQuery = '';
  String _sortBy = 'nama'; // nama, gaji_pokok, gaji_bersih
  bool _ascending = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Data List
          Expanded(
            child: FutureBuilder<List<GajiUser>>(
              future: GajiService.fetchGaji(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Memuat data gaji..."),
                      ],
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text("Error: ${snapshot.error}"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text("Coba Lagi"),
                        ),
                      ],
                    ),
                  );
                }

                List<GajiUser> data = snapshot.data ?? [];
                
                // Filter berdasarkan search query
                if (_searchQuery.isNotEmpty) {
                  data = data.where((gaji) => 
                    gaji.nama.toLowerCase().contains(_searchQuery)
                  ).toList();
                }

                // Sort data
                data.sort((a, b) {
                  dynamic valueA, valueB;
                  switch (_sortBy) {
                    case 'nama':
                      valueA = a.nama;
                      valueB = b.nama;
                      break;
                    case 'gaji_pokok':
                      valueA = a.gajiPokok;
                      valueB = b.gajiPokok;
                      break;
                    case 'gaji_bersih':
                      valueA = a.gajiBersih;
                      valueB = b.gajiBersih;
                      break;
                    default:
                      valueA = a.nama;
                      valueB = b.nama;
                  }
                  
                  int result = valueA.compareTo(valueB);
                  return _ascending ? result : -result;
                });

                if (data.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Tidak ada data yang ditemukan"),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final gaji = data[index];
                    return _buildGajiCard(gaji);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGajiCard(GajiUser gaji) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            gaji.nama.isNotEmpty ? gaji.nama[0].toUpperCase() : 'U',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ),
        title: Text(
          gaji.nama,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gaji Bersih: ${_formatCurrency(gaji.gajiBersih)}",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text("Status: "),
                DropdownButton<String>(
                  value: gaji.status,
                  items: const [
                    DropdownMenuItem(value: "Belum Dibayar", child: Text("Belum Dibayar")),
                    DropdownMenuItem(value: "Sudah Dibayar", child: Text("Sudah Dibayar")),
                  ],
                  onChanged: (newValue) {
                    if (newValue != null) {
                      GajiService.updateStatus(gaji.id, newValue).then((_) {
                        setState(() {
                          gaji.status = newValue;
                        });
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),

        children: [
          _buildGajiDetail(gaji),
        ],
      ),
    );
  }

  Widget _buildGajiDetail(GajiUser gaji) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            "Rincian Gaji",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // Gaji Pokok
          _buildDetailRow(
            "Gaji Pokok", 
            _formatCurrency(gaji.gajiPokok), 
            Colors.blue,
            Icons.account_balance_wallet,
          ),
          
          // Lembur
          _buildDetailRow(
            "Total Lembur", 
            _formatCurrency(gaji.totalLembur), 
            Colors.orange,
            Icons.access_time,
          ),
          
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          
          // Potongan Section
          Row(
            children: [
              Icon(Icons.remove_circle_outline, size: 16, color: Colors.red[600]),
              const SizedBox(width: 8),
              const Text(
                "Detail Potongan:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // List Potongan
          if (gaji.potongan.isNotEmpty)
            ...gaji.potongan.map((p) => _buildPotonganItem(p))
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Tidak ada potongan",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          
          // Total Potongan
          _buildDetailRow(
            "Total Potongan", 
            "-${_formatCurrency(gaji.totalPotongan)}", 
            Colors.red,
            Icons.remove_circle,
            isTotal: true,
          ),
          
          const SizedBox(height: 8),
          const Divider(thickness: 2),
          const SizedBox(height: 8),
          
          // Gaji Bersih
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      "Gaji Bersih",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatCurrency(gaji.gajiBersih),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color, IconData icon, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPotonganItem(PotonganGajiModel potongan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  potongan.namaPotongan,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "${potongan.nominal}%",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            "-${_formatCurrency(potongan.nilai ?? 0)}",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Format angka dengan pemisah ribuan
    String result = amount.toStringAsFixed(0);
    String formatted = '';
    int counter = 0;
    
    for (int i = result.length - 1; i >= 0; i--) {
      if (counter == 3) {
        formatted = '.$formatted';
        counter = 0;
      }
      formatted = result[i] + formatted;
      counter++;
    }
    
    return 'Rp $formatted';
  }
}