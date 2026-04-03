// lib/game/game_controller.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../services/storage_service.dart';

class GameController extends ChangeNotifier {
  // Game state
  GameState _gameState = GameState.idle;
  GameState get gameState => _gameState;

  int _score = 0;
  int get score => _score;

  int _coins = 0;
  int get coins => _coins;

  int _highScore = 0;
  int get highScore => _highScore;

  String _activePowerUpMessage = '';
  String get activePowerUpMessage => _activePowerUpMessage;

  // Snake and food (simplified – expand as needed)
  List<Point<int>> _snake = [Point(5, 5), Point(4, 5), Point(3, 5)];
  List<Point<int>> get snake => _snake;

  Point<int> _food = Point(10, 10);
  Point<int> get food => _food;

  Direction _currentDirection = Direction.right;
  Direction get currentDirection => _currentDirection;

  // Skin
  SnakeSkin _selectedSkin = allSkins.first;
  SnakeSkin get selectedSkin => _selectedSkin;
  SnakeSkin get currentSkin => _selectedSkin;

  // Game constants
  int get gridSize => 20;

  // Game timer
  Timer? _gameTimer;

  // Additional properties for widgets
  List<Portal> get portals => [];
  List<Point<int>> get obstacles => [];
  FoodType get foodType => FoodType.normal;
  Point<int>? get powerUpItem => null;
  PowerUpType? get powerUpItemType => null;
  List<ActivePowerUp> get activePowerUps => [];
  Direction get direction => _currentDirection;

  // Constructor
  GameController() {
    _loadCoins();
    _loadHighScore();
  }

  void _loadCoins() async {
    _coins = StorageService.instance.coins;
    notifyListeners();
  }

  void _loadHighScore() async {
    _highScore = StorageService.instance.highScore;
    notifyListeners();
  }

  void setSkin(SnakeSkin skin) {
    _selectedSkin = skin;
    notifyListeners();
  }

  void startGame() {
    _gameState = GameState.playing;
    _score = 0;
    _snake = [Point(5, 5), Point(4, 5), Point(3, 5)];
    _currentDirection = Direction.right;
    _generateFood();
    _startGameLoop();
    notifyListeners();
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_gameState == GameState.playing) {
        _moveSnake();
      }
    });
  }

  void _moveSnake() {
    Point<int> head = _snake.first;
    Point<int> newHead = Point<int>(head.x + _currentDirection.delta.x, head.y + _currentDirection.delta.y);

    // Check wall collision
    if (newHead.x < 1 || newHead.x > gridSize || newHead.y < 1 || newHead.y > gridSize) {
      _gameState = GameState.gameOver;
      _gameTimer?.cancel();
      notifyListeners();
      return;
    }

    // Check self collision
    if (_snake.contains(newHead)) {
      _gameState = GameState.gameOver;
      _gameTimer?.cancel();
      notifyListeners();
      return;
    }

    _snake.insert(0, newHead);

    // Check food
    if (newHead == _food) {
      _score++;
      _generateFood();
    } else {
      _snake.removeLast();
    }

    notifyListeners();
  }

  void togglePause() {
    if (_gameState == GameState.playing) {
      _gameState = GameState.paused;
      _gameTimer?.cancel();
    } else if (_gameState == GameState.paused) {
      _gameState = GameState.playing;
      _startGameLoop();
    }
    notifyListeners();
  }

  void changeDirection(Direction newDirection) {
    if ((_currentDirection == Direction.right && newDirection == Direction.left) ||
        (_currentDirection == Direction.left && newDirection == Direction.right) ||
        (_currentDirection == Direction.up && newDirection == Direction.down) ||
        (_currentDirection == Direction.down && newDirection == Direction.up)) {
      return; // prevent 180-degree turns
    }
    _currentDirection = newDirection;
    notifyListeners();
  }

  void addCoins(int amount) {
    _coins += amount;
    StorageService.instance.addCoins(amount);
    notifyListeners();
  }

  void saveStats() {
    // Save high score, etc.
    if (_score > _highScore) {
      _highScore = _score;
      StorageService.instance.setHighScore(_score);
    }
  }

  bool get isNewHighScore => _score > _highScore;

  void _generateFood() {
    do {
      _food = Point<int>(
        Random().nextInt(gridSize) + 1,
        Random().nextInt(gridSize) + 1,
      );
    } while (_snake.contains(_food));
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}