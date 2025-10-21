import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guess1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const GuessingGame(),
    );
  }
}

class GuessingGame extends StatefulWidget {
  const GuessingGame({super.key});

  @override
  State<GuessingGame> createState() => _GuessingGameState();
}

class _GuessingGameState extends State<GuessingGame> {
  // Constants
  static const int maxNumber = 90;
  static const int minNumber = 1;
  static const int correctAnswerPoints = 10;
  static const int wrongAnswerPenalty = 5;
  static const int blinkDurationMs = 150;
  static const int blinkCount = 6;
  static const int feedbackDurationMs = 1500;

  // Game state
  final Random _random = Random();
  int _score = 0;
  int? _currentNumber;
  int? _leftNumber;
  int? _rightNumber;
  bool _isBlinking = false;
  Timer? _blinkTimer;
  bool _showDot = true;
  String _feedbackMessage = '';
  bool _showFeedback = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _startGame);
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isBlinking = true;
      _showDot = true;
    });

    int currentBlinkCount = 0;
    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(
      const Duration(milliseconds: blinkDurationMs),
      (timer) {
        setState(() {
          _showDot = !_showDot;
        });
        currentBlinkCount++;
        if (currentBlinkCount >= blinkCount) {
          timer.cancel();
          _generateNewRound();
        }
      },
    );
  }

  void _generateNewRound() {
    setState(() {
      _isBlinking = false;
      _currentNumber = _random.nextInt(maxNumber) + minNumber;

      // Generate one bigger and one smaller number
      int biggerNumber =
          _currentNumber! + _random.nextInt(maxNumber - _currentNumber!) + 1;
      int smallerNumber = _random.nextInt(_currentNumber!) + minNumber;

      // Randomly assign to left or right
      if (_random.nextBool()) {
        _leftNumber = biggerNumber;
        _rightNumber = smallerNumber;
      } else {
        _leftNumber = smallerNumber;
        _rightNumber = biggerNumber;
      }
    });
  }

  void _handleButtonPress(bool isLeftSelected) {
    if (_currentNumber == null || _isBlinking) return;

    int selectedNumber = isLeftSelected ? _leftNumber! : _rightNumber!;
    int otherNumber = isLeftSelected ? _rightNumber! : _leftNumber!;

    setState(() {
      if (selectedNumber > otherNumber) {
        _score += correctAnswerPoints;
        _feedbackMessage = 'GREATER number! +$correctAnswerPoints';
        _showFeedback = true;
      } else {
        _score -= wrongAnswerPenalty;
        _feedbackMessage = 'LOWER number! -$wrongAnswerPenalty';
        _showFeedback = true;
      }
    });

    Future.delayed(const Duration(milliseconds: feedbackDurationMs), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
        });
      }
      Future.delayed(const Duration(milliseconds: 400), _startGame);
    });
  }

  void _resetGame() {
    _blinkTimer?.cancel();
    setState(() {
      _score = 0;
      _currentNumber = null;
      _leftNumber = null;
      _rightNumber = null;
      _isBlinking = false;
      _showDot = true;
      _feedbackMessage = '';
      _showFeedback = false;
    });
    Future.delayed(const Duration(milliseconds: 100), _startGame);
  }

  Widget _buildBlinkingDots() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (rowIndex) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (colIndex) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _showDot ? Colors.red : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameButton({
    required VoidCallback onTap,
    required Color color,
    required double size,
    Widget? child,
  }) {
    return InkWell(
      onTap: _isBlinking ? null : onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _isBlinking ? color.withValues(alpha: 0.5) : color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: Container(
            width: screenWidth > 400 ? 350 : screenWidth * 0.9,
            height: screenHeight * 0.85,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Title
                const Text(
                  'Guess1',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 30),

                // Blinking dots or number display
                SizedBox(
                  height: 40,
                  child: _isBlinking
                      ? _buildBlinkingDots()
                      : _currentNumber != null
                      ? Text(
                          '$_currentNumber',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        )
                      : _buildBlinkingDots(),
                ),

                const SizedBox(height: 30),

                // Separate bar placeholder
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(height: 40),

                // Feedback message
                SizedBox(
                  height: 60,
                  child: AnimatedOpacity(
                    opacity: _showFeedback ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _feedbackMessage.contains('GREATER')
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _feedbackMessage.contains('GREATER')
                              ? Colors.green
                              : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _feedbackMessage.isNotEmpty ? _feedbackMessage : ' ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _feedbackMessage.contains('GREATER')
                                ? Colors.green[800]
                                : Colors.red[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Spacer(),

                // Number buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left button
                    _buildGameButton(
                      onTap: () => _handleButtonPress(true),
                      color: Colors.green[300]!,
                      size: 80,
                      child: const Icon(
                        Icons.swap_horizontal_circle,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Middle button (Reset)
                    _buildGameButton(
                      onTap: _resetGame,
                      color: Colors.blue[200]!,
                      size: 60,
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.black,
                        size: 35,
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Right button
                    _buildGameButton(
                      onTap: () => _handleButtonPress(false),
                      color: Colors.green[300]!,
                      size: 80,
                      child: const Icon(
                        Icons.swap_horizontal_circle,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // Score display
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Score: $_score',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
