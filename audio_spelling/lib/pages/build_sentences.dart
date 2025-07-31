import 'package:flutter/material.dart';
import 'dart:math'; // For shuffling words
import 'package:shared_preferences/shared_preferences.dart'; // For saving level progress

// --- Word and SentenceLevel Models (Copied for self-containment) ---
class Word {
  final String text;
  final String id; // Unique ID for each word instance

  Word({required this.text, required this.id});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Word && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class SentenceLevel {
  final int levelNumber;
  final String correctSentence;
  final List<Word> correctWords;
  final List<Word> shuffledWords;

  SentenceLevel({
    required this.levelNumber,
    required this.correctSentence,
    required this.correctWords,
    required this.shuffledWords,
  });
}

// Helper function to create a SentenceLevel from a string
SentenceLevel _createSentenceLevel(int levelNumber, String sentence) {
  final correctWords = sentence.split(' ').map((text) => Word(text: text, id: UniqueKey().toString())).toList();
  final shuffledWords = List<Word>.from(correctWords)..shuffle(Random());
  return SentenceLevel(
    levelNumber: levelNumber,
    correctSentence: sentence,
    correctWords: correctWords,
    shuffledWords: shuffledWords,
  );
}
// --- End of Models ---

class BuildSentencesPage extends StatefulWidget {
  const BuildSentencesPage({super.key});

  @override
  State<BuildSentencesPage> createState() => _BuildSentencesPageState();
}

class _BuildSentencesPageState extends State<BuildSentencesPage> {
  // List of sentences for different levels, starting easy and increasing difficulty
  final List<String> _rawSentences = [
    // 3-word sentences (easy)
    "I like apples.",
    "She runs fast.",
    "They play games.",
    "He reads books.",
    "We eat food.",
    // 4-word sentences
    "The dog barks loudly.",
    "Birds sing in trees.",
    "Cats love to sleep.",
    "Fish swim in water.",
    "The sun shines bright.",
    // 5-word sentences
    "My friend lives in a big city.",
    "The children are playing outside now.",
    "She bought a new red car.",
    "He always helps his little sister.",
    "We went to the beach yesterday.",
    // 6-word sentences
    "The teacher gave us a lot of homework.",
    "My favorite color is bright blue.",
    "They decided to travel around the world.",
    "The small bird built a cozy nest.",
    "Please close the door quietly behind you.",
    // Longer/more complex sentences
    "The old house stood on top of the hill.",
    "Learning a new language takes time and effort.",
    "The beautiful flowers bloomed in the spring garden.",
    "She carefully packed her suitcase for the long trip.",
    "The curious cat chased the butterfly across the lawn.",
    "Despite the heavy rain, the concert continued as planned.",
    "The ancient ruins attracted many tourists from all over.",
    "He quickly finished his work and went home early.",
    "The gentle breeze rustled the leaves of the tall trees.",
    "The chef prepared a delicious meal for all the guests.",
  ];

  late SentenceLevel _currentLevel;
  late List<Word> _availableWords; // Words shown at the top for selection
  List<Word?> _selectedWords = []; // Words placed in the answer slots (can be null for empty slots)
  bool _isCheckingAnswer = false; // To prevent multiple checks during answer submission
  bool _isLevelComplete = false;
  int _currentLevelIndex = 0; // Tracks the current level index (0-based)
  int _maxUnlockedLevelIndex = 0; // Tracks the highest level ever completed (0-based)
  bool _isLoading = true; // Loading state for initial data fetch
  int hintCount = 2; // Counter for hints used

  late final List<SentenceLevel> _allLevels; // Declare as late final

  OverlayEntry? _overlayEntry; // To manage the custom overlay message

  @override
  void initState() {
    super.initState();
    // Initialize _allLevels using the helper function
    _allLevels = _rawSentences.asMap().entries.map((entry) {
      return _createSentenceLevel(entry.key + 1, entry.value);
    }).toList();
    _loadProgress(); // Load both current and unlocked levels
  }

  @override
  void dispose() {
    _overlayEntry?.remove(); // Ensure overlay is removed when page is disposed
    super.dispose();
  }

  // Load both current level index and max unlocked level index from SharedPreferences
  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLevelIndex = prefs.getInt('currentLevelIndex_sentences') ?? 0;
      _maxUnlockedLevelIndex = prefs.getInt('maxUnlockedLevelIndex_sentences') ?? 0;

      // Ensure loaded indices are within bounds
      if (_currentLevelIndex >= _allLevels.length) {
        _currentLevelIndex = 0;
      }
      if (_maxUnlockedLevelIndex >= _allLevels.length) {
        _maxUnlockedLevelIndex = _allLevels.length - 1; // Cap at max level
      }
      if (_currentLevelIndex > _maxUnlockedLevelIndex) {
        _currentLevelIndex = _maxUnlockedLevelIndex; // Cannot be ahead of unlocked
      }

      _loadLevel(); // Load the level based on the retrieved index
      _isLoading = false; // End loading
    });
  }

  // Save both current level index and max unlocked level index to SharedPreferences
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentLevelIndex_sentences', _currentLevelIndex);
    await prefs.setInt('maxUnlockedLevelIndex_sentences', _maxUnlockedLevelIndex);
  }

  void _loadLevel() {
    setState(() {
      _currentLevel = _allLevels[_currentLevelIndex];
      // Create a deep copy of shuffled words to avoid modifying the original level data
      _availableWords = List.from(_currentLevel.shuffledWords.map((word) => Word(text: word.text, id: word.id)));
      _selectedWords = List.filled(_currentLevel.correctWords.length, null); // Initialize with nulls for empty slots
      _isLevelComplete = false;
      _isCheckingAnswer = false; // Reset checking flag for new level
      hintCount = 2; // Reset hint count for new level
    });
  }

  void _onWordTapped(Word tappedWord) {
    if (_isLevelComplete) return;

    setState(() {
      int emptySlotIndex = _selectedWords.indexOf(null);
      if (emptySlotIndex != -1) {
        _selectedWords[emptySlotIndex] = tappedWord;
        _availableWords.removeWhere((word) => word.id == tappedWord.id);
      }

      // Automatically check answer if all slots are filled
      if (!_selectedWords.contains(null) && !_isCheckingAnswer) {
        _isCheckingAnswer = true;
        _checkAnswer();
      }
    });
  }

  void _onSelectedWordTapped(int index) {
    if (_isLevelComplete) return;

    setState(() {
      Word? wordToMoveBack = _selectedWords[index];
      if (wordToMoveBack != null) {
        _availableWords.add(wordToMoveBack);
        _availableWords.sort((a, b) => a.text.compareTo(b.text)); // Sort for consistent display
        _selectedWords[index] = null;
        _isLevelComplete = false; // Allow re-interaction if user moves a word back
      }
    });
  }

  void _checkAnswer() {
    final userSentence = _selectedWords.map((word) => word?.text ?? '').join(' ');
    final correctSentence = _currentLevel.correctSentence;

    if (userSentence == correctSentence) {
      setState(() {
        _isLevelComplete = true;
        // Update max unlocked level if current level is higher
        if (_currentLevelIndex >= _maxUnlockedLevelIndex) {
          _maxUnlockedLevelIndex = _currentLevelIndex + 1;
        }
      });
      _showLevelCompleteMessage(true); // Show success message
    } else {
      _showLevelCompleteMessage(false); // Only show incorrect message
    }
    _isCheckingAnswer = false;
  }

  // This method is used for both correct and incorrect messages
  void _showLevelCompleteMessage(bool isSuccess) {
    // Ensure any previous overlay is removed
    _overlayEntry?.remove();
    _overlayEntry = null;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    isSuccess ? 'Level Complete!' : 'Oh no!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isSuccess
                        ? ''
                        : 'Your sentence was incorrect.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                      if (isSuccess) {
                        _currentLevelIndex++;
                        _saveProgress(); // Save both current and unlocked progress

                        if (_currentLevelIndex < _allLevels.length) {
                          _loadLevel(); // Load next level
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Congratulations! You completed all levels!')),
                          );
                          setState(() {
                            _currentLevelIndex = 0; // Reset for replay
                            _maxUnlockedLevelIndex = _allLevels.length - 1; // Keep all levels unlocked
                          });
                          _saveProgress(); // Save reset state
                          _loadLevel();
                        }
                      } else {
                        _resetGame(); // Allow user to try again
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      isSuccess
                          ? (_currentLevelIndex < _allLevels.length ? 'Next Level' : 'Restart Game')
                          : 'Try Again',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _resetGame() {
    setState(() {
      _loadLevel(); // Simply reload the current level
    });
  }

  void _showHint() {
    if (_isLevelComplete) return; // No hint needed if level is complete
    if (hintCount <= 0) {
      return;
    }
    
    // Find the first incorrect word in _selectedWords
    int firstIncorrectIndex = -1;
    for (int i = 0; i < _currentLevel.correctWords.length; i++) {
      if (_selectedWords[i]?.text != _currentLevel.correctWords[i].text) {
        firstIncorrectIndex = i;
        break;
      }
    }

    if (firstIncorrectIndex != -1) {
      // If there's an incorrect word, clear the slot and put the correct one
      Word? wordToReturn = _selectedWords[firstIncorrectIndex];
      if (wordToReturn != null) {
        _availableWords.add(wordToReturn);
        _availableWords.sort((a, b) => a.text.compareTo(b.text));
      }

      final correctWordForSlot = _currentLevel.correctWords[firstIncorrectIndex];
      // Find this correct word in the available words pool
      final wordToPlace = _availableWords.firstWhere(
        (word) => word.text == correctWordForSlot.text,
        orElse: () => correctWordForSlot, // Fallback if somehow not in available (shouldn't happen)
      );

      setState(() {
        _selectedWords[firstIncorrectIndex] = wordToPlace;
        _availableWords.removeWhere((word) => word.id == wordToPlace.id);
        hintCount--;
      });

      // If all slots are now filled after hint, check answer
      if (!_selectedWords.contains(null) && !_isCheckingAnswer) {
        _isCheckingAnswer = true;
        _checkAnswer();
      }

    } else {
      // If all words are currently correct, but not yet checked or level not complete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All placed words are correct so far!'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5F7C8A), // Dark grey background from UI
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Match PlayPage AppBar color
       
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white), // New Levels button
            onPressed: () {
              _showLevelsBottomSheet(context);
            },
          ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white, // Or your accent color
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LEVEL Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A6572), // Slightly darker grey for level box
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'LEVEL ${_currentLevel.levelNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Answer Slots (where selected words go)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A6572), // Match level box background
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        alignment: WrapAlignment.center,
                        children: List.generate(_currentLevel.correctWords.length, (index) {
                          final word = _selectedWords[index];
                          return GestureDetector(
                            onTap: () => _onSelectedWordTapped(index),
                            child: WordBlock(
                              word: word?.text ?? '', // Display word or empty string
                              color: word != null ? const Color(0xFFD4C7B7) : const Color(0xFF8D9CA3), // Beige if filled, darker grey if empty
                              textColor: word != null ? Colors.black87 : Colors.white54,
                              isSelected: word != null, // True if a word is placed here
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Jumbled Words (Selectable)
                    Expanded(
                      child: Center(
                        child: Wrap(
                          spacing: 10.0, // Horizontal space between words
                          runSpacing: 10.0, // Vertical space between lines
                          alignment: WrapAlignment.center,
                          children: _availableWords.map((word) {
                            return GestureDetector(
                              onTap: () => _onWordTapped(word),
                              child: WordBlock(
                                word: word.text,
                                color: const Color(0xFFD4C7B7), // Light beige from UI
                                textColor: Colors.black87,
                                isSelected: false, // Always false here as they are available
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton('RESET', _resetGame),
                        _buildActionButton('HINT ($hintCount)', _showHint), // Display hint count
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A6572), // Button background color
        foregroundColor: Colors.white, // Text color
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        shadowColor: const Color.fromARGB(134, 0, 0, 0),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // New method to show the levels bottom sheet
  void _showLevelsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Select Level',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const Divider(height: 30, thickness: 1),
              Expanded( // Use Expanded to allow GridView to take available space
                child: GridView.builder(
                  shrinkWrap: true, // Use shrinkWrap when inside Column
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4 levels per row
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1, // Make tiles square
                  ),
                  itemCount: _allLevels.length,
                  itemBuilder: (context, index) {
                    final int levelNumber = index + 1;
                    // Check if the level is unlocked (completed or current)
                    final bool isUnlocked = levelNumber <= (_maxUnlockedLevelIndex + 1);
                    final bool isCurrent = levelNumber == (_currentLevelIndex + 1);

                    return GestureDetector(
                      onTap: isUnlocked
                          ? () {
                              Navigator.pop(context); // Close bottom sheet
                              if (!isCurrent) { // Only load if not the current level
                                setState(() {
                                  _currentLevelIndex = index;
                                });
                                _saveProgress(); // Save the new current level
                                _loadLevel();
                              }
                              // Removed _showCorrectSentenceDialog call here
                            }
                          : null, // Disable tap for locked levels
                      child: _buildLevelTile(levelNumber, isUnlocked, isCurrent),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Helper widget to build individual level tiles
  Widget _buildLevelTile(int levelNumber, bool isUnlocked, bool isCurrent) {
    Color backgroundColor = Colors.grey.shade200;
    Color textColor = Colors.grey.shade600;
    IconData icon = Icons.lock;

    if (isUnlocked) {
      backgroundColor = isCurrent ? Colors.blue.shade100 : Colors.green.shade100;
      textColor = isCurrent ? Colors.blue.shade900 : Colors.green.shade900;
      icon = Icons.check_circle_outline; // Or a star/trophy for completed
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: isCurrent ? Border.all(color: Colors.blue, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isUnlocked)
            Icon(icon, size: 30, color: textColor)
          else
            Text(
              '$levelNumber',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          if (isUnlocked && !isCurrent && levelNumber <= _maxUnlockedLevelIndex) // Show checkmark for truly completed levels
            Icon(Icons.check, color: Colors.green.shade700, size: 20),
          if (isCurrent)
            Text(
              'Current',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
        ],
      ),
    );
  }

  // Removed _showCorrectSentenceDialog method as requested
}
class WordBlock extends StatelessWidget {
  final String word;
  final Color color;
  final Color textColor;
  final bool isSelected; // To indicate if it's currently selected/placed

  const WordBlock({
    super.key,
    required this.word,
    required this.color,
    this.textColor = Colors.black,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(73, 0, 0, 0),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Text(
        word.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
