import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/constants/api_constants.dart';

class AppUpdateInfo {
  final String version;
  final int versionCode;
  final String title;
  final String message;
  final String apkUrl;
  final String downloadUrl;
  final bool forceUpdate;
  final List<String> features;

  AppUpdateInfo({
    required this.version,
    required this.versionCode,
    required this.title,
    required this.message,
    required this.apkUrl,
    required this.downloadUrl,
    required this.forceUpdate,
    required this.features,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      version: json['version'] ?? '2.4.16',
      versionCode: json['versionCode'] ?? 256,
      title: json['title'] ?? 'New Update Available',
      message: json['message'] ?? 'A new version of BATWA is available.',
      apkUrl: json['apkUrl'] ?? json['downloadUrl'] ?? 'https://buttwaa.online/batwa-wallet.apk',
      downloadUrl: json['downloadUrl'] ?? json['apkUrl'] ?? 'https://buttwaa.online/#download',
      forceUpdate: json['forceUpdate'] ?? false,
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class AppUpdateService {
  static const int currentVersionCode = 276;
  static const String currentVersionName = "2.4.36";

  /// Server URLs where version.json might be hosted
  static List<String> get updateUrls => [
    'https://buttwaa.online/version.json',
    'https://battwaa.online/version.json',
    '${ApiConstants.baseUrl}/version.json',
    'http://127.0.0.1:3000/version.json',
    'http://10.0.2.2:3000/version.json',
    'http://192.168.0.100:3000/version.json',
  ];

  /// Checks for available update. If found, returns AppUpdateInfo
  static Future<AppUpdateInfo?> checkUpdate() async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    for (final url in updateUrls) {
      try {
        final response = await dio.get(url);
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data is Map ? response.data : Map<String, dynamic>.from(response.data);
          final info = AppUpdateInfo.fromJson(data);

          if (info.versionCode > currentVersionCode) {
            return info;
          }
        }
      } catch (_) {
        // Continue to next probe
      }
    }
    return null;
  }

  /// Automatically prompt user if update is available
  static Future<void> promptIfUpdateAvailable(BuildContext context, {bool showNoUpdateNotice = false}) async {
    try {
      final update = await checkUpdate();
      if (!context.mounted) return;

      if (update != null) {
        showUpdateDialog(context, update);
      } else if (showNoUpdateNotice) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Aapki app pehle se hi latest version (v2.2.0) par hai! ✅"),
            backgroundColor: AppColors.darkNavy,
          ),
        );
      }
    } catch (_) {}
  }

  /// Shows the styled 3D modal update dialog
  static void showUpdateDialog(BuildContext context, AppUpdateInfo update) {
    showDialog(
      context: context,
      barrierDismissible: !update.forceUpdate,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => !update.forceUpdate,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: AppColors.primaryYellow.withOpacity(0.4), width: 2),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          color: AppColors.darkNavy,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              update.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkNavy,
                              ),
                            ),
                            Text(
                              'Version ${update.version} Available',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    update.message,
                    style: const TextStyle(fontSize: 14, color: AppColors.darkNavyLight, height: 1.4),
                  ),
                  if (update.features.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "What's New:",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkNavy),
                    ),
                    const SizedBox(height: 6),
                    ...update.features.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("• ", style: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                f,
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (!update.forceUpdate)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              side: const BorderSide(color: AppColors.lightCardBorder),
                            ),
                            child: const Text("Baad Mein", style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      if (!update.forceUpdate) const SizedBox(width: 12),
                      Expanded(
                        flex: update.forceUpdate ? 1 : 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            final target = update.apkUrl.isNotEmpty ? update.apkUrl : update.downloadUrl;
                            final uri = Uri.tryParse(target);
                            if (uri != null) {
                              try {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } catch (_) {}
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: AppColors.darkNavy,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            "Abhi Update Karein ⚡",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
