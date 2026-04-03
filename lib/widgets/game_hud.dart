import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/game_controller.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

// ─── Score / Coin HUD ─────────────────────────────────────────────────────────
class GameHUD extends StatelessWidget {
  final GameController controller;

  const GameHUD({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _HUDCard(
          icon: '⭐',
          label: 'Score',
          value: controller.score.toString(),
        ),
        _HUDCard(
          icon: '🏆',
          label: 'Best',
          value: StorageService.instance.highScore.toString(),
        ),
        _HUDCard(
          icon: '🪙',
          label: 'Coins',
          value: controller.coins.toString(),
        ),
        GestureDetector(
          onTap: controller.togglePause,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              controller.gameState == GameState.paused
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
              color: AppTheme.accent,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}

class _HUDCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _HUDCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Active Power-Up Badges ───────────────────────────────────────────────────
class PowerUpBadges extends StatelessWidget {
  final GameController controller;

  const PowerUpBadges({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final active = controller.activePowerUps.where((p) => !p.isExpired).toList();
    if (active.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: active.map((p) => _PowerUpBadge(powerUp: p)).toList(),
    );
  }
}

class _PowerUpBadge extends StatelessWidget {
  final ActivePowerUp powerUp;

  const _PowerUpBadge({required this.powerUp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: powerUp.type.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: powerUp.type.color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(powerUp.type.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          if (powerUp.type.durationSeconds > 0)
            Text(
              '${powerUp.remainingSeconds.toStringAsFixed(1)}s',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: powerUp.type.color,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Power-Up Toast ───────────────────────────────────────────────────────────
class PowerUpToast extends StatelessWidget {
  final String? message;

  const PowerUpToast({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: message != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message ?? '',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppTheme.background,
          ),
        ),
      ),
    );
  }
}

// ─── D-Pad Controls ───────────────────────────────────────────────────────────
class DPadControls extends StatelessWidget {
  final GameController controller;

  const DPadControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DPadButton(
          icon: Icons.keyboard_arrow_up_rounded,
          onTap: () => controller.changeDirection(Direction.up),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DPadButton(
              icon: Icons.keyboard_arrow_left_rounded,
              onTap: () => controller.changeDirection(Direction.left),
            ),
            const SizedBox(width: 52),
            _DPadButton(
              icon: Icons.keyboard_arrow_right_rounded,
              onTap: () => controller.changeDirection(Direction.right),
            ),
          ],
        ),
        _DPadButton(
          icon: Icons.keyboard_arrow_down_rounded,
          onTap: () => controller.changeDirection(Direction.down),
        ),
      ],
    );
  }
}

class _DPadButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DPadButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 32),
      ),
    );
  }
}

