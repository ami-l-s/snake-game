import 'dart:math';
import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../models/game_models.dart';
import '../theme/app_theme.dart';

class GameBoard extends StatelessWidget {
  final GameController controller;

  const GameBoard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.gridBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CustomPaint(
            painter: _GamePainter(controller: controller),
          ),
        ),
      ),
    );
  }
}

class _GamePainter extends CustomPainter {
  final GameController controller;

  _GamePainter({required this.controller}) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / controller.gridSize;

    _drawGrid(canvas, size, cellSize);
    _drawPortals(canvas, cellSize);
    _drawObstacles(canvas, cellSize);
    _drawFood(canvas, cellSize);
    _drawPowerUpItem(canvas, cellSize);
    _drawSnake(canvas, cellSize);
  }

  void _drawGrid(Canvas canvas, Size size, double cellSize) {
    final paint = Paint()
      ..color = AppTheme.gridLine
      ..strokeWidth = 0.5;

    for (int i = 0; i <= controller.gridSize; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        paint,
      );
    }
  }

  void _drawPortals(Canvas canvas, double cellSize) {
    for (final portal in controller.portals) {
      _drawPortalCell(canvas, portal.entry, portal.color, cellSize);
      _drawPortalCell(canvas, portal.exit, portal.color.withValues(alpha: 0.6), cellSize);
    }
  }

  void _drawPortalCell(Canvas canvas, Point<int> pos, Color color, double cellSize) {
    final rect = _cellRect(pos, cellSize);
    final paint = Paint()..color = color.withValues(alpha: 0.3);
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(4)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(4)),
      borderPaint,
    );

    _drawEmoji(canvas, '🌀', rect.center, cellSize * 0.55);
  }

  void _drawObstacles(Canvas canvas, double cellSize) {
    final paint = Paint()..color = AppTheme.obstacleColor;
    for (final obs in controller.obstacles) {
      final rect = _cellRect(obs, cellSize).deflate(1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }

  void _drawFood(Canvas canvas, double cellSize) {
    if (controller.food == null) return;
    final rect = _cellRect(controller.food!, cellSize);
    _drawEmoji(canvas, controller.foodType.emoji, rect.center, cellSize * 0.65);
  }

  void _drawPowerUpItem(Canvas canvas, double cellSize) {
    if (controller.powerUpItem == null || controller.powerUpItemType == null) return;
    final rect = _cellRect(controller.powerUpItem!, cellSize);

    // Glowing background
    final paint = Paint()
      ..color = controller.powerUpItemType!.color.withValues(alpha: 0.25);
    canvas.drawCircle(rect.center, cellSize * 0.45, paint);

    _drawEmoji(canvas, controller.powerUpItemType!.emoji, rect.center, cellSize * 0.55);
  }

  void _drawSnake(Canvas canvas, double cellSize) {
    final snake = controller.snake;
    final skin = controller.currentSkin;
    final isGhost = controller.activePowerUps
        .any((p) => p.type == PowerUpType.ghost && !p.isExpired);

    for (int i = 0; i < snake.length; i++) {
      final isHead = i == 0;
      final isTail = i == snake.length - 1;

      Color color;
      if (isHead) {
        color = skin.headColor;
      } else if (isTail) {
        color = skin.tailColor;
      } else {
        // Gradient from head to tail
        final t = i / snake.length;
        color = Color.lerp(skin.bodyColor, skin.tailColor, t)!;
      }

      if (isGhost) color = color.withValues(alpha: 0.5);

      final rect = _cellRect(snake[i], cellSize).deflate(isHead ? 0.5 : 1.5);
      final radius = isHead ? 6.0 : 4.0;

      final paint = Paint()..color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        paint,
      );

      // Eyes on head
      if (isHead) {
        _drawSnakeEyes(canvas, rect, controller.direction, cellSize);
      }
    }
  }

  void _drawSnakeEyes(Canvas canvas, Rect headRect, Direction dir, double cellSize) {
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    final eyeRadius = cellSize * 0.1;
    final pupilRadius = cellSize * 0.06;

    Offset eye1, eye2;

    switch (dir) {
      case Direction.right:
        eye1 = Offset(headRect.right - eyeRadius * 2, headRect.top + eyeRadius * 1.5);
        eye2 = Offset(headRect.right - eyeRadius * 2, headRect.bottom - eyeRadius * 1.5);
        break;
      case Direction.left:
        eye1 = Offset(headRect.left + eyeRadius * 2, headRect.top + eyeRadius * 1.5);
        eye2 = Offset(headRect.left + eyeRadius * 2, headRect.bottom - eyeRadius * 1.5);
        break;
      case Direction.up:
        eye1 = Offset(headRect.left + eyeRadius * 1.5, headRect.top + eyeRadius * 2);
        eye2 = Offset(headRect.right - eyeRadius * 1.5, headRect.top + eyeRadius * 2);
        break;
      case Direction.down:
        eye1 = Offset(headRect.left + eyeRadius * 1.5, headRect.bottom - eyeRadius * 2);
        eye2 = Offset(headRect.right - eyeRadius * 1.5, headRect.bottom - eyeRadius * 2);
        break;
    }

    canvas.drawCircle(eye1, eyeRadius, eyePaint);
    canvas.drawCircle(eye2, eyeRadius, eyePaint);
    canvas.drawCircle(eye1, pupilRadius, pupilPaint);
    canvas.drawCircle(eye2, pupilRadius, pupilPaint);
  }

  void _drawEmoji(Canvas canvas, String emoji, Offset center, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  Rect _cellRect(Point<int> cell, double cellSize) {
    return Rect.fromLTWH(
      cell.x * cellSize,
      cell.y * cellSize,
      cellSize,
      cellSize,
    );
  }

  @override
  bool shouldRepaint(_GamePainter old) => true;
}

