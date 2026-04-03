# 🐍 Snake Munchies
**by Amilabstech**

A cute, feature-packed twist on the classic Snake game built with Flutter.

---

## Features

### Gameplay Twists
- ⚡ **Power-ups**: Speed Boost, Shrink, Ghost Mode, Magnet, Shield, Double Coins
- 🌀 **Portals**: Warp around the board
- 🧱 **Dynamic obstacles**: Walls appear as score increases
- 🍎🍕⭐ **Multiple food types**: Normal, Bonus, Power-Up, Golden
- 👀 **Cute snake eyes** that follow direction

### Monetization
- 📺 **Rewarded Ads** — Watch to revive after death
- 🏷️ **Banner Ads** — Shown at bottom (hidden for VIP)
- 👑 **Snake VIP IAP** — Remove ads + unlock premium skins (~$1.99)
- 🪙 **Coin Packs IAP** — 100 or 500 coins
- 🎨 **Skin Shop** — Buy skins with earned coins

### Skins
- Classic, Candy, Dino, Galaxy (buy with coins)
- Rainbow, Lava (VIP exclusive)

---

## Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Set up AdMob
1. Create an AdMob account at https://admob.google.com
2. Create a new app and ad units (Banner, Rewarded, Interstitial)
3. Replace test IDs in `lib/theme/app_theme.dart`:
```dart
static const String bannerAdUnitId = 'YOUR_BANNER_ID';
static const String rewardedAdUnitId = 'YOUR_REWARDED_ID';
static const String interstitialAdUnitId = 'YOUR_INTERSTITIAL_ID';
```
4. Add your AdMob App ID to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
  android:name="com.google.android.gms.ads.APPLICATION_ID"
  android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

### 3. Set up In-App Purchases
1. Create products in Google Play Console / App Store Connect:
   - `snake_munchies_vip` (Non-consumable, ~$1.99)
   - `coins_pack_100` (Consumable)
   - `coins_pack_500` (Consumable)
2. Update company info in `lib/theme/app_theme.dart`:
```dart
static const String website = 'https://amilabstech.com';
static const String supportEmail = 'support@amilabstech.com';
static const String twitter = 'https://twitter.com/amilabstech';
// etc.
```

### 4. Android signing
Make sure your keystore is configured in `android/key.properties` (you've already done this for Amissd!).

### 5. Build
```bash
# Debug
flutter run

# Release AAB for Play Store
flutter build appbundle --release
```

---

## Project Structure
```
lib/
├── main.dart                 # Entry point
├── theme/
│   └── app_theme.dart        # Colors, constants, company info
├── models/
│   └── game_models.dart      # Snake, Food, PowerUp, Skin models
├── game/
│   └── game_controller.dart  # Core game logic (ChangeNotifier)
├── widgets/
│   ├── game_board.dart       # CustomPainter game board
│   └── game_hud.dart         # HUD, D-Pad, badges
├── screens/
│   ├── game_screen.dart      # Main game screen
│   └── shop_screen.dart      # Shop: VIP, Coins, Skins, About
└── services/
    ├── storage_service.dart  # SharedPreferences
    ├── ad_service.dart       # AdMob (banner + rewarded)
    └── iap_service.dart      # In-App Purchases
```

---

## Next Steps (Stage 2+)
- [ ] Add sound effects (audioplayers)
- [ ] Leaderboard (Firebase)
- [ ] Daily challenges
- [ ] 2-player mode
- [ ] Particle effects on food eaten
- [ ] Haptic feedback

---

Built with ❤️ by **Amilabstech**  
Website: https://amilabstech.com  
Support: support@amilabstech.com
