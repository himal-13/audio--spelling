import 'package:flutter/material.dart';
import 'dart:math';
// import 'package:shared_preferences/shared_preferences.dart'; // Uncomment for real persistence

// Define a data structure for a word in the game
class GameWord {
  final String correctWord;
  final String scrambledWord;
  final String definition; // Added definition

  GameWord(this.correctWord, this.definition) : scrambledWord = _scrambleWord(correctWord);

  // Helper to scramble a word
  static String _scrambleWord(String word) {
    List<String> chars = word.split('');
    chars.shuffle(Random());
    return chars.join();
  }
}

// Define a data structure for a game level
class GameLevel {
  final int levelNumber;
  final List<GameWord> words;

  GameLevel({required this.levelNumber, required this.words});

  // Example levels with definitions
  static List<GameLevel> get allLevels => [
        GameLevel(
          levelNumber: 1,
          words: [
            GameWord('CAT', 'A small domesticated carnivorous mammal.'),
            GameWord('DOG', 'A domesticated carnivorous mammal that typically has a long snout.'),
            GameWord('SUN', 'The star that the Earth orbits.'),
            GameWord('RUN', 'Move at a speed faster than a walk.'),
            GameWord('JUMP', 'Push oneself off a surface into the air.'),
          ],
        ),
        GameLevel(
          levelNumber: 2,
          words: [
            GameWord('APPLE', 'A round fruit with crisp flesh and a green, red, or yellow skin.'),
            GameWord('HOUSE', 'A building for human habitation.'),
            GameWord('TABLE', 'A piece of furniture with a flat top and one or more legs.'),
            GameWord('CHAIR', 'A separate seat for one person, typically with a back and four legs.'),
            GameWord('WATER', 'A colorless, transparent, odorless liquid that forms the seas, lakes, rivers, and rain.'),
          ],
        ),
        GameLevel(
          levelNumber: 3,
          words: [
            GameWord('ELEPHANT', 'A very large plant-eating mammal with a prehensile trunk.'),
            GameWord('COMPUTER', 'An electronic device for storing and processing data.'),
            GameWord('KEYBOARD', 'A panel of keys that operate a computer or typewriter.'),
            GameWord('MOUNTAIN', 'A large natural elevation of the earth\'s surface.'),
            GameWord('OCEAN', 'A very large expanse of sea.'),
          ],
        ),
        GameLevel(
          levelNumber: 4,
          words: [
            GameWord('PROGRAMMING', 'The process of writing computer programs.'),
            GameWord('DEVELOPMENT', 'The process of developing or being developed.'),
            GameWord('APPLICATION', 'A formal request to an authority for something.'),
            GameWord('INTELLIGENCE', 'The ability to acquire and apply knowledge and skills.'),
            GameWord('ENGINEERING', 'The branch of science and technology concerned with the design, building, and use of engines, machines, and structures.'),
          ],
        ),
      ];
}

class ClassicalSpellingGame extends StatefulWidget {
  const ClassicalSpellingGame({super.key});

  @override
  State<ClassicalSpellingGame> createState() => _ClassicalSpellingGameState();
}

class _ClassicalSpellingGameState extends State<ClassicalSpellingGame> {
  int? _selectedLevel;
  int _currentWordIndex = 0;
  List<String> _currentAttempt = [];
  bool _isCorrect = false;
  bool _showFeedback = false;
  int _hintsUsed = 0; // Track hints used per word
  final int _maxHints = 1; // Maximum hints allowed per word
  List<String> _availableScrambledChars = []; // Tracks available letters to drag

  // Set to store completed levels
  Set<int> _completedLevels = {};

  @override
  void initState() {
    super.initState();
    _loadProgress(); // Load saved progress when the widget initializes
  }

  // Simulates loading progress from storage (e.g., SharedPreferences)
  void _loadProgress() async {
    // For actual persistence, uncomment the following:
    // final prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   _completedLevels = (prefs.getStringList('completedLevels') ?? [])
    //       .map(int.parse)
    //       .toSet();
    // });

    setState(() {
      // For initial run, ensure at least level 1 is accessible.
      // In a real app, you'd load from SharedPreferences.
      if (_completedLevels.isEmpty) {
        _completedLevels.add(0); // Add a dummy "level 0" to unlock level 1
      }
    });
  }

  // Simulates saving progress to storage (e.g., SharedPreferences)
  void _saveProgress() async {
    // For actual persistence, uncomment the following:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setStringList(
    //     'completedLevels', _completedLevels.map((e) => e.toString()).toList());
  }

  // Function to start a level
  void _startLevel(int levelNumber) {
    setState(() {
      _selectedLevel = levelNumber;
      _currentWordIndex = 0;
      _resetAttempt();
      _hintsUsed = 0; // Reset hints when starting a new word
    });
  }

  // Resets the current attempt for a new word
  void _resetAttempt() {
    setState(() {
      final currentWord = GameLevel.allLevels[_selectedLevel! - 1].words[_currentWordIndex];
      _currentAttempt = List.filled(currentWord.correctWord.length, '');
      _availableScrambledChars = currentWord.scrambledWord.split(''); // Reset available chars
      _isCorrect = false;
      _showFeedback = false;
      _hintsUsed = 0; // Reset hints when resetting a word
    });
  }

  // Handles a letter being placed in the attempt
  void _onLetterPlaced(String letter, int index) {
    setState(() {
      // If there was already a letter in this slot, return it to the available pool
      if (_currentAttempt[index].isNotEmpty) {
        _availableScrambledChars.add(_currentAttempt[index]);
      }

      _currentAttempt[index] = letter;
      // Only remove if the letter was actually from the available pool.
      // This prevents issues if a letter is dropped onto itself.
      final int removedIndex = _availableScrambledChars.indexOf(letter);
      if (removedIndex != -1) {
        _availableScrambledChars.removeAt(removedIndex);
      }
      _checkWord();
    });
  }

  // Checks if the current attempt matches the correct word
  void _checkWord() {
    if (_currentAttempt.every((char) => char.isNotEmpty)) {
      final currentWord = GameLevel.allLevels[_selectedLevel! - 1].words[_currentWordIndex];
      final attemptedWord = _currentAttempt.join();
      setState(() {
        _isCorrect = (attemptedWord == currentWord.correctWord);
        _showFeedback = true;
      });

      if (_isCorrect) {
        Future.delayed(const Duration(seconds: 1), () {
          _moveToNextWord();
        });
      }
    }
  }

  // Moves to the next word or finishes the level
  void _moveToNextWord() {
    final currentLevelWords = GameLevel.allLevels[_selectedLevel! - 1].words;
    if (_currentWordIndex < currentLevelWords.length - 1) {
      setState(() {
        _currentWordIndex++;
        _resetAttempt();
      });
    } else {
      // Level completed
      _completedLevels.add(_selectedLevel!); // Mark current level as completed
      _saveProgress(); // Save progress
      _showCompletionDialog();
    }
  }

  // Provides a hint to the user
  void _getHint() {
    if (_hintsUsed < _maxHints) { // Limit to _maxHints hints per word
      final currentWord = GameLevel.allLevels[_selectedLevel! - 1].words[_currentWordIndex];
      final correctChars = currentWord.correctWord.split('');

      // Find an empty slot that can be filled with a correct letter
      for (int i = 0; i < correctChars.length; i++) {
        if (_currentAttempt[i].isEmpty) {
          setState(() {
            _currentAttempt[i] = correctChars[i];
            // Remove the hinted letter from available scrambled chars if it was there
            // Use removeAt or removeWhere if there are duplicate letters and you need to remove a specific instance
            final int removedIndex = _availableScrambledChars.indexOf(correctChars[i]);
            if (removedIndex != -1) {
              _availableScrambledChars.removeAt(removedIndex);
            }
            _hintsUsed++;
            _checkWord(); // Check word after hint
          });
          return; // Only provide one hint at a time
        }
      }
    } else {
      _showMessageDialog('Hint Limit Reached', 'You have used all $_maxHints hints for this word.');
    }
  }

  // Fills the boxes with the correct word
  void _solveWord() {
    setState(() {
      final currentWord = GameLevel.allLevels[_selectedLevel! - 1].words[_currentWordIndex];
      _currentAttempt = currentWord.correctWord.split('');
      _availableScrambledChars.clear(); // Clear all scrambled letters
      _isCorrect = true;
      _showFeedback = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _moveToNextWord();
    });
  }



  // Shows a generic message dialog
  void _showMessageDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Shows a dialog when the level is completed
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: const Text('Level Completed!', style: TextStyle(color: Color(0xFF5B6DF0), fontWeight: FontWeight.bold)),
          content: Text('Congratulations! You finished Level $_selectedLevel.', style: const TextStyle(color: Colors.black87)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                setState(() {
                  _selectedLevel = null; // Go back to level selection
                });
              },
              child: const Text('Back to Levels', style: TextStyle(color: Color(0xFF5B6DF0), fontWeight: FontWeight.bold)),
            ),
            if (_selectedLevel! < GameLevel.allLevels.length)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _startLevel(_selectedLevel! + 1); // Start next level
                },
                child: const Text('Next Level', style: TextStyle(color: Color(0xFFFF9F40), fontWeight: FontWeight.bold)),
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
        backgroundColor: const Color(0xFF5B6DF0),
        title: Text(
          _selectedLevel == null ? 'Select Level' : 'Level $_selectedLevel',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (_selectedLevel != null) {
              setState(() {
                _selectedLevel = null; // Go back to level selection
              });
            } else {
              Navigator.pop(context); // Go back to PlayPage
            }
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5B6DF0), Color(0xFF4AC2D6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _selectedLevel == null
              ? _buildLevelSelection()
              : _buildGamePlay(),
        ),
      ),
    );
  }

  // Builds the level selection screen
  Widget _buildLevelSelection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Choose Your Challenge',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.2, // Adjust aspect ratio for better sizing
            ),
            itemCount: GameLevel.allLevels.length,
            itemBuilder: (context, index) {
              final level = GameLevel.allLevels[index];
              // Check if the previous level is completed to unlock this level
              final bool isLocked = !_completedLevels.contains(level.levelNumber - 1);
              final bool isCompleted = _completedLevels.contains(level.levelNumber);

              return _buildLevelButton(level.levelNumber, isLocked, isCompleted);
            },
          ),
        ),
      ],
    );
  }

  // Builds a single level button
  Widget _buildLevelButton(int levelNumber, bool isLocked, bool isCompleted) {
    return InkWell(
      onTap: isLocked ? null : () => _startLevel(levelNumber), // Disable tap if locked
      child: Container(
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.grey.withOpacity(0.6)
              : (isCompleted ? Colors.green.withOpacity(0.9) : Colors.white.withOpacity(0.9)),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isLocked
                ? Colors.grey.shade700
                : (isCompleted ? Colors.green.shade700 : const Color(0xFFFF9F40)),
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLocked ? Icons.lock : (isCompleted ? Icons.check_circle : Icons.star),
              size: 48,
              color: isLocked ? Colors.white : (isCompleted ? Colors.white : const Color(0xFFFF9F40)),
            ),
            const SizedBox(height: 12),
            Text(
              'Level $levelNumber',
              style: TextStyle(
                color: isLocked ? Colors.white : (isCompleted ? Colors.white : const Color(0xFF5B6DF0)),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isCompleted)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Completed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Builds the main game play screen
  Widget _buildGamePlay() {
    // Defensive checks for _selectedLevel and _currentWordIndex
    if (_selectedLevel == null || _selectedLevel! - 1 < 0 || _selectedLevel! - 1 >= GameLevel.allLevels.length) {
      return const Center(child: Text("Error: Invalid level selected.", style: TextStyle(color: Colors.white)));
    }

    final currentLevel = GameLevel.allLevels[_selectedLevel! - 1];

    if (_currentWordIndex < 0 || _currentWordIndex >= currentLevel.words.length) {
      return const Center(child: Text("Error: Invalid word index.", style: TextStyle(color: Colors.white)));
    }

    final currentGameWord = currentLevel.words[_currentWordIndex];
    final totalWordsInLevel = currentLevel.words.length;
    final progress = (_currentWordIndex + 1) / totalWordsInLevel; // Calculate progress

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Unscramble the word:',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        const SizedBox(height: 10), // Reduced spacing
        // Level Progress Indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                color: const Color(0xFFFF9F40), // Orange accent for progress
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 8),
              Text(
                'Word ${_currentWordIndex + 1} of $totalWordsInLevel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30), // Adjusted spacing
        // Display for the word being formed by the user
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _showFeedback
                  ? (_isCorrect ? Colors.greenAccent : Colors.redAccent)
                  : Colors.white.withOpacity(0.5),
              width: 3,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate a flexible box size based on available width and number of letters
              // Ensure minimum size and prevent too large boxes
              final double availableWidth = constraints.maxWidth - (currentGameWord.correctWord.length * 8); // Account for horizontal margins
              final double idealBoxWidth = availableWidth / currentGameWord.correctWord.length;
              final double boxSize = max(35.0, min(60.0, idealBoxWidth)); // Adjusted min/max for better appearance

              return Wrap( // Changed from Row to Wrap for multi-line support
                alignment: WrapAlignment.center,
                spacing: 8.0, // Spacing between boxes
                runSpacing: 8.0, // Spacing between lines
                children: List.generate(currentGameWord.correctWord.length, (index) {
                  return DragTarget<String>(
                    onWillAcceptWithDetails: (data) => true,
                    onAcceptWithDetails: (data) {
                      _onLetterPlaced(data.data, index);
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: boxSize,
                        height: boxSize + 10, // Slightly taller for better look
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
                            fontSize: boxSize * 0.6, // Responsive font size
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
        // Display for scrambled letters (now using _availableScrambledChars)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12.0,
          runSpacing: 12.0,
          children: _availableScrambledChars.map((char) { // Use _availableScrambledChars
            return Draggable<String>(
              data: char,
              feedback: Material(
                color: Colors.transparent,
                child: _buildLetterBox(char, isFeedback: true),
              ),
              childWhenDragging: const SizedBox.shrink(), // Use SizedBox.shrink() for placeholder
              child: _buildLetterBox(char),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
        if (_showFeedback)
          Text(
            _isCorrect ? 'Correct!' : 'Try Again!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _isCorrect ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.refresh,
              label: 'Reset',
              color: Colors.redAccent,
              onTap: _resetAttempt,
            ),
            _buildActionButton(
              icon: Icons.lightbulb_outline,
              label: 'Hint (${_maxHints - _hintsUsed})', // Show remaining hints
              color: (_maxHints - _hintsUsed) > 0 ? Colors.yellow.shade700 : Colors.grey, // Grey out if no hints left
              onTap: (_maxHints - _hintsUsed) > 0 ? _getHint : null, // Disable if no hints left
            ),
            _buildActionButton(
              icon: Icons.check_circle_outline,
              label: 'Solve',
              color: Colors.blueAccent,
              onTap: _solveWord,
            ),
            // _buildActionButton(
            //   icon: Icons.skip_next,
            //   label: 'Skip',
            //   color: Colors.purpleAccent,
            //   onTap: (){
            //    final currentWord = GameLevel.allLevels[_selectedLevel! - 1].words[_currentWordIndex];
                  // _showMessageDialog('Definition of "${currentWord.correctWord}"', currentWord.definition);
                  // Future.delayed(const Duration(seconds: 2), () { // Give time to read definition
                  //   _moveToNextWord();
                  // });},
            // ),
          ],
        ),
      ],
    );
  }

  // Helper to build a letter box for draggable letters
  Widget _buildLetterBox(String letter, {bool isFeedback = false, bool isDragging = false}) {
    return Container(
      width: isFeedback ? 50 : 60,
      height: isFeedback ? 60 : 70,
      decoration: BoxDecoration(
        color: isFeedback
            ? Colors.orangeAccent.withOpacity(0.8)
            : (isDragging ? Colors.transparent : Colors.white.withOpacity(0.9)),
        borderRadius: BorderRadius.circular(15),
        boxShadow: isFeedback || isDragging
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

  // Helper to build action buttons (Reset, Hint, Solve, Skip)
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap, // Made onTap nullable
  }) {
    return InkWell(
      onTap: onTap, // Use the provided onTap callback (can be null)
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Adjusted padding for more buttons
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
                fontSize: 16, // Adjusted font size for more buttons
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
