import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/task/widgets/video.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfessionalLampiranWidget extends StatefulWidget {
  final String url;

  const ProfessionalLampiranWidget({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<ProfessionalLampiranWidget> createState() =>
      _ProfessionalLampiranWidgetState();
}

class _ProfessionalLampiranWidgetState
    extends State<ProfessionalLampiranWidget> {
  String get fileExtension => widget.url.split('.').last.toLowerCase();

  String get fileName {
    final uri = Uri.tryParse(widget.url);
    if (uri != null) {
      return uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'file.$fileExtension';
    }
    return 'file.$fileExtension';
  }

  IconData get fileIcon {
    if (['mp4', 'mov', 'avi', '3gp', 'mkv', 'flv'].contains(fileExtension)) {
      return Icons.video_library_rounded;
    } else if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp']
        .contains(fileExtension)) {
      return Icons.image_rounded;
    } else if (fileExtension == 'pdf') {
      return Icons.picture_as_pdf_rounded;
    } else if (['mp3', 'wav', 'm4a', 'aac', 'flac'].contains(fileExtension)) {
      return Icons.audio_file_rounded;
    } else if (['doc', 'docx'].contains(fileExtension)) {
      return Icons.description_rounded;
    } else if (['xls', 'xlsx'].contains(fileExtension)) {
      return Icons.table_chart_rounded;
    } else if (['zip', 'rar', '7z'].contains(fileExtension)) {
      return Icons.folder_zip_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  Future<void> _downloadFile(BuildContext context) async {
    try {
      final uri = Uri.parse(widget.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackbar(context, 'Tidak dapat membuka file');
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Gagal mengunduh file: ${e.toString()}');
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    if (['mp4', 'mov', 'avi', '3gp', 'mkv', 'flv'].contains(fileExtension)) {
      return _buildVideoPlayer(context);
    } else if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp']
        .contains(fileExtension)) {
      return _buildImageViewer(context, isSmallScreen);
    } else if (fileExtension == 'pdf') {
      return _buildPdfPlaceholder(context, isSmallScreen);
    } else if (['mp3', 'wav', 'm4a', 'aac', 'flac'].contains(fileExtension)) {
      return _buildAudioPlaceholder(context, isSmallScreen);
    } else {
      return _buildDownloadCard(context, isSmallScreen);
    }
  }

  Widget _buildFullscreenButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.fullscreen,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  void _openImageFullscreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5,
                    child: Image.network(widget.url, fit: BoxFit.contain),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openVideoFullscreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: VideoPlayerWidget(
                    videoUrl: widget.url,
                    isFullscreen: true, // kalau ada
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            VideoPlayerWidget(videoUrl: widget.url),
            Positioned(
              right: 8,
              bottom: 8,
              child: _buildFullscreenButton(
                context,
                onTap: () => _openVideoFullscreen(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer(BuildContext context, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                widget
                    .url, // atau getFullUrl(tugas.lampiran!) kalau dari TugasModel
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                // <-- testing error builder
                errorBuilder: (context, error, stackTrace) {
                  // debugPrint("❌ Error load image: $error"); // <-- ini akan tampil di console
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_rounded,
                            size: isSmallScreen ? 48 : 64,
                            color: AppColors.putih.withOpacity(0.5)),
                        SizedBox(height: 12),
                        Text(
                          'Gagal memuat gambar',
                          style: GoogleFonts.poppins(
                            color: AppColors.putih.withOpacity(0.7),
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                        Text(
                          error
                              .toString(), // <-- tampilkan error di UI juga supaya jelas
                          style: TextStyle(color: Colors.red, fontSize: 10),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: _buildFullscreenButton(
                context,
                onTap: () => _openImageFullscreen(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfPlaceholder(BuildContext context, bool isSmallScreen) {
    return _buildFileCard(
      context: context,
      icon: Icons.picture_as_pdf_rounded,
      title: 'Dokumen PDF',
      subtitle: 'Klik tombol di bawah untuk membuka PDF',
      isSmallScreen: isSmallScreen,
    );
  }

  Widget _buildAudioPlaceholder(BuildContext context, bool isSmallScreen) {
    return _buildFileCard(
      context: context,
      icon: Icons.audio_file_rounded,
      title: 'File Audio',
      subtitle: 'Klik tombol di bawah untuk memutar audio',
      isSmallScreen: isSmallScreen,
    );
  }

  Widget _buildFileCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isSmallScreen ? 48 : 64,
              color: AppColors.putih,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.putih,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.putih.withOpacity(0.8),
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          _buildDownloadButton(context, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildDownloadCard(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              fileIcon,
              size: isSmallScreen ? 48 : 64,
              color: AppColors.putih,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            fileName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppColors.putih,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              fileExtension.toUpperCase(),
              style: GoogleFonts.poppins(
                color: AppColors.putih,
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          _buildDownloadButton(context, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context, bool isSmallScreen) {
    return ElevatedButton.icon(
      onPressed: () => _downloadFile(context),
      icon: Icon(
        Icons.download_rounded,
        size: isSmallScreen ? 18 : 20,
        color: AppColors.putih,
      ),
      label: Text(
        'Unduh File',
        style: GoogleFonts.poppins(
          color: AppColors.putih,
          fontSize: isSmallScreen ? 14 : 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.putih,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 24 : 32,
          vertical: isSmallScreen ? 12 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
        shadowColor: AppColors.secondary.withOpacity(0.5),
      ),
    );
  }
}
