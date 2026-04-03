// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import '../game/game_controller.dart' as game;   // ✅ alias to avoid conflicts
import '../models/game_models.dart';
import '../services/ad_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/game_board.dart';
import '../widgets/game_hud.dart';
import 'shop_screen.dart';

// ========== MAIN GAME SCREEN ==========
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late game.GameController _controller;   // ✅ alias
  bool _showReviveDialog = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _controller = game.GameController();
    _controller.addListener(_onGameStateChanged);

    final skinId = StorageService.instance.selectedSkin;
    final skin = allSkins.firstWhere(   // ✅ alias
      (s) => s.id == skinId,
      orElse: () => allSkins.first,
    );
    _controller.setSkin(skin);
  }

  void _onGameStateChanged() {
    if (_controller.gameState == GameState.gameOver && !_showReviveDialog) { // ✅ alias
      setState(() => _showReviveDialog = true);
      _showGameOverScreen();
    }
  }

  void _showGameOverScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _GameOverScreen(
          controller: _controller,
          onWatchAdForCoins: _handleWatchAdForCoins,
          onRestart: _handleRestart,
        ),
      ),
    ).then((_) => setState(() => _showReviveDialog = false));
  }

  void _showStatus(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.nunito()),
      backgroundColor: color ?? AppTheme.primary,
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _handleWatchAdForCoins() async {
    Navigator.of(context).pop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Loading ad…'),
              ]),
            ),
          ),
        ),
      ),
    );

    final rewarded = await AdService.instance.showRewardedAd();
    if (mounted) Navigator.of(context, rootNavigator: true).pop();

    if (rewarded) {
      _controller.addCoins(2);
      _showStatus('Ad watched! +2 coins added', color: AppTheme.success);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black54,
          builder: (_) => Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                _showGameOverScreen();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                decoration: BoxDecoration(
                  color: AppTheme.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🪙', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    '+2 Coins Added!',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to continue',
                    style:
                        GoogleFonts.nunito(fontSize: 14, color: Colors.white70),
                  ),
                ]),
              ),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        _showStatus('No ad available — try again later', color: AppTheme.danger);
        _showGameOverScreen();
      }
    }
  }

  void _handleRestart() {
    Navigator.of(context).pop();
    _controller.saveStats();
    if (_controller.gameState == GameState.paused) {  // ✅ alias
      _controller.togglePause();
    }
    _controller.startGame();
  }

  Future<void> _handlePlayPressed() async {
    if (!AdService.instance.isRewardedAdReady) {
      // Ad not available; allow offline play without waiting.
      _showStatus('No ad available — starting game offline', color: AppTheme.secondary);
      _controller.startGame();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Loading ad…'),
              ]),
            ),
          ),
        ),
      ),
    );

    final rewarded = await AdService.instance.showRewardedAd();
    if (mounted) Navigator.of(context, rootNavigator: true).pop();

    if (rewarded) {
      _controller.addCoins(2);
      _showStatus('Ad watched! +2 coins added', color: AppTheme.success);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black54,
          builder: (_) => Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                _controller.startGame();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                decoration: BoxDecoration(
                  color: AppTheme.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🪙', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    '+2 Coins Added!',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to start game',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        );
      }
    } else {
      // If ad failed, let user play anyway (offline fallback) and notify.
      _showStatus('Unable to load ad — starting game offline', color: AppTheme.secondary);
      _controller.startGame();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.delta.dy > 0) {
              _controller.changeDirection(Direction.down);   // ✅ alias
            } else {
              _controller.changeDirection(Direction.up);
            }
          },
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx > 0) {
              _controller.changeDirection(Direction.right);
            } else {
              _controller.changeDirection(Direction.left);
            }
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GameHUD(controller: _controller),
                ),
                PowerUpBadges(controller: _controller),
                const SizedBox(height: 4),
                PowerUpToast(message: _controller.activePowerUpMessage),
                const SizedBox(height: 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _controller.gameState == GameState.idle  // ✅ alias
                        ? _StartScreen(onStart: _handlePlayPressed)
                        : GameBoard(controller: _controller),
                  ),
                ),
                const SizedBox(height: 12),
                if (_controller.gameState == GameState.playing ||    // ✅ alias
                    _controller.gameState == GameState.paused)
                  DPadControls(controller: _controller),
                const SizedBox(height: 8),
                _BottomBar(controller: _controller),
                if (!StorageService.instance.isVip &&
                    AdService.instance.isBannerAdReady)
                  SizedBox(
                    height:
                        AdService.instance.bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: AdService.instance.bannerAd!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========== POWER-UP BADGES ==========
class PowerUpBadges extends StatelessWidget {
  final game.GameController controller;   // ✅ alias
  const PowerUpBadges({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ========== POWER-UP TOAST ==========
class PowerUpToast extends StatelessWidget {
  final String message;
  const PowerUpToast({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ========== D-PAD CONTROLS ==========
class DPadControls extends StatelessWidget {
  final game.GameController controller;   // ✅ alias
  const DPadControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: _ctrlButton(
              Icons.arrow_upward,
              () => controller.changeDirection(Direction.up),   // ✅ alias
            ),
          ),
          Positioned(
            left: 0,
            child: _ctrlButton(
              Icons.arrow_back,
              () => controller.changeDirection(Direction.left),
            ),
          ),
          Positioned(
            right: 0,
            child: _ctrlButton(
              Icons.arrow_forward,
              () => controller.changeDirection(Direction.right),
            ),
          ),
          Positioned(
            bottom: 0,
            child: _ctrlButton(
              Icons.arrow_downward,
              () => controller.changeDirection(Direction.down),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ctrlButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        backgroundColor: Colors.black54,
        elevation: 2,
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}

// ─── Start Screen ─────────────────────────────────────────────────────────────
class _StartScreen extends StatelessWidget {
  final VoidCallback onStart;
  const _StartScreen({required this.onStart});

  Future<void> _launchStore() async {
    final uri = Uri.parse(AppConstants.playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🐍', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          Text(
            AppConstants.appName,
            style: GoogleFonts.nunito(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Swipe or use D-Pad to move',
            style:
                GoogleFonts.nunito(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(
              'Play! 🎮',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'by ${AppConstants.companyName}',
            style:
                GoogleFonts.nunito(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _launchStore,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < 4 ? Icons.star : Icons.star_half,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '4.5',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Game Over Screen ─────────────────────────────────────────────────────────
class _GameOverScreen extends StatelessWidget {
  final game.GameController controller;   // ✅ alias
  final VoidCallback onWatchAdForCoins;
  final VoidCallback onRestart;

  const _GameOverScreen({
    required this.controller,
    required this.onWatchAdForCoins,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: controller.isNewHighScore
                  ? AppTheme.accent
                  : AppTheme.primary.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.isNewHighScore ? '🏆' : '😵',
                style: const TextStyle(fontSize: 56),
              ),
              const SizedBox(height: 8),
              Text(
                controller.isNewHighScore ? 'New High Score!' : 'Game Over!',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: controller.isNewHighScore
                      ? AppTheme.accent
                      : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatBox(
                      label: 'Score',
                      value: '${controller.score}',
                      color: AppTheme.primary),
                  _StatBox(
                    label: 'Best',
                    value: '${StorageService.instance.highScore}',
                    color: AppTheme.accent,
                  ),
                  _StatBox(
                      label: 'Coins',
                      value: '🪙 ${controller.coins}',
                      color: AppTheme.success),
                ],
              ),
              const SizedBox(height: 24),
              _GOButton(
                emoji: '🪙',
                label: 'Watch Ad for +2 Coins',
                subtitle: 'Free bonus coins!',
                color: AppTheme.success,
                onTap: onWatchAdForCoins,
              ),
              const SizedBox(height: 12),
              _GOButton(
                emoji: '🔄',
                label: 'Restart',
                subtitle: 'Start fresh',
                color: AppTheme.primary,
                onTap: onRestart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: GoogleFonts.nunito(
              fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      Text(label,
          style:
              GoogleFonts.nunito(fontSize: 11, color: AppTheme.textSecondary)),
    ]);
  }
}

class _GOButton extends StatelessWidget {
  final String emoji, label, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _GOButton({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              Text(subtitle,
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8))),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final game.GameController controller;   // ✅ alias
  const _BottomBar({required this.controller});

  void _navigateWithPause(BuildContext context, Widget screen) {
    final wasPlaying = controller.gameState == GameState.playing;   // ✅ alias
    if (wasPlaying) controller.togglePause();

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) {
      if (wasPlaying && controller.gameState == GameState.paused) {
        controller.togglePause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BarButton(
            icon: '🛍️',
            label: 'Shop',
            onTap: () => _navigateWithPause(
              context,
              ShopScreen(controller: controller),
            ),
          ),
          _BarButton(
            icon: '🎨',
            label: 'Skins',
            onTap: () => _navigateWithPause(
              context,
              ShopScreen(controller: controller, startOnSkins: true),
            ),
          ),
          _BarButton(
            icon: '📺',
            label: 'Earn',
            onTap: () => _navigateWithPause(
              context,
              ShopScreen(controller: controller, startOnEarn: true),
            ),
          ),
          _BarButton(
            icon: '🪙',
            label: '${StorageService.instance.coins}',
            onTap: () => _navigateWithPause(
              context,
              ShopScreen(controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _BarButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
            color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}