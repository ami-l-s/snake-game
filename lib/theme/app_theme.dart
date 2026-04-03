import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Cute & Cartoonish
  static const Color primary = Color(0xFF6C63FF);      // Soft purple
  static const Color secondary = Color(0xFFFF6B9D);    // Pink
  static const Color accent = Color(0xFFFFD93D);       // Yellow
  static const Color success = Color(0xFF6BCB77);      // Green
  static const Color danger = Color(0xFFFF6B6B);       // Red
  static const Color background = Color(0xFF1A1A2E);   // Dark navy
  static const Color surface = Color(0xFF16213E);      // Darker navy
  static const Color cardBg = Color(0xFF0F3460);       // Card navy
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8D0);

  // Game Grid Colors
  static const Color gridBg = Color(0xFF0D1B2A);
  static const Color gridLine = Color(0xFF1A2D42);
  static const Color snakeHead = Color(0xFF6C63FF);
  static const Color snakeBody = Color(0xFF9B94FF);
  static const Color snakeTail = Color(0xFFCBC8FF);
  static const Color foodColor = Color(0xFFFF6B9D);
  static const Color portalColor = Color(0xFFFFD93D);
  static const Color obstacleColor = Color(0xFF4A4A6A);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(
      const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w900),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class AppConstants {
  // Company Info
  static const String companyName = 'Amilabstech';
  static const String appName = 'Snake';
  static const String version = '1.0.0';
  static const String website = 'https://amilabstech.com';
  static const String supportEmail = 'support@amilabstech.com';
  static const String privacyPolicy = 'https://amilabstech.com/privacy';
  static const String termsOfService = 'https://amilabstech.com/terms';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.amilabstech.snake';

  // Social Media
  static const String twitter = 'https://twitter.com/amilabstech';
  static const String instagram = 'https://instagram.com/amilabstech';
  static const String youtube = 'https://youtube.com/@amilabstech';
  static const String github = 'https://github.com/amilabstech';

  // Ad Unit IDs
  // ─── DEVELOPMENT (swap back before publishing) ─────────────────
  // static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  // static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  // static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  // ─── PRODUCTION ────────────────────────────────────────────────
  static const String bannerAdUnitId = 'ca-app-pub-9755093615040362/6720694934';
  static const String rewardedAdUnitId = 'ca-app-pub-9755093615040362/7217622023';
  static const String interstitialAdUnitId = 'ca-app-pub-9755093615040362/6720694934';

  // IAP Product IDs
  static const String iapVipId = 'snake_munchies_vip';
  static const String iapVipSubscriptionId = 'snake_munchies_vip_sub'; // subscription for premium features
  static const String iapCoinsPack1 = 'coins_pack_10'; // 10 coins for 10 shillings
  static const String iapCoinsPack2 = 'coins_pack_100'; // 100 coins for 80 shillings

  // Game Settings
  static const int gridSize = 20;
  static const int initialGameSpeed = 200; // ms per tick
  static const int minGameSpeed = 80;
  static const int speedIncreaseEvery = 5; // score points
  static const int coinsPerFood = 2;
  static const int coinsPerRevive = 10;
  static const int startingLives = 1;

  // SharedPreferences Keys
  static const String keyHighScore = 'high_score';
  static const String keyCoins = 'coins';
  static const String keySelectedSkin = 'selected_skin';
  static const String keyUnlockedSkins = 'unlocked_skins';
  static const String keyIsVip = 'is_vip';
  static const String keyTotalGamesPlayed = 'total_games';
  static const String keySoundEnabled = 'sound_enabled';
  static const int coinsPerAd = 20;
}

