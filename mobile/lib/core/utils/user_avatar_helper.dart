import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🌟 Helper to provide beautiful 3D/realistic animated avatars for Male and Female users
class UserAvatarHelper {
  static const String _keySelectedGender = 'batwa_user_gender';
  static const String _keyCustomAvatarUrl = 'batwa_user_custom_avatar_url';

  // High quality, photorealistic/3D character avatars
  static const String defaultMaleAvatar =
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=250&auto=format&fit=crop&q=80';
  
  static const String defaultFemaleAvatar =
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=250&auto=format&fit=crop&q=80';

  // Curated 3D & professional avatar options
  static const List<Map<String, String>> maleAvatars = [
    {
      'id': 'male_1',
      'label': 'Male Avatar 1',
      'url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=250&auto=format&fit=crop&q=80',
    },
    {
      'id': 'male_2',
      'label': 'Male Avatar 2',
      'url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=250&auto=format&fit=crop&q=80',
    },
    {
      'id': 'male_3',
      'label': 'Male Avatar 3',
      'url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=250&auto=format&fit=crop&q=80',
    },
    {
      'id': 'male_4',
      'label': 'Male Avatar 4',
      'url': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=250&auto=format&fit=crop&q=80',
    },
  ];

  static const List<Map<String, String>> femaleAvatars = [
    {
      'id': 'female_1',
      'label': 'Female Avatar 1',
      'url': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=250&auto=format&fit=crop&q=80',
    },
    {
      'id': 'female_2',
      'label': 'Female Avatar 2',
      'url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=250&auto=format&fit=crop&q=80',
    },
    {
      'id': 'female_3',
      'label': 'Female Avatar 3',
      'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=250&auto=format&fit=crop&q=80',
    },
    {
      'id': 'female_4',
      'label': 'Female Avatar 4',
      'url': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=250&auto=format&fit=crop&q=80',
    },
  ];

  static List<String> get allAvatarUrls => [
    ...maleAvatars.map((m) => m['url']!),
    ...femaleAvatars.map((m) => m['url']!),
  ];

  /// Get the active avatar URL (custom > gender based default > fallback male)
  static Future<String> getAvatarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final customUrl = prefs.getString(_keyCustomAvatarUrl);
    if (customUrl != null && customUrl.isNotEmpty) {
      return customUrl;
    }
    final gender = prefs.getString(_keySelectedGender) ?? 'MALE';
    return gender == 'FEMALE' ? defaultFemaleAvatar : defaultMaleAvatar;
  }

  /// Get currently saved gender ('MALE' or 'FEMALE')
  static Future<String> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedGender) ?? 'MALE';
  }

  /// Save selected gender and set default avatar accordingly
  static Future<void> saveGender(String gender, {String? customUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedGender, gender);
    if (customUrl != null && customUrl.isNotEmpty) {
      await prefs.setString(_keyCustomAvatarUrl, customUrl);
    } else {
      final defaultUrl = gender == 'FEMALE' ? defaultFemaleAvatar : defaultMaleAvatar;
      await prefs.setString(_keyCustomAvatarUrl, defaultUrl);
    }
  }

  /// Save custom avatar URL directly
  static Future<void> saveCustomAvatarUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomAvatarUrl, url);
  }

  /// Build a robust, beautiful Avatar Widget with smooth loading and error fallback
  static Widget buildAvatarWidget({
    required String? imageUrl,
    required String gender,
    required double size,
    Border? border,
  }) {
    final fallbackUrl = gender == 'FEMALE' ? defaultFemaleAvatar : defaultMaleAvatar;
    final effectiveUrl = (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : fallbackUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border ?? Border.all(color: Colors.white, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          effectiveUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: const Color(0xFF031E14),
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF3D602)),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF031E14),
              child: Center(
                child: Icon(
                  gender == 'FEMALE' ? Icons.face_3_rounded : Icons.face_rounded,
                  color: const Color(0xFFF3D602),
                  size: size * 0.55,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
