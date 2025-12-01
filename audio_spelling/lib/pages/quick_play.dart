import 'package:audio_spelling/datas/quick_play_datas.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuickPlay extends StatefulWidget {
  const QuickPlay({super.key});

  @override
  State<QuickPlay> createState() => _QuickPlayState();
}

class _QuickPlayState extends State<QuickPlay> {
  List<WordPuzzle> _currentPuzzles = [];
  int _currentPuzzleIndex = 0;
  
  // State for current puzzle
  List<String> _currentAttempt = [];
  List<String> _availableLetters = [];
  
  bool _showFeedback = false;
  bool _isLastActionCorrect = false;
  
  int _hintsUsed = 0;
  final int _maxHintsPerGame = 5;
  
  int _score = 0;
  int _totalCompleted = 0;
  
  // Progress tracking
  int _quickPlayHighScore = 0;
  int _totalGamesPlayed = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _startNewGame();
  }

  void _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _quickPlayHighScore = prefs.getInt('quickPlayHighScore') ?? 0;
      _totalGamesPlayed = prefs.getInt('totalQuickGamesPlayed') ?? 0;
    });
  }

  void _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (_score > _quickPlayHighScore) {
      await prefs.setInt('quickPlayHighScore', _score);
    }
    await prefs.setInt('totalQuickGamesPlayed', _totalGamesPlayed + 1);
  }

  void _startNewGame() {
    setState(() {
      _currentPuzzles = WordsRepository.getRandomPuzzles(5); // 5 random puzzles per game
      _currentPuzzleIndex = 0;
      _score = 0;
      _hintsUsed = 0;
      _totalCompleted = 0;
      _loadCurrentPuzzle();
    });
  }

  void _loadCurrentPuzzle() {
    if (_currentPuzzleIndex >= _currentPuzzles.length) {
      _endGame();
      return;
    }

    final currentPuzzle = _currentPuzzles[_currentPuzzleIndex];
    setState(() {
      _currentAttempt = List.filled(currentPuzzle.word.length, '');
      _availableLetters = List.from(currentPuzzle.scrambledLetters);
      _showFeedback = false;
    });
  }

  void _onLetterPlaced(String letter, int letterIndex) {
    setState(() {
      // If there was already a letter in this slot, return it to available pool
      if (_currentAttempt[letterIndex].isNotEmpty) {
        _availableLetters.add(_currentAttempt[letterIndex]);
      }

      _currentAttempt[letterIndex] = letter;
      _availableLetters.remove(letter);

      // Check if word is complete
      if (_currentAttempt.every((char) => char.isNotEmpty)) {
        _checkWord();
      } else {
        _showFeedback = false;
      }
    });
  }

  void _onLetterReturned(int letterIndex) {
    setState(() {
      final letterToReturn = _currentAttempt[letterIndex];
      if (letterToReturn.isNotEmpty) {
        _availableLetters.add(letterToReturn);
        _currentAttempt[letterIndex] = '';
        _showFeedback = false;
      }
    });
  }

  void _checkWord() {
    final currentPuzzle = _currentPuzzles[_currentPuzzleIndex];
    final attemptedWord = _currentAttempt.join();
    final isCorrect = attemptedWord == currentPuzzle.word;

    setState(() {
      _showFeedback = true;
      _isLastActionCorrect = isCorrect;

      if (isCorrect) {
        _score += 100 - (_hintsUsed * 10); // Base 100 points, minus 10 per hint
        _totalCompleted++;
        
        // Move to next puzzle after delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          setState(() {
            _currentPuzzleIndex++;
            _loadCurrentPuzzle();
          });
        });
      }
    });
  }

  void _getHint() {
    if (_hintsUsed >= _maxHintsPerGame) {
      _showMessageDialog('Hint Limit Reached', 'You have used all $_maxHintsPerGame hints for this game.');
      return;
    }

    final currentPuzzle = _currentPuzzles[_currentPuzzleIndex];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFF5E6CC),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFFD4C7B7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF8D7C6A), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentPuzzle.category,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5A2B),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  currentPuzzle.hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF8B5A2B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _hintsUsed++;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5A2B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'GOT IT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addCorrectLetter() {
    final currentPuzzle = _currentPuzzles[_currentPuzzleIndex];
    
    // Find first empty slot
    int emptyIndex = -1;
    for (int i = 0; i < _currentAttempt.length; i++) {
      if (_currentAttempt[i].isEmpty) {
        emptyIndex = i;
        break;
      }
    }
    
    if (emptyIndex == -1) return; // All slots are filled
    
    final correctLetter = currentPuzzle.word[emptyIndex];
    
    // Check if letter is available
    if (_availableLetters.contains(correctLetter)) {
      setState(() {
        _currentAttempt[emptyIndex] = correctLetter;
        _availableLetters.remove(correctLetter);
        
        // Check if word is complete
        if (_currentAttempt.every((char) => char.isNotEmpty)) {
          _checkWord();
        }
      });
    } else {
      // Letter might be already placed elsewhere, find and swap
      for (int i = 0; i < _currentAttempt.length; i++) {
        if (_currentAttempt[i] == correctLetter && i != emptyIndex) {
          // Swap letters
          setState(() {
            _currentAttempt[emptyIndex] = correctLetter;
            _currentAttempt[i] = '';
          });
          break;
        }
      }
    }
  }

  void _resetCurrentPuzzle() {
    final currentPuzzle = _currentPuzzles[_currentPuzzleIndex];
    setState(() {
      _currentAttempt = List.filled(currentPuzzle.word.length, '');
      _availableLetters = List.from(currentPuzzle.scrambledLetters);
      _showFeedback = false;
    });
  }

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

  void _endGame() {
    _saveProgress();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFF5E6CC),
          title: const Text('Game Completed!', style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Puzzles Solved: $_totalCompleted/${_currentPuzzles.length}', style: const TextStyle(color: Color(0xFF8B5A2B))),
              Text('Final Score: $_score', style: const TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
              Text('High Score: ${_score > _quickPlayHighScore ? _score : _quickPlayHighScore}', style: const TextStyle(color: Color(0xFF8B5A2B))),
              if (_score > _quickPlayHighScore)
                const Text('New High Score! 🎉', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('Exit', style: TextStyle(color: Color(0xFF8B5A2B))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGame();
              },
              child: const Text('Play Again', style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPuzzles.isEmpty || _currentPuzzleIndex >= _currentPuzzles.length) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5E6CC),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8B5A2B))),
      );
    }

    final currentPuzzle = _currentPuzzles[_currentPuzzleIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6CC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6CC),
        elevation: 0,
        title: const Text(
          'Quick Play',
          style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF8B5A2B)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Score: $_score',
                  style: const TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${_currentPuzzleIndex + 1}/${_currentPuzzles.length}',
                  style: const TextStyle(color: Color(0xFF8B5A2B), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category and progress
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    currentPuzzle.category,
                    style: const TextStyle(
                      color: Color(0xFF8B5A2B),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentPuzzleIndex + 1) / _currentPuzzles.length,
                    backgroundColor: const Color(0xFFD4C7B7),
                    color: const Color(0xFF8B5A2B),
                  ),
                ],
              ),
            ),

            // Word attempt area
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _showFeedback
                        ? (_isLastActionCorrect ? Colors.green.shade100 : Colors.red.shade100)
                        : const Color(0xFFFDF0D5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _showFeedback
                          ? (_isLastActionCorrect ? Colors.green : Colors.red)
                          : const Color(0xFFD4C7B7),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(currentPuzzle.word.length, (index) {
                      return DragTarget<String>(
                        onWillAcceptWithDetails: (data) => _currentAttempt[index].isEmpty,
                        onAcceptWithDetails: (data) {
                          _onLetterPlaced(data.data, index);
                        },
                        builder: (context, candidateData, rejectedData) {
                          return GestureDetector(
                            onTap: () => _onLetterReturned(index),
                            child: _buildAttemptLetterBox(_currentAttempt[index]),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
            ),

            // Available letters area
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0D5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD4C7B7),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0,
                runSpacing: 8.0,
                children: _availableLetters.map((char) {
                  return Draggable<String>(
                    data: char,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildLetterBox(char, isFeedback: true),
                    ),
                    childWhenDragging: _buildLetterBox(char, isDragging: true),
                    child: _buildLetterBox(char),
                  );
                }).toList(),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: 'RESET',
                    color: const Color(0xFFD4C7B7),
                    onTap: _resetCurrentPuzzle,
                  ),
                  _buildActionButton(
                    icon: Icons.lightbulb_outline,
                    label: 'HINT',
                    color: const Color(0xFFD4C7B7),
                    onTap: _getHint,
                  ),
                  _buildActionButton(
                    icon: Icons.auto_fix_high,
                    label: 'AUTO',
                    color: const Color(0xFFD4C7B7),
                    onTap: _addCorrectLetter,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterBox(String letter, {bool isFeedback = false, bool isDragging = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isFeedback
            ? const Color.fromARGB(76, 139, 89, 43)
            : (isDragging ? Colors.transparent : const Color(0xFFD4C7B7)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFeedback ? Colors.white : const Color(0xFF8D7C6A),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isFeedback ? Colors.white : const Color(0xFF8B5A2B),
        ),
      ),
    );
  }

  Widget _buildAttemptLetterBox(String letter) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: letter.isEmpty ? const Color(0xFFD4C7B7).withOpacity(0.5) : const Color(0xFFD4C7B7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF8D7C6A),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter.toUpperCase(),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B5A2B),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD4C7B7),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: const Color(0xFF8D7C6A), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF8B5A2B), size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8B5A2B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}