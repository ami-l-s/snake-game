import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Direction ───────────────────────────────────────────────────────────────
enum Direction { up, down, left, right }

extension DirectionExt on Direction {
  bool isOpposite(Direction other) {
    return (this == Direction.up && other == Direction.down) ||
        (this == Direction.down && other == Direction.up) ||
        (this == Direction.left && other == Direction.right) ||
        (this == Direction.right && other == Direction.left);
  }

  Point<int> get delta {
    switch (this) {
      case Direction.up:    return const Point(0, -1);
      case Direction.down:  return const Point(0, 1);
      case Direction.left:  return const Point(-1, 0);
      case Direction.right: return const Point(1, 0);
    }
  }
}

// ─── Power-Up Types ───────────────────────────────────────────────────────────
enum PowerUpType {
  speedBoost,   // Move faster temporarily
  shrink,       // Reduce snake length by 3
  ghost,        // Pass through own tail
  magnet,       // Food moves toward snake
  shield,       // Survive one wall/tail collision
  doubleCoins,  // 2x coins for 10 seconds
}

extension PowerUpTypeExt on PowerUpType {
  String get emoji {
    switch (this) {
      case PowerUpType.speedBoost:  return '⚡';
      case PowerUpType.shrink:      return '✂️';
      case PowerUpType.ghost:       return '👻';
      case PowerUpType.magnet:      return '🧲';
      case PowerUpType.shield:      return '🛡️';
      case PowerUpType.doubleCoins: return '🪙';
    }
  }

  String get name {
    switch (this) {
      case PowerUpType.speedBoost:  return 'Speed Boost!';
      case PowerUpType.shrink:      return 'Snip Snip!';
      case PowerUpType.ghost:       return 'Ghost Mode!';
      case PowerUpType.magnet:      return 'Food Magnet!';
      case PowerUpType.shield:      return 'Shield Up!';
      case PowerUpType.doubleCoins: return '2x Coins!';
    }
  }

  Color get color {
    switch (this) {
      case PowerUpType.speedBoost:  return const Color(0xFFFFD93D);
      case PowerUpType.shrink:      return const Color(0xFFFF6B9D);
      case PowerUpType.ghost:       return const Color(0xFFB0B8D0);
      case PowerUpType.magnet:      return const Color(0xFF6C63FF);
      case PowerUpType.shield:      return const Color(0xFF6BCB77);
      case PowerUpType.doubleCoins: return const Color(0xFFFFB347);
    }
  }

  int get durationSeconds {
    switch (this) {
      case PowerUpType.speedBoost:  return 5;
      case PowerUpType.shrink:      return 0; // instant
      case PowerUpType.ghost:       return 7;
      case PowerUpType.magnet:      return 8;
      case PowerUpType.shield:      return 0; // instant
      case PowerUpType.doubleCoins: return 10;
    }
  }
}

// ─── Food Types ───────────────────────────────────────────────────────────────
enum FoodType { normal, bonus, powerUp, golden }

extension FoodTypeExt on FoodType {
  String get emoji {
    switch (this) {
      case FoodType.normal:  return '🍎';
      case FoodType.bonus:   return '🍕';
      case FoodType.powerUp: return '✨';
      case FoodType.golden:  return '⭐';
    }
  }

  int get points {
    switch (this) {
      case FoodType.normal:  return 1;
      case FoodType.bonus:   return 3;
      case FoodType.powerUp: return 1;
      case FoodType.golden:  return 10;
    }
  }

  int get coins {
    switch (this) {
      case FoodType.normal:  return 2;
      case FoodType.bonus:   return 5;
      case FoodType.powerUp: return 3;
      case FoodType.golden:  return 20;
    }
  }
}

// ─── Snake Skin ───────────────────────────────────────────────────────────────
enum SkinUnlockType { free, coins, watchAds, vip }

class SnakeSkin {
  final String id;
  final String name;
  final String emoji;
  final Color headColor;
  final Color bodyColor;
  final Color tailColor;
  final int price;           // coins cost (if unlockType == coins)
  final int adsRequired;     // number of ads to watch (if unlockType == watchAds)
  final bool isPremium;      // requires VIP
  final SkinUnlockType unlockType;

  const SnakeSkin({
    required this.id,
    required this.name,
    required this.emoji,
    required this.headColor,
    required this.bodyColor,
    required this.tailColor,
    this.price = 0,
    this.adsRequired = 0,
    this.isPremium = false,
    this.unlockType = SkinUnlockType.free,
  });
}

const List<SnakeSkin> allSkins = [
  // ── Free ─────────────────────────────────────────────────────
  SnakeSkin(
    id: 'classic',
    name: 'Classic',
    emoji: '🐍',
    headColor: Color(0xFF6C63FF),
    bodyColor: Color(0xFF9B94FF),
    tailColor: Color(0xFFCBC8FF),
  ),
  SnakeSkin(
    id: 'forest',
    name: 'Forest',
    emoji: '🌿',
    headColor: Color(0xFF2D6A4F),
    bodyColor: Color(0xFF52B788),
    tailColor: Color(0xFF95D5B2),
  ),
  SnakeSkin(
    id: 'ocean',
    name: 'Ocean',
    emoji: '🌊',
    headColor: Color(0xFF0077B6),
    bodyColor: Color(0xFF00B4D8),
    tailColor: Color(0xFF90E0EF),
  ),

  // ── Watch Ads to unlock ───────────────────────────────────────
  SnakeSkin(
    id: 'candy',
    name: 'Candy',
    emoji: '🍭',
    headColor: Color(0xFFFF6B9D),
    bodyColor: Color(0xFFFFB3CC),
    tailColor: Color(0xFFFFD6E7),
    unlockType: SkinUnlockType.watchAds,
    adsRequired: 3,
  ),
  SnakeSkin(
    id: 'toxic',
    name: 'Toxic',
    emoji: '☢️',
    headColor: Color(0xFF39FF14),
    bodyColor: Color(0xFF7FFF00),
    tailColor: Color(0xFFCCFF00),
    unlockType: SkinUnlockType.watchAds,
    adsRequired: 5,
  ),
  SnakeSkin(
    id: 'sunset',
    name: 'Sunset',
    emoji: '🌅',
    headColor: Color(0xFFFF6B35),
    bodyColor: Color(0xFFFF9F1C),
    tailColor: Color(0xFFFFBF69),
    unlockType: SkinUnlockType.watchAds,
    adsRequired: 5,
  ),

  // ── Buy with Coins ────────────────────────────────────────────
  SnakeSkin(
    id: 'dino',
    name: 'Dino',
    emoji: '🦕',
    headColor: Color(0xFF6BCB77),
    bodyColor: Color(0xFF9DDBA5),
    tailColor: Color(0xFFC8EFCC),
    unlockType: SkinUnlockType.coins,
    price: 120,
  ),
  SnakeSkin(
    id: 'fire',
    name: 'Fire',
    emoji: '🔥',
    headColor: Color(0xFFFF4500),
    bodyColor: Color(0xFFFF8C00),
    tailColor: Color(0xFFFFD700),
    unlockType: SkinUnlockType.coins,
    price: 150,
  ),
  SnakeSkin(
    id: 'ice',
    name: 'Ice',
    emoji: '❄️',
    headColor: Color(0xFF48CAE4),
    bodyColor: Color(0xFFA8DADC),
    tailColor: Color(0xFFE8F4F8),
    unlockType: SkinUnlockType.coins,
    price: 150,
  ),
  SnakeSkin(
    id: 'galaxy',
    name: 'Galaxy',
    emoji: '🌌',
    headColor: Color(0xFF240046),
    bodyColor: Color(0xFF7B2FBE),
    tailColor: Color(0xFFE0AAFF),
    unlockType: SkinUnlockType.coins,
    price: 200,
  ),
  SnakeSkin(
    id: 'midnight',
    name: 'Midnight',
    emoji: '🌙',
    headColor: Color(0xFF1B1B2F),
    bodyColor: Color(0xFF2E2E5E),
    tailColor: Color(0xFF4A4A8A),
    unlockType: SkinUnlockType.coins,
    price: 300,
  ),
  SnakeSkin(
    id: 'rose',
    name: 'Rose Gold',
    emoji: '🌹',
    headColor: Color(0xFFB76E79),
    bodyColor: Color(0xFFD4A5A5),
    tailColor: Color(0xFFF2D7D5),
    unlockType: SkinUnlockType.coins,
    price: 300,
  ),
  SnakeSkin(
    id: 'cherry',
    name: 'Cherry',
    emoji: '🍒',
    headColor: Color(0xFFDC143C),
    bodyColor: Color(0xFFFF6B81),
    tailColor: Color(0xFFFFB3C1),
    unlockType: SkinUnlockType.coins,
    price: 180,
  ),
  SnakeSkin(
    id: 'storm',
    name: 'Storm',
    emoji: '⚡',
    headColor: Color(0xFF4A4E69),
    bodyColor: Color(0xFF9A8C98),
    tailColor: Color(0xFFC9ADA7),
    unlockType: SkinUnlockType.coins,
    price: 220,
  ),

  // ── VIP only ──────────────────────────────────────────────────
  SnakeSkin(
    id: 'rainbow',
    name: 'Rainbow',
    emoji: '🌈',
    headColor: Color(0xFFFF6B6B),
    bodyColor: Color(0xFFFFD93D),
    tailColor: Color(0xFF6BCB77),
    isPremium: true,
    unlockType: SkinUnlockType.vip,
  ),
  SnakeSkin(
    id: 'lava',
    name: 'Lava',
    emoji: '🌋',
    headColor: Color(0xFFFF4500),
    bodyColor: Color(0xFFFF6B35),
    tailColor: Color(0xFFFFAB73),
    isPremium: true,
    unlockType: SkinUnlockType.vip,
  ),
  SnakeSkin(
    id: 'diamond',
    name: 'Diamond',
    emoji: '💎',
    headColor: Color(0xFFB9F2FF),
    bodyColor: Color(0xFF7FDBFF),
    tailColor: Color(0xFFE0F7FA),
    isPremium: true,
    unlockType: SkinUnlockType.vip,
  ),
  SnakeSkin(
    id: 'gold',
    name: 'Gold',
    emoji: '✨',
    headColor: Color(0xFFFFD700),
    bodyColor: Color(0xFFFFC200),
    tailColor: Color(0xFFFFE066),
    isPremium: true,
    unlockType: SkinUnlockType.vip,
  ),
  SnakeSkin(
    id: 'neon',
    name: 'Neon',
    emoji: '💡',
    headColor: Color(0xFFFF00FF),
    bodyColor: Color(0xFF00FFFF),
    tailColor: Color(0xFFFFFF00),
    isPremium: true,
    unlockType: SkinUnlockType.vip,
  ),
  SnakeSkin(
    id: 'void',
    name: 'Void',
    emoji: '🌑',
    headColor: Color(0xFF000000),
    bodyColor: Color(0xFF1A1A1A),
    tailColor: Color(0xFF333333),
    isPremium: true,
    unlockType: SkinUnlockType.vip,
  ),
];

// ─── Game State ───────────────────────────────────────────────────────────────
enum GameState { idle, playing, paused, gameOver }

class ActivePowerUp {
  final PowerUpType type;
  final DateTime expiresAt;

  ActivePowerUp({required this.type, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  double get remainingSeconds => max(0, expiresAt.difference(DateTime.now()).inMilliseconds / 1000);
}

class Portal {
  final Point<int> entry;
  final Point<int> exit;
  final Color color;

  const Portal({required this.entry, required this.exit, required this.color});
}

