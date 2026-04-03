import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── High Score ───────────────────────────────────────────────
  int get highScore => _prefs.getInt(AppConstants.keyHighScore) ?? 0;

  Future<bool> setHighScore(int score) async {
    if (score > highScore) {
      await _prefs.setInt(AppConstants.keyHighScore, score);
      return true; // new high score!
    }
    return false;
  }

  // ─── Coins ────────────────────────────────────────────────────
  int get coins => _prefs.getInt(AppConstants.keyCoins) ?? 0;

  Future<void> addCoins(int amount) async {
    await _prefs.setInt(AppConstants.keyCoins, coins + amount);
  }

  Future<bool> spendCoins(int amount) async {
    if (coins >= amount) {
      await _prefs.setInt(AppConstants.keyCoins, coins - amount);
      return true;
    }
    return false;
  }

  // ─── Skin ─────────────────────────────────────────────────────
  String get selectedSkin =>
      _prefs.getString(AppConstants.keySelectedSkin) ?? 'classic';

  Future<void> setSelectedSkin(String skinId) async {
    await _prefs.setString(AppConstants.keySelectedSkin, skinId);
  }

  List<String> get unlockedSkins {
    final raw = _prefs.getStringList(AppConstants.keyUnlockedSkins);
    return raw ?? ['classic'];
  }

  Future<void> unlockSkin(String skinId) async {
    final current = unlockedSkins;
    if (!current.contains(skinId)) {
      current.add(skinId);
      await _prefs.setStringList(AppConstants.keyUnlockedSkins, current);
    }
  }

  bool isSkinUnlocked(String skinId) => unlockedSkins.contains(skinId);

  // ─── VIP ──────────────────────────────────────────────────────
  bool get isVip => _prefs.getBool(AppConstants.keyIsVip) ?? false;

  Future<void> setVip(bool value) async {
    await _prefs.setBool(AppConstants.keyIsVip, value);
    if (value) {
      // VIP unlocks all premium skins
      for (final id in ['rainbow', 'lava', 'diamond', 'gold', 'neon', 'void']) {
        await unlockSkin(id);
      }
    }
  }

  // ─── Skin ad-watch progress ───────────────────────────────────
  int skinAdWatches(String skinId) =>
      _prefs.getInt('skin_ads_$skinId') ?? 0;

  Future<int> incrementSkinAdWatch(String skinId) async {
    final current = skinAdWatches(skinId) + 1;
    await _prefs.setInt('skin_ads_$skinId', current);
    return current;
  }

  // ─── Stats ────────────────────────────────────────────────────
  int get totalGamesPlayed =>
      _prefs.getInt(AppConstants.keyTotalGamesPlayed) ?? 0;

  Future<void> incrementGamesPlayed() async {
    await _prefs.setInt(
        AppConstants.keyTotalGamesPlayed, totalGamesPlayed + 1);
  }

  // ─── Settings ─────────────────────────────────────────────────
  bool get soundEnabled => _prefs.getBool(AppConstants.keySoundEnabled) ?? true;

  Future<void> setSoundEnabled(bool value) async {
    await _prefs.setBool(AppConstants.keySoundEnabled, value);
  }
}

