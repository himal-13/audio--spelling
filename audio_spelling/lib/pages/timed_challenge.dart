import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// Reusing GameWord structure from ClassicalSpellingGame
class GameWord {
  final String correctWord;
  final String scrambledWord;
  final String hintText; // Added hint text/definition

  GameWord(this.correctWord, this.hintText) : scrambledWord = _scrambleWord(correctWord);

  static String _scrambleWord(String word) {
    List<String> chars = word.split('');
    chars.shuffle(Random());
    return chars.join();
  }
}

class TimedSpellingChallenge extends StatefulWidget {
  const TimedSpellingChallenge({super.key});

  @override
  State<TimedSpellingChallenge> createState() => _TimedSpellingChallengeState();
}

class _TimedSpellingChallengeState extends State<TimedSpellingChallenge> {
  static const int _gameDurationSeconds = 60; // Total game time
  late Timer _timer;
  int _secondsRemaining = _gameDurationSeconds;
  int _score = 0;
  bool _isGameOver = false;

  // Word pool structured for difficulty progression - EXPANDED
  List<GameWord> _easyWords = [
    GameWord('CAT', 'A common house pet.'),
    GameWord('DOG', 'Man\'s best friend.'),
    GameWord('SUN', 'Shines brightly in the sky.'),
    GameWord('RUN', 'Move quickly on foot.'),
    GameWord('JUMP', 'Propel oneself into the air.'),
    GameWord('FISH', 'Swims in water.'),
    GameWord('BIRD', 'Flies in the sky.'),
    GameWord('TREE', 'Tall plant with a trunk and branches.'),
    GameWord('BOOK', 'A set of written or printed pages.'),
    GameWord('PEN', 'An instrument for writing or drawing with ink.'),
    GameWord('CAR', 'A road vehicle, typically with four wheels.'),
    GameWord('HAT', 'A covering for the head.'),
    GameWord('BALL', 'A round object used in games.'),
    GameWord('CUP', 'A small bowl-shaped container for drinking.'),
    GameWord('BOX', 'A container with a flat base and sides.'),
    GameWord('FAN', 'An apparatus with rotating blades that creates a current of air.'),
    GameWord('BED', 'A piece of furniture for sleeping.'),
    GameWord('LEG', 'Each of the limbs on which a person or animal walks.'),
    GameWord('ARM', 'Each of the two upper limbs of the human body.'),
    GameWord('EYE', 'The organ of sight.'),
  ];

  List<GameWord> _mediumWords = [
    GameWord('APPLE', 'A common red or green fruit.'),
    GameWord('HOUSE', 'A building where people live.'),
    GameWord('WATER', 'A clear, odorless liquid.'),
    GameWord('HAPPY', 'Feeling or showing pleasure.'),
    GameWord('SMILE', 'A facial expression of pleasure.'),
    GameWord('CLOUD', 'A visible mass of water droplets in the sky.'),
    GameWord('FLOWER', 'The reproductive part of a plant.'),
    GameWord('TABLE', 'Furniture with a flat top and legs.'),
    GameWord('CHAIR', 'A seat for one person.'),
    GameWord('GRAPE', 'A berry, typically green, purple, red, or black.'),
    GameWord('LEMON', 'A yellow, oval citrus fruit.'),
    GameWord('BANANA', 'A long, curved fruit which grows in clusters.'),
    GameWord('ORANGE', 'A round juicy citrus fruit with a tough, bright reddish-yellow rind.'),
    GameWord('PENCIL', 'An instrument for writing or drawing.'),
    GameWord('WINDOW', 'An opening in the wall of a building.'),
    GameWord('DOOR', 'A movable barrier at the entrance to a building.'),
    GameWord('STREET', 'A public road in a city or town.'),
    GameWord('BRIDGE', 'A structure carrying a road, path, railroad, or canal across a river.'),
    GameWord('RIVER', 'A large natural stream of water.'),
    GameWord('OCEAN', 'A very large expanse of sea.'),
  ];

  List<GameWord> _hardWords = [
    GameWord('ELEPHANT', 'Largest land animal.'),
    GameWord('COMPUTER', 'Electronic device for processing data.'),
    GameWord('KEYBOARD', 'Used for typing on a computer.'),
    GameWord('MOUNTAIN', 'A large natural elevation of the earth\'s surface.'),
    GameWord('PROGRAMMING', 'Writing code for computers.'),
    GameWord('DEVELOPER', 'One who creates software.'),
    GameWord('APPLICATION', 'A software program.'),
    GameWord('INTELLIGENCE', 'Ability to acquire and apply knowledge.'),
    GameWord('ENGINEERING', 'Designing and building structures or machines.'),
    GameWord('UNIVERSITY', 'An institution of higher education.'),
    GameWord('HOSPITAL', 'An institution providing medical and surgical treatment.'),
    GameWord('RESTAURANT', 'A place where people pay to sit and eat meals.'),
    GameWord('TELEPHONE', 'A system for transmitting voices over a distance.'),
    GameWord('TELEVISION', 'An electronic device with a screen for viewing pictures.'),
    GameWord('CHOCOLATE', 'A food made from roasted and ground cacao seeds.'),
    GameWord('STRAWBERRY', 'A sweet soft red fruit with a seed-studded surface.'),
    GameWord('ADVENTURE', 'An unusual and exciting or daring experience.'),
    GameWord('EXPLORER', 'A person who explores an unfamiliar area.'),
    GameWord('MYSTERY', 'Something that is difficult or impossible to understand or explain.'),
    GameWord('CHALLENGE', 'A call to take part in a contest or competition.'),
  ];

  late GameWord _currentWord;
  List<String> _currentAttempt = [];
  List<String> _availableScrambledChars = []; // Tracks available letters to drag
  String? _currentHintText; // Stores the hint text to display

  // New: History of recently used words to prevent immediate duplication
  final List<GameWord> _recentWordsHistory = [];
  static const int _maxHistorySize = 5; // Keep track of the last 5 words

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _secondsRemaining = _gameDurationSeconds;
      _score = 0;
      _isGameOver = false;
      _currentHintText = null; // Clear hint at start of new game
      _recentWordsHistory.clear(); // Clear history for a new game
      _nextWord(); // Start with the first word
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        _gameOver();
      }
    });
  }

  void _nextWord() {
    setState(() {
      List<GameWord> poolToDrawFrom;
      if (_score < 50) {
        poolToDrawFrom = _easyWords;
      } else if (_score < 150) {
        poolToDrawFrom = _mediumWords;
      } else {
        poolToDrawFrom = _hardWords;
      }

      GameWord newWord;
      final random = Random();
      int attempts = 0;
      do {
        newWord = poolToDrawFrom[random.nextInt(poolToDrawFrom.length)];
        attempts++;
        if (attempts > 50 && poolToDrawFrom.length <= _maxHistorySize) {
          // Fallback: If pool is too small and we can't find a non-duplicate,
          // just pick any word to prevent infinite loop.
          break;
        }
      } while (_recentWordsHistory.contains(newWord)); // Ensure no immediate duplicates

      _currentWord = newWord;
      _currentAttempt = List.filled(_currentWord.correctWord.length, '');
      _availableScrambledChars = _currentWord.scrambledWord.split('');
      _currentHintText = null; // Clear hint for new word

      // Update recent words history
      _recentWordsHistory.add(_currentWord);
      if (_recentWordsHistory.length > _maxHistorySize) {
        _recentWordsHistory.removeAt(0); // Remove the oldest word
      }
    });
  }

  void _resetCurrentWord() {
    setState(() {
      _currentAttempt = List.filled(_currentWord.correctWord.length, '');
      _availableScrambledChars = _currentWord.scrambledWord.split('');
      _currentHintText = null; // Clear hint when resetting word
    });
  }

  void _onLetterPlaced(String letter, int index) {
    setState(() {
      // If there was already a letter in this slot, return it to the available pool
      if (_currentAttempt[index].isNotEmpty) {
        _availableScrambledChars.add(_currentAttempt[index]);
      }

      _currentAttempt[index] = letter;
      final int removedIndex = _availableScrambledChars.indexOf(letter);
      if (removedIndex != -1) {
        _availableScrambledChars.removeAt(removedIndex);
      }
      _checkWord();
    });
  }

  void _checkWord() {
    if (_currentAttempt.every((char) => char.isNotEmpty)) {
      final attemptedWord = _currentAttempt.join();
      if (attemptedWord == _currentWord.correctWord) {
        setState(() {
          _score += 10; // Award points for correct word
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          _nextWord(); // Move to next word quickly
        });
      } else {
        // Optional: Penalize for incorrect word or just move on
        Future.delayed(const Duration(milliseconds: 500), () {
          _nextWord(); // Move to next word after a short delay for incorrect attempts
        });
      }
    }
  }

  void _showHint() {
    setState(() {
      _currentHintText = _currentWord.hintText;
    });
  }

  void _gameOver() {
    setState(() {
      _isGameOver = true;
    });
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: const Text('Game Over!', style: TextStyle(color: Color(0xFF5B6DF0), fontWeight: FontWeight.bold)),
          content: Text('Time\'s up! Your final score is: $_score', style: const TextStyle(color: Colors.black87)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _startGame(); // Restart game
              },
              child: const Text('Play Again', style: TextStyle(color: Color(0xFF5B6DF0), fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to PlayPage
              },
              child: const Text('Back to Menu', style: TextStyle(color: Color(0xFFFF9F40), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 19, 184, 0), // Matching Timed Challenge button color
        title: const Text('Timed Challenge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 19, 184, 0), Color(0xFF5B6DF0)], // Adjusted gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isGameOver
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_off, size: 80, color: Colors.white),
                      const SizedBox(height: 20),
                      const Text(
                        'Time Over!',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Final Score: $_score',
                        style: const TextStyle(fontSize: 28, color: Colors.white),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9F40),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Play Again',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Go back to PlayPage
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Back to Menu',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoBox(Icons.timer, 'Time: $_secondsRemaining s', Colors.orangeAccent),
                          _buildInfoBox(Icons.score, 'Score: $_score', Colors.blueAccent),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Unscramble the word:',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Display for the word being formed by the user
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 3,
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double availableWidth = constraints.maxWidth - (_currentWord.correctWord.length * 8);
                          final double idealBoxWidth = availableWidth / _currentWord.correctWord.length;
                          final double boxSize = max(35.0, min(60.0, idealBoxWidth));

                          return Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: List.generate(_currentWord.correctWord.length, (index) {
                              return DragTarget<String>(
                                onWillAcceptWithDetails: (data) => true,
                                onAcceptWithDetails: (data) {
                                  _onLetterPlaced(data.data, index);
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return Container(
                                    width: boxSize,
                                    height: boxSize + 10,
                                    decoration: BoxDecoration(
                                      color: _currentAttempt[index].isNotEmpty
                                          ? Colors.white.withOpacity(0.9)
                                          : Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.7),
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _currentAttempt[index],
                                      style: TextStyle(
                                        fontSize: boxSize * 0.6,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF5B6DF0),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Display for scrambled letters
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: _availableScrambledChars.map((char) {
                        return Draggable<String>(
                          data: char,
                          feedback: Material(
                            color: Colors.transparent,
                            child: _buildLetterBox(char, isFeedback: true),
                          ),
                          childWhenDragging: const SizedBox.shrink(),
                          child: _buildLetterBox(char),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    // Reset and Hint Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.refresh,
                          label: 'Reset',
                          color: Colors.redAccent,
                          onTap: _resetCurrentWord, // Call the new reset method
                        ),
                        _buildActionButton(
                          icon: Icons.lightbulb_outline,
                          label: 'Hint',
                          color: Colors.yellow.shade700,
                          onTap: _showHint,
                        ),
                      ],
                    ),
                    if (_currentHintText != null) // Conditionally show hint text
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Hint: $_currentHintText',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  // Helper to build info boxes (Time, Score)
  Widget _buildInfoBox(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build a letter box for draggable letters
  Widget _buildLetterBox(String letter, {bool isFeedback = false}) {
    return Container(
      width: isFeedback ? 50 : 60,
      height: isFeedback ? 60 : 70,
      decoration: BoxDecoration(
        color: isFeedback
            ? Colors.orangeAccent.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: isFeedback
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
        border: Border.all(
          color: isFeedback ? Colors.white : const Color(0xFFFF9F40),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: isFeedback ? 30 : 36,
          fontWeight: FontWeight.bold,
          color: isFeedback ? Colors.white : const Color(0xFF5B6DF0),
        ),
      ),
    );
  }

  // Helper to build action buttons (Reset, Hint)
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
