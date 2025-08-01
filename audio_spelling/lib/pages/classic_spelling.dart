import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

// Define a data structure for a word in the game
class GameWord {
  final String correctWord;
  final String scrambledWord; // Scrambled version of this specific word
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
  final List<String> commonLetterPool; // New: Pool of letters for all words in this level

  GameLevel({required this.levelNumber, required this.words, required this.commonLetterPool});

  // Example levels with definitions and common letter pools
  static List<GameLevel> get allLevels {
    // Helper to create a common letter pool from a list of words
    List<String> _createCommonPool(List<GameWord> words) {
      String allChars = '';
      for (var word in words) {
        allChars += word.correctWord;
      }
      List<String> chars = allChars.split('');
      chars.shuffle(Random());
      return chars;
    }

    return [
    // game_data.dart
    GameLevel(
      levelNumber: 1,
      words: [
        GameWord('AT', 'Used to indicate a place or position.'),
        GameWord('CAT', 'Domestic carnivorous animal.'),
      ],
      commonLetterPool: _createCommonPool([
        GameWord('AT', ''),
        GameWord('CAT', ''),
      ]),
    ),
    
    // --- Level 2: 2 two-letter words, 1 three-letter word.
    // The letters from 'GO', 'HI', 'BED' cannot form any other valid words.
    GameLevel(
      levelNumber: 2,
      words: [
        GameWord('GO', 'Move from one place to another.'),
        GameWord('HI', 'A greeting.'),
        GameWord('BED', 'A piece of furniture for sleeping on.'),
      ],
      commonLetterPool: _createCommonPool([
        GameWord('GO', ''), GameWord('HI', ''),
        GameWord('BED', ''),
      ]),
    ),

    // --- Level 3: 1 two-letter word, 2 three-letter words.
    // The letters from 'IT', 'RUN', 'SUN' only form the intended words.
    GameLevel(
      levelNumber: 3,
      words: [
        GameWord('IT', 'Used to refer to a thing previously mentioned.'),
        GameWord('RUN', 'Move at a speed faster than walking.'),
        GameWord('SUN', 'The star around which the earth orbits.'),
      ],
      commonLetterPool: _createCommonPool([
        GameWord('IT', ''), GameWord('RUN', ''),
        GameWord('SUN', ''),
      ]),
    ),

    // --- Level 4: 1 three-letter word, 1 four-letter word.
    // The letters from 'PET' and 'DREAM' are distinct enough to prevent other words.
    GameLevel(
      levelNumber: 4,
      words: [
        GameWord('PET', 'A domestic animal kept for companionship.'),
        GameWord('DREAM', 'A series of thoughts, images, and sensations occurring during sleep.'),
      ],
      commonLetterPool: _createCommonPool([
        GameWord('PET', ''), GameWord('DREAM', ''),
      ]),
    ),

    // --- Level 5: 2 three-letter words, 2 four-letter words.
    // The letters from 'MAP', 'LOG', 'WIND', 'GOLD' only form the given words.
    GameLevel(
      levelNumber: 5,
      words: [
        GameWord('MAP', 'A diagrammatic representation of an area.'),
        GameWord('LOG', 'A part of the trunk or a large branch of a tree.'),
        GameWord('WIND', 'The perceptible natural movement of air.'),
        GameWord('GOLD', 'A precious yellow metal.'),
      ],
      commonLetterPool: _createCommonPool([
        GameWord('MAP', ''), GameWord('LOG', ''),
        GameWord('WIND', ''), GameWord('GOLD', ''),
      ]),
    ),

    // --- Level 6: 2 four-letter words, 2 five-letter words.
    // The letters from 'SINK', 'LOUD', 'GRAIN', 'OCEAN' don't create other words.
    GameLevel(
      levelNumber: 6,
      words: [
        GameWord('SINK', 'Go down below the surface of something.'),
        GameWord('LOUD', 'Producing or capable of producing much noise.'),
        GameWord('GRAIN', 'A small, hard seed, especially of a cereal plant.'),
        GameWord('OCEAN', 'A very large expanse of sea.'),
      ],
      commonLetterPool: _createCommonPool([
        GameWord('SINK', ''), GameWord('LOUD', ''),
        GameWord('GRAIN', ''), GameWord('OCEAN', ''),
      ]),
    ),

    // --- Level 7: 1 five-letter word, 1 six-letter word.
    // The words 'SHINE' and 'GLOWED' use distinct letters to prevent other combinations.
    GameLevel(
      levelNumber: 7,
      words: [
        GameWord('SHINE', 'To emit or reflect light; be bright.'),
        GameWord('GLOWED', 'Emitted a steady light without flame.'),
      ],
      commonLetterPool: _createCommonPool([
        GameWord('SHINE', ''), GameWord('GLOWED', ''),
      ]),
    ),

    // --- Level 8: 1 six-letter word, 1 seven-letter word.
    // The letters from 'MOMENT' and 'JOURNEY' work together without creating other words.
    GameLevel(
      levelNumber: 8,
      words: [
        GameWord('MOMENT', 'A very brief period of time.'),
        GameWord('JOURNEY', 'An act of traveling from one place to another.'),
      ],
      commonLetterPool: _createCommonPool([
        GameWord('MOMENT', ''), GameWord('JOURNEY', ''),
      ]),
    ),

    // --- Level 9: 1 seven-letter word, 1 eight-letter word.
    // The letters from 'CAPTURE' and 'MYSTERY' are chosen to avoid other words.
    GameLevel(
      levelNumber: 9,
      words: [
        GameWord('CAPTURE', 'Take into one\'s possession or control by force.'),
        GameWord('MYSTERY', 'Something that is difficult or impossible to understand or explain.'),
      ],
      commonLetterPool: _createCommonPool([
        GameWord('CAPTURE', ''), GameWord('MYSTERY', ''),
      ]),
    ),

    // --- Level 10: 1 seven-letter word, 1 nine-letter word.
    // The words 'EXPLORE' and 'COMMUNITY' work well together.
    GameLevel(
      levelNumber: 10,
      words: [
        GameWord('EXPLORE', 'Travel in or through an unfamiliar country or area.'),
        GameWord('COMMUNITY', 'A group of people living in the same place.'),
      ],
      commonLetterPool: _createCommonPool([
        GameWord('EXPLORE', ''), GameWord('COMMUNITY', ''),
      ]),
    ),
  ];
}
    
  }

class ClassicalSpellingGame extends StatefulWidget {
  const ClassicalSpellingGame({super.key});

  @override
  State<ClassicalSpellingGame> createState() => _ClassicalSpellingGameState();
}

class _ClassicalSpellingGameState extends State<ClassicalSpellingGame> {
  int? _selectedLevel;
  // State for multiple words in a level
  List<List<String>> _currentAttempts = []; // List of attempts for each word
  List<GameWord?> _matchedWords = []; // Tracks which GameWord has been matched by each _currentAttempts row
  Set<String> _completedCorrectWordsSet = {}; // Stores the *correct word strings* that have been successfully formed

  List<String> _availableScrambledChars = []; // Common pool of letters for the level

  bool _showFeedback = false; // General feedback for last action
  bool _isLastActionCorrect = false; // Whether the last check was correct

  int _hintsUsedOverall = 0; // Track total hints used per level
  final int _maxHintsPerLevel = 3; // Maximum hints allowed per level

  // Set to store completed levels (using levelNumber, not index)
  Set<int> _completedLevels = {};
  int _maxUnlockedLevel = 1; // Tracks the highest level number unlocked

  @override
  void initState() {
    super.initState();
    _loadProgress(); // Load saved progress when the widget initializes
  }

  // Loads progress from SharedPreferences
  void _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Retrieve the list of completed levels, default to empty list if not found
      _completedLevels = (prefs.getStringList('classicalCompletedLevels') ?? [])
          .map(int.parse) // Convert string back to int
          .toSet(); // Convert list to set

      // Determine the max unlocked level
      if (_completedLevels.isEmpty) {
        _maxUnlockedLevel = 1; // Start with Level 1 unlocked
      } else {
        _maxUnlockedLevel = (_completedLevels.reduce(max) + 1); // Max completed + 1
        // Ensure _maxUnlockedLevel does not exceed total levels + 1
        if (_maxUnlockedLevel > GameLevel.allLevels.length + 1) {
          _maxUnlockedLevel = GameLevel.allLevels.length + 1;
        }
      }
    });
  }

  // Saves progress to SharedPreferences
  void _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the Set of completed levels to a List of Strings to save
    final completedLevelsList = _completedLevels.map((level) => level.toString()).toList();
    await prefs.setStringList('classicalCompletedLevels', completedLevelsList);
  }

  // Function to start a level
  void _startLevel(int levelNumber) {
    setState(() {
      _selectedLevel = levelNumber;
      _resetLevel(); // Reset all words and available chars for the new level
    });
  }

  // Resets the entire current level's state
  void _resetLevel() {
    if (_selectedLevel == null) return; // Should not happen if called correctly

    final currentLevelData = GameLevel.allLevels[_selectedLevel! - 1];
    _currentAttempts = List.generate(
      currentLevelData.words.length, // Number of rows will be equal to number of words in level
      (wordIndex) => List.filled(currentLevelData.words[wordIndex].correctWord.length, ''), // Each row length matches its target word
    );
    _matchedWords = List.filled(currentLevelData.words.length, null); // Initialize all rows as unmatched
    _completedCorrectWordsSet = {}; // Clear the set of completed words
    _availableScrambledChars = List.from(currentLevelData.commonLetterPool);
    _availableScrambledChars.shuffle(Random()); // Shuffle the common pool
    _hintsUsedOverall = 0; // Reset hints for the new level
    _showFeedback = false;
    _isLastActionCorrect = false;
  }

  // Handles a letter being placed in a specific word's slot
  void _onLetterPlaced(String letter, int wordIndex, int letterIndex) {
    setState(() {
      // If this row was previously matched, unmatch it first
      if (_matchedWords[wordIndex] != null) {
        _completedCorrectWordsSet.remove(_matchedWords[wordIndex]!.correctWord);
        _matchedWords[wordIndex] = null;
      }

      // If there was already a letter in this slot, return it to the available pool
      if (_currentAttempts[wordIndex][letterIndex].isNotEmpty) {
        _availableScrambledChars.add(_currentAttempts[wordIndex][letterIndex]);
      }

      _currentAttempts[wordIndex][letterIndex] = letter;
      _availableScrambledChars.remove(letter);

      // Only attempt to match if the row is now full
      if (_currentAttempts[wordIndex].every((char) => char.isNotEmpty)) {
        _attemptToMatchWord(wordIndex);
      } else {
        _showFeedback = false; // Clear feedback if not full
      }
      _checkLevelCompletion(); // Always check level completion after any change
    });
  }

  // Handles a letter being tapped in a specific word's slot (to return it)
  void _onLetterReturned(int wordIndex, int letterIndex) {
    setState(() {
      final letterToReturn = _currentAttempts[wordIndex][letterIndex];
      if (letterToReturn.isNotEmpty) {
        _availableScrambledChars.add(letterToReturn);
        _availableScrambledChars.sort(); // Keep sorted for consistent display (optional)

        _currentAttempts[wordIndex][letterIndex] = '';

        // If this row was previously matched, unmatch it
        if (_matchedWords[wordIndex] != null) {
          _completedCorrectWordsSet.remove(_matchedWords[wordIndex]!.correctWord);
          _matchedWords[wordIndex] = null;
          _showFeedback = false; // Clear feedback
        }
      }
    });
  }

  // Attempts to match the word formed in a specific attempt row
  void _attemptToMatchWord(int wordIndex) {
    final attemptedWord = _currentAttempts[wordIndex].join();
    final currentLevelWords = GameLevel.allLevels[_selectedLevel! - 1].words;

    bool foundMatch = false;
    for (var correctGameWord in currentLevelWords) {
      // Check if this correct word has already been found by ANY row
      if (!_completedCorrectWordsSet.contains(correctGameWord.correctWord)) {
        if (attemptedWord == correctGameWord.correctWord) {
          setState(() {
            _matchedWords[wordIndex] = correctGameWord; // Mark this row as matching this specific correct word
            _completedCorrectWordsSet.add(correctGameWord.correctWord); // Add to the set of found words
            _isLastActionCorrect = true;
            _showFeedback = true;
          });
          foundMatch = true;
          break; // Found a match for this attempted word, stop checking other correct words
        }
      }
    }

    if (!foundMatch) {
      setState(() {
        _isLastActionCorrect = false;
        _showFeedback = true;
      });
    }
  }

  // Checks if all words in the current level are completed
  void _checkLevelCompletion() {
    final currentLevelWords = GameLevel.allLevels[_selectedLevel! - 1].words;
    // Check if the number of unique words in _completedCorrectWordsSet matches the total words for the level
    if (_completedCorrectWordsSet.length == currentLevelWords.length) {
      // If a level is completed, we should save the progress.
      // We will now add the completed level to the set and save it.
      if (!_completedLevels.contains(_selectedLevel!)) {
        _completedLevels.add(_selectedLevel!);
        _saveProgress(); // Call the new save function here
      }
      
      Future.delayed(const Duration(seconds: 1), () {
        _showCompletionDialog();
      });
    }
  }

  // Provides a hint to the user
  void _getHint() {
    if (_hintsUsedOverall >= _maxHintsPerLevel) {
      _showMessageDialog('Hint Limit Reached', 'You have used all $_maxHintsPerLevel hints for this level.');
      return;
    }

    final currentLevelWords = GameLevel.allLevels[_selectedLevel! - 1].words;
    
    // Find an un-matched correct word
    GameWord? correctWordToHint;
    for (var gw in currentLevelWords) {
      if (!_completedCorrectWordsSet.contains(gw.correctWord)) {
        correctWordToHint = gw;
        break;
      }
    }

    if (correctWordToHint == null) {
      _showMessageDialog('All Words Completed', 'All words in this level are already completed!');
      return;
    }

    setState(() {
      _hintsUsedOverall++; // Increment hint count
    });
    
    _showDefinitionHintDialog(correctWordToHint);
  }

  // Shows a dialog with the word's definition
  void _showDefinitionHintDialog(GameWord gameWord) {
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
                const Text(
                  'HINT',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5A2B),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  gameWord.definition,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF8B5A2B),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5A2B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'CLOSE',
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

  // Resets all words in the current level
  void _resetAllWords() {
    _resetLevel();
    setState(() {}); // Trigger rebuild
  }

  // Shows a generic message dialog (for hint limit, etc.)
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
    // Add the completed level to the set and save it before the dialog appears
    if (!_completedLevels.contains(_selectedLevel!)) {
      _completedLevels.add(_selectedLevel!);
      _saveProgress(); // Ensure progress is saved
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFF5E6CC), // Match UI image background
          title: const Text('Level Completed!', style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)), // Match UI image text color
          content: Text('Congratulations! You finished Level $_selectedLevel.', style: const TextStyle(color: Color(0xFF8B5A2B))), // Match UI image text color
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                setState(() {
                  _selectedLevel = null; // Go back to level selection
                });
              },
              child: const Text('Back to Levels', style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
            ),
            if (_selectedLevel! < GameLevel.allLevels.length)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _startLevel(_selectedLevel! + 1); // Start next level
                },
                child: const Text('Next Level', style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6CC), // Overall background color from UI image
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6CC), // AppBar background color from UI image
        elevation: 0, // No shadow
        title: Text(
          _selectedLevel == null ? 'Select Level' : 'Level $_selectedLevel',
          style: const TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold, fontSize: 24), // Match UI image text color and size
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF8B5A2B)), // Match UI image icon color
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
      body: SafeArea(
        child: _selectedLevel == null
            ? _buildLevelSelection()
            : _buildGamePlay(),
      ),
    );
  }

  // Builds the level selection screen
  Widget _buildLevelSelection() {
    return Column(
      children: [
       
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
              // Check if the level is locked based on _maxUnlockedLevel
              final bool isLocked = level.levelNumber > _maxUnlockedLevel;
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
              ? const Color(0xFFD4C7B7).withOpacity(0.6) // Lighter greyish-brown for locked
              : (isCompleted ? const Color(0xFF8B5A2B) : const Color(0xFFFDF0D5)), // Dark brown for completed, light yellow for unlocked
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
                ? const Color(0xFF8D7C6A) // Darker border for locked
                : (isCompleted ? const Color(0xFF5A3B1F) : const Color(0xFFD4C7B7)), // Darker brown for completed, light brown for unlocked
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLocked ? Icons.lock : (isCompleted ? Icons.check_circle : Icons.play_arrow), // Play icon for unlocked, check for completed
              size: 48,
              color: isLocked ? const Color(0xFF8D7C6A) : (isCompleted ? Colors.white : const Color(0xFF8B5A2B)), // Icon color
            ),
            const SizedBox(height: 12),
            Text(
              'Level $levelNumber',
              style: TextStyle(
                color: isLocked ? const Color(0xFF8D7C6A) : (isCompleted ? Colors.white : const Color(0xFF8B5A2B)), // Text color
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
    // Defensive checks for _selectedLevel
    if (_selectedLevel == null || _selectedLevel! - 1 < 0 || _selectedLevel! - 1 >= GameLevel.allLevels.length) {
      return const Center(child: Text("Error: Invalid level selected.", style: TextStyle(color: Colors.black87)));
    }

    final currentLevelData = GameLevel.allLevels[_selectedLevel! - 1];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
      children: [
        Expanded(child: SizedBox()),        
     
        // Display for the words being formed by the user (target boxes)
        SingleChildScrollView( // Allow scrolling if many words
          padding: const EdgeInsets.all(10),
          child: Column(
            children: List.generate(currentLevelData.words.length, (wordIndex) {
              final currentGameWord = currentLevelData.words[wordIndex];
              final bool isWordCompleted = _matchedWords[wordIndex] != null; // Check if this specific row is matched
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    // The existing letter boxes
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isWordCompleted
                            ? const Color.fromARGB(219, 200, 230, 201)
                            : const Color(0xFFFDF0D5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isWordCompleted
                              ? Colors.green
                              : const Color(0xFFD4C7B7),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(52, 0, 0, 0),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 5.0,
                        runSpacing: 5.0,
                        children: List.generate(currentGameWord.correctWord.length, (letterIndex) {
                          final String currentLetter = _currentAttempts[wordIndex][letterIndex];
                          return DragTarget<String>(
                            onWillAcceptWithDetails: (data) => !isWordCompleted, // Only accept if word not completed
                            onAcceptWithDetails: (data) {
                              if (!isWordCompleted) {
                                _onLetterPlaced(data.data, wordIndex, letterIndex);
                              }
                            },
                            builder: (context, candidateData, rejectedData) {
                              return GestureDetector( // Make letter in attempt box tappable to return
                                onTap: isWordCompleted ? null : () => _onLetterReturned(wordIndex, letterIndex),
                                child: _buildAttemptLetterBox(
                                  currentLetter,
                                  wordIndex, // Pass wordIndex for feedback logic
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        // Display for scrambled letters (draggable letters)
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF0D5), // Light yellow background for the main box
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4C7B7), // Light beige border
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(45, 0, 0, 0),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0, // Smaller spacing for available letters
            runSpacing: 8.0,
            children: _availableScrambledChars.map((char) {
              return Draggable<String>(
                data: char,
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildLetterBox(char, isFeedback: true),
                ),
                childWhenDragging: _buildLetterBox(char, isDragging: true), // Show ghost when dragging
                child: _buildLetterBox(char),
              );
            }).toList(),
          ),
        ),
        // Action Buttons
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.refresh,
                label: 'RESET',
                color: const Color(0xFFD4C7B7), // Match UI image button color
                onTap: _resetAllWords, // Reset all words in the level
              ),
              _buildActionButton(
                icon: Icons.lightbulb_outline,
                label: 'HINT', // Label as per UI image
                color: const Color(0xFFD4C7B7), // Match UI image button color
                onTap: _getHint,
              ),
            ],
          ),
        ),
        // Feedback message (optional, can be removed if not desired)
       
      ],
    );
  }

  // Helper to build a letter box for draggable letters (bottom pool)
  Widget _buildLetterBox(String letter, {bool isFeedback = false, bool isDragging = false}) {
    return Container(
      width: 45, // Smaller width
      height: 45, // Smaller height
      decoration: BoxDecoration(
        color: isFeedback
            ? const Color.fromARGB(76, 139, 89, 43)
            : (isDragging ? Colors.transparent : const Color(0xFFD4C7B7)),
        borderRadius: BorderRadius.circular(8), // Slightly smaller radius
        border: Border.all(
          color: isFeedback ? Colors.white : const Color(0xFF8D7C6A),
          width: 1.5, // Slightly thinner border
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(34, 0, 0, 0),
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
          fontSize: 24, // Smaller font size
          fontWeight: FontWeight.bold,
          color: isFeedback ? Colors.white : const Color(0xFF8B5A2B),
        ),
      ),
    );
  }

  // Helper to build a letter box for the attempt (top word slots)
  Widget _buildAttemptLetterBox(String letter, int wordIndex) { // Removed showFeedback, isCorrect params
    Color borderColor = const Color(0xFF8D7C6A);
    Color bgColor = const Color(0xFFD4C7B7);
    Color textColor = const Color(0xFF8B5A2B);

    bool isWordCompleted = _matchedWords[wordIndex] != null;

    if (isWordCompleted) {
      borderColor = Colors.green.shade700;
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade900;
    } else if (_currentAttempts[wordIndex].every((char) => char.isNotEmpty) && _showFeedback && !_isLastActionCorrect) {
      // If the word row is full, and last action was incorrect, and this row is not matched
      borderColor = Colors.red.shade700;
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade900;
    } else if (letter.isEmpty) {
      bgColor = const Color.fromARGB(102, 212, 199, 183);
    }

    return Container(
      width: 45, // Smaller width
      height: 45, // Smaller height
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8), // Slightly smaller radius
        border: Border.all(
          color: borderColor,
          width: 1.5, // Slightly thinner border
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(34, 0, 0, 0),
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
          fontSize: 24, // Smaller font size
          fontWeight: FontWeight.bold,
          color: textColor,
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
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFD4C7B7),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(36, 0, 0, 0),
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
            Icon(icon, color: const Color(0xFF8B5A2B), size: 28),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8B5A2B),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
