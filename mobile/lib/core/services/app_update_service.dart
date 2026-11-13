import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const int currentVersionCode = 286;
  static const String currentVersionName = "2.4.46";

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

  static const String _keyDismissedVersion = "dismissed_update_version_code";

  /// Checks if this update version was already dismissed by the user
  static Future<bool> isVersionDismissed(int versionCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissed = prefs.getInt(_keyDismissedVersion) ?? 0;
      return dismissed >= versionCode;
    } catch (_) {
      return false;
    }
  }

  /// Remembers that the user closed/dismissed this update version so it never annoys them again
  static Future<void> markVersionDismissed(int versionCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyDismissedVersion, versionCode);
    } catch (_) {}
  }

  static bool _isDialogShowing = false;

  /// Automatically prompt user if update is available
  static Future<void> promptIfUpdateAvailable(BuildContext context, {bool showNoUpdateNotice = false, bool forceCheck = false}) async {
    if (_isDialogShowing) return;
    try {
      final update = await checkUpdate();
      if (!context.mounted) return;

      if (update != null) {
        // If not forceCheck and user already dismissed this version, do not harass them on screen transitions
        if (!forceCheck && !update.forceUpdate) {
          final isDismissed = await isVersionDismissed(update.versionCode);
          if (isDismissed) return;
        }

        if (context.mounted && !_isDialogShowing) {
          _isDialogShowing = true;
          showUpdateDialog(context, update);
        }
      } else if (showNoUpdateNotice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Aapki app pehle se hi latest version ($currentVersionName) par hai! ✅"),
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
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(color: AppColors.primaryYellow.withOpacity(0.5), width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Icon, Title, and Direct Top-Right Close 'X' Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          color: AppColors.darkNavy,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              update.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkNavy,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Version ${update.version} Available',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Top Right Close 'X' Button
                      if (!update.forceUpdate)
                        InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            markVersionDismissed(update.versionCode);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.darkNavy.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppColors.darkNavy,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    update.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.darkNavyLight, height: 1.3),
                  ),
                  if (update.features.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "What's New:",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkNavy),
                    ),
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 120),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: update.features.take(3).map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ", style: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: Text(
                                      f,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  // Always visible Bottom Buttons
                  Row(
                    children: [
                      if (!update.forceUpdate)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _isDialogShowing = false;
                              Navigator.pop(ctx);
                              markVersionDismissed(update.versionCode);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              side: const BorderSide(color: AppColors.lightCardBorder),
                            ),
                            child: const Text("Baad Mein", style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                      if (!update.forceUpdate) const SizedBox(width: 10),
                      Expanded(
                        flex: update.forceUpdate ? 1 : 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            _isDialogShowing = false;
                            Navigator.pop(ctx);
                            markVersionDismissed(update.versionCode);
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            "Abhi Update Karein ⚡",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
    ).then((_) {
      if (!update.forceUpdate) {
        markVersionDismissed(update.versionCode);
      }
    });
  }
}
