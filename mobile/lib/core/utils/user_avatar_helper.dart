import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🌟 Helper to provide beautiful 3D Pixar character avatars for Male and Female users
class UserAvatarHelper {
  static const String _keySelectedGender = 'batwa_user_gender';
  static const String _keyCustomAvatarUrl = 'batwa_user_custom_avatar_url';

  // High quality 3D Pixar Character Avatars
  static const String defaultMaleAvatar = 'assets/images/avatars/avatar_male_1.png';
  static const String defaultFemaleAvatar = 'assets/images/avatars/avatar_female_1.png';

  // Curated 3D Pixar Avatar Options (Old unsplash photos completely removed)
  static const List<Map<String, String>> maleAvatars = [
    {
      'id': 'male_1',
      'label': 'Male 1 (Glasses & Beard)',
      'url': 'assets/images/avatars/avatar_male_1.png',
    },
    {
      'id': 'male_2',
      'label': 'Male 2 (Silver Hair & Glasses)',
      'url': 'assets/images/avatars/avatar_male_2.png',
    },
    {
      'id': 'male_3',
      'label': 'Male 3 (Teen Teal Hoodie)',
      'url': 'assets/images/avatars/avatar_male_3.png',
    },
    {
      'id': 'male_4',
      'label': 'Male 4 (Black Shirt & Glasses)',
      'url': 'assets/images/avatars/avatar_male_4.png',
    },
    {
      'id': 'male_5',
      'label': 'Male 5 (Blue Shirt & Trimmed Beard)',
      'url': 'assets/images/avatars/avatar_male_5.png',
    },
    {
      'id': 'male_6',
      'label': 'Male 6 (Navy Polo & Earring)',
      'url': 'assets/images/avatars/avatar_male_6.png',
    },
    {
      'id': 'male_7',
      'label': 'Male 7 (Afro Fade & Hoodie)',
      'url': 'assets/images/avatars/avatar_male_7.png',
    },
    {
      'id': 'male_8',
      'label': 'Male 8 (Teen Yellow Hoodie)',
      'url': 'assets/images/avatars/avatar_male_8.png',
    },
    {
      'id': 'male_9',
      'label': 'Male 9 (Curly Hair, Glasses & Red Hoodie)',
      'url': 'assets/images/avatars/avatar_male_9.png',
    },
    {
      'id': 'male_10',
      'label': 'Male 10 (Spiky Hair, Beard & Blue Shirt)',
      'url': 'assets/images/avatars/avatar_male_10.png',
    },
    {
      'id': 'male_11',
      'label': 'Male 11 (Wavy Hair, Beard & Traditional Tunic)',
      'url': 'assets/images/avatars/avatar_male_11.png',
    },
    {
      'id': 'male_12',
      'label': 'Male 12 (Spiky Hair, Beard & Red Flannel)',
      'url': 'assets/images/avatars/avatar_male_12.png',
    },
  ];

  static const List<Map<String, String>> femaleAvatars = [
    {
      'id': 'female_1',
      'label': 'Female 1 (Bun & Glasses)',
      'url': 'assets/images/avatars/avatar_female_1.png',
    },
    {
      'id': 'female_2',
      'label': 'Female 2 (Wavy Hair & Smile)',
      'url': 'assets/images/avatars/avatar_female_2.png',
    },
    {
      'id': 'female_3',
      'label': 'Female 3 (White Shirt & Bun)',
      'url': 'assets/images/avatars/avatar_female_3.png',
    },
    {
      'id': 'female_4',
      'label': 'Female 4 (Bob Hair & Glasses)',
      'url': 'assets/images/avatars/avatar_female_4.png',
    },
    {
      'id': 'female_5',
      'label': 'Female 5 (Yellow Cardigan)',
      'url': 'assets/images/avatars/avatar_female_5.png',
    },
    {
      'id': 'female_6',
      'label': 'Female 6 (Green Shirt & Waving)',
      'url': 'assets/images/avatars/avatar_female_6.png',
    },
    {
      'id': 'female_7',
      'label': 'Female 7 (Hijab & Blazer)',
      'url': 'assets/images/avatars/avatar_female_7.png',
    },
    {
      'id': 'female_8',
      'label': 'Female 8 (Brown Hijab & Blazer)',
      'url': 'assets/images/avatars/avatar_female_8.png',
    },
    {
      'id': 'female_9',
      'label': 'Female 9 (Green Eyes & Freckles)',
      'url': 'assets/images/avatars/avatar_female_9.png',
    },
    {
      'id': 'female_10',
      'label': 'Female 10 (Wavy Hair & Purple BG)',
      'url': 'assets/images/avatars/avatar_female_10.png',
    },
    {
      'id': 'female_11',
      'label': 'Female 11 (Long Hair, Subtle Smile & Pink BG)',
      'url': 'assets/images/avatars/avatar_female_11.png',
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
      // If stored URL is outdated, unsplash, or removed, migrate to default
      if (customUrl.contains('unsplash.com') || customUrl.contains('http') || !allAvatarUrls.contains(customUrl)) {
        final gender = prefs.getString(_keySelectedGender) ?? 'MALE';
        final newDefault = gender == 'FEMALE' ? defaultFemaleAvatar : defaultMaleAvatar;
        await prefs.setString(_keyCustomAvatarUrl, newDefault);
        return newDefault;
      }
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
    if (customUrl != null && customUrl.isNotEmpty && !customUrl.contains('unsplash.com')) {
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
    String effectiveUrl = (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : fallbackUrl;

    // Auto-migrate old unsplash links to fresh 3D Pixar avatar
    if (effectiveUrl.contains('unsplash.com')) {
      effectiveUrl = fallbackUrl;
    }

    Widget imageChild;
    if (effectiveUrl.startsWith('assets/')) {
      imageChild = Image.asset(
        effectiveUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/default_avatar.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF031E14),
            child: Center(
              child: Icon(
                gender == 'FEMALE' ? Icons.face_3_rounded : Icons.face_rounded,
                color: const Color(0xFFF3D602),
                size: size * 0.55,
              ),
            ),
          ),
        ),
      );
    } else {
      imageChild = Image.network(
        effectiveUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          defaultMaleAvatar,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF031E14),
            child: Center(
              child: Icon(
                gender == 'FEMALE' ? Icons.face_3_rounded : Icons.face_rounded,
                color: const Color(0xFFF3D602),
                size: size * 0.55,
              ),
            ),
          ),
        ),
      );
    }

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
      child: ClipOval(child: imageChild),
    );
  }
}
