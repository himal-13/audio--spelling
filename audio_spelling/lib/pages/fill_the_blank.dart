import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:async';

// Data structure for a single word in the game
class FillWord {
  final String word;
  final String clue;
  final int blanks; // Number of blanks to hide

  FillWord({
    required this.word,
    required this.clue,
    this.blanks = 1,
  });
}

// Data structure for a single Fill-in-the-Blank puzzle level
class FillTheBlankLevel {
  final int levelNumber;
  final List<FillWord> words;

  FillTheBlankLevel({
    required this.levelNumber,
    required this.words,
  });

  static List<FillTheBlankLevel> get allLevels => [
    FillTheBlankLevel(
      levelNumber: 1,
      words: [
        FillWord(word: 'BAT', clue: 'An animal that flies at night (3 letters).', blanks: 1),
        FillWord(word: 'CAT', clue: 'A small domesticated carnivorous mammal with soft fur (3 letters).', blanks: 1),
        FillWord(word: 'SUN', clue: 'The star at the center of our solar system (3 letters).', blanks: 1),
        FillWord(word: 'CAR', clue: 'A road vehicle, typically with four wheels (3 letters).', blanks: 1),
      ],
    ),
    FillTheBlankLevel(
      levelNumber: 2,
      words: [
        FillWord(word: 'APPLE', clue: 'A common fruit that is red or green (5 letters).', blanks: 2),
        FillWord(word: 'BREAD', clue: 'A staple food made from flour (5 letters).', blanks: 2),
        FillWord(word: 'WATER', clue: 'A transparent fluid that forms the seas, lakes, and rivers (5 letters).', blanks: 2),
      ],
    ),
    FillTheBlankLevel(
      levelNumber: 3,
      words: [
        FillWord(word: 'BEACH', clue: 'A sandy shore by the ocean (5 letters).', blanks: 2),
        FillWord(word: 'DREAM', clue: 'A series of thoughts, images, or sensations occurring in a person’s mind during sleep (5 letters).', blanks: 2),
        FillWord(word: 'OCEAN', clue: 'A very large expanse of sea (5 letters).', blanks: 2),
      ],
    ),
    FillTheBlankLevel(
      levelNumber: 4,
      words: [
        FillWord(word: 'ORANGE', clue: 'A round citrus fruit with a tough, bright reddish-yellow rind (6 letters).', blanks: 2),
        FillWord(word: 'FROZEN', clue: 'Turned into ice; very cold (6 letters).', blanks: 2),
        FillWord(word: 'CASTLE', clue: 'A large building with thick walls and towers that was built in the past (6 letters).', blanks: 2),
        FillWord(word: 'LIZARD', clue: 'A reptile with a long body and tail (6 letters).', blanks: 2),
      ],
    ),
    FillTheBlankLevel(
      levelNumber: 5,
      words: [
        FillWord(word: 'PLANET', clue: 'A celestial body orbiting a star (6 letters).', blanks: 2),
        FillWord(word: 'PYTHON', clue: 'A large constricting snake or a programming language (6 letters).', blanks: 3),
        FillWord(word: 'RHYTHM', clue: 'A strong, regular, repeated pattern of movement or sound (6 letters).', blanks: 3),
      ],
    ),
    FillTheBlankLevel(
      levelNumber: 6,
      words: [
        FillWord(word: 'MOUNTAIN', clue: 'A large natural elevation of the earth\'s surface (8 letters).', blanks: 3),
        FillWord(word: 'UMBRELLA', clue: 'A device for protection against rain or sun (8 letters).', blanks: 3),
        FillWord(word: 'KEYBOARD', clue: 'A panel of keys that operate a computer or typewriter (8 letters).', blanks: 3),
      ],
    ),
    FillTheBlankLevel(
      levelNumber: 7,
      words: [
        FillWord(word: 'BICYCLE', clue: 'A vehicle with two wheels, a saddle, and handlebars (7 letters).', blanks: 3),
        FillWord(word: 'FANTASY', clue: 'The faculty or activity of imagining impossible or improbable things (7 letters).', blanks: 3),
        FillWord(word: 'JOURNEY', clue: 'An act of traveling from one place to another (7 letters).', blanks: 3),
        FillWord(word: 'MYSTERY', clue: 'Something that is difficult or impossible to understand or explain (7 letters).', blanks: 3),
      ],
    ),
    FillTheBlankLevel(
      levelNumber: 8,
      words: [
        FillWord(word: 'ADVENTURE', clue: 'An unusual and exciting or daring experience (9 letters).', blanks: 4),
        FillWord(word: 'HOSPITAL', clue: 'An institution providing medical and surgical treatment (8 letters).', blanks: 3),
        FillWord(word: 'EDUCATION', clue: 'The process of receiving or giving systematic instruction (9 letters).', blanks: 4),
      ],
    ),
    FillTheBlankLevel(
      levelNumber: 9,
      words: [
        FillWord(word: 'CHALLENGE', clue: 'A call to take part in a contest or competition (9 letters).', blanks: 4),
        FillWord(word: 'ELEPHANT', clue: 'A large land animal with a trunk (8 letters).', blanks: 3),
        FillWord(word: 'TELEVISION', clue: 'An electronic device that receives signals and displays them on a screen (10 letters).', blanks: 4),
        FillWord(word: 'SYNONYMOUS', clue: 'Having the same or a similar meaning (10 letters).', blanks: 4),
      ],
    ),
    FillTheBlankLevel(
      levelNumber: 10,
      words: [
        FillWord(word: 'PROGRAMMING', clue: 'The process of writing computer programs (11 letters).', blanks: 4),
        FillWord(word: 'DEVELOPMENT', clue: 'The process of growing or changing (11 letters).', blanks: 5),
        FillWord(word: 'IMAGINATION', clue: 'The faculty or action of forming new ideas (11 letters).', blanks: 5),
        FillWord(word: 'CONSTITUTION', clue: 'A body of fundamental principles or established precedents (12 letters).', blanks: 5),
      ],
    ),
  ];
}


class FillTheBlankGamePage extends StatefulWidget {
  const FillTheBlankGamePage({super.key});

  @override
  State<FillTheBlankGamePage> createState() => _FillTheBlankGamePageState();
}

class _FillTheBlankGamePageState extends State<FillTheBlankGamePage> {
  int? _selectedLevelNumber;
  late FillTheBlankLevel _currentLevel;
  late Set<int> _completedLevels;
  int _maxUnlockedLevel = 1;
  bool _isLoading = true;

  // Game state for the current level
  List<List<String>> _userWords = [];
  List<List<int>> _blankIndices = [];
  List<String> _letterBank = [];
  List<bool> _bankUsed = [];
  List<bool?> _isWordCorrect = []; // null: unchecked, true: correct, false: incorrect

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _completedLevels = (prefs.getStringList('fillBlankCompletedLevels') ?? [])
          .map(int.parse)
          .toSet();

      if (_completedLevels.isEmpty) {
        _maxUnlockedLevel = 1;
      } else {
        _maxUnlockedLevel = (_completedLevels.reduce(max) + 1);
        if (_maxUnlockedLevel > FillTheBlankLevel.allLevels.length) {
          _maxUnlockedLevel = FillTheBlankLevel.allLevels.length;
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'fillBlankCompletedLevels', _completedLevels.map((e) => e.toString()).toList());
  }

  Future<void> _resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fillBlankCompletedLevels');
    _loadProgress();
    setState(() {
      _selectedLevelNumber = null;
    });
  }

  void _startLevel(int levelNumber) {
    final level = FillTheBlankLevel.allLevels.firstWhere((p) => p.levelNumber == levelNumber);
    setState(() {
      _selectedLevelNumber = levelNumber;
      _currentLevel = level;
      _setupWords();
    });
  }

  void _setupWords() {
    _userWords.clear();
    _blankIndices.clear();
    _letterBank.clear();
    _isWordCorrect = List.filled(_currentLevel.words.length, null);

    final random = Random();
    List<String> missingLetters = [];

    for (var wordInfo in _currentLevel.words) {
      final originalWord = wordInfo.word.toUpperCase();
      List<int> wordBlankIndices = [];
      while (wordBlankIndices.length < wordInfo.blanks) {
        final index = random.nextInt(originalWord.length);
        if (!wordBlankIndices.contains(index)) {
          wordBlankIndices.add(index);
          missingLetters.add(originalWord[index]);
        }
      }
      _blankIndices.add(wordBlankIndices);
      _userWords.add(List.filled(originalWord.length, ''));
    }

    _letterBank = [...missingLetters];
    // Add some extra random letters to the bank
    while (_letterBank.length < missingLetters.length + 3) {
      _letterBank.add(String.fromCharCode('A'.codeUnitAt(0) + random.nextInt(26)));
    }
    _letterBank.shuffle(random);
    _bankUsed = List.filled(_letterBank.length, false);

    setState(() {});
  }

  void _checkAnswers() {
    bool allCorrect = true;
    for (int i = 0; i < _currentLevel.words.length; i++) {
      final correctWord = _currentLevel.words[i].word.toUpperCase();
      String userWord = '';

      for (int j = 0; j < correctWord.length; j++) {
        if (_blankIndices[i].contains(j)) {
          userWord += _userWords[i][j];
        } else {
          userWord += correctWord[j];
        }
      }

      setState(() {
        if (userWord == correctWord) {
          _isWordCorrect[i] = true;
        } else {
          _isWordCorrect[i] = false;
          allCorrect = false;
        }
      });
    }

    if (allCorrect) {
      _showCompletionDialog();
    } else {
      Timer(const Duration(seconds: 2), () {
        _resetWrongWords();
      });
    }
  }

  void _resetWrongWords() {
    setState(() {
      for (int i = 0; i < _currentLevel.words.length; i++) {
        if (_isWordCorrect[i] == false) {
          // Find the letters used for the wrong word and return them to the bank
          for (int j = 0; j < _blankIndices[i].length; j++) {
            final blankIndex = _blankIndices[i][j];
            final usedLetter = _userWords[i][blankIndex];
            if (usedLetter.isNotEmpty) {
              final bankIndex = _letterBank.indexOf(usedLetter);
              if (bankIndex != -1) {
                _bankUsed[bankIndex] = false;
              }
            }
          }
          // Reset the user's input for the wrong word
          _userWords[i] = List.filled(_currentLevel.words[i].word.length, '');
          _isWordCorrect[i] = null; // Reset feedback state
        }
      }
    });
  }

  void _showCompletionDialog() {
    if (!_completedLevels.contains(_selectedLevelNumber!)) {
      _completedLevels.add(_selectedLevelNumber!);
      _saveProgress();
      _loadProgress();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFF5E6CC),
          title: const Text('Level Completed!',
              style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
          content: Text('Congratulations! You finished Level $_selectedLevelNumber.',
              style: const TextStyle(color: Color(0xFF8B5A2B))),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedLevelNumber = null;
                });
              },
              child: const Text('Back to Levels',
                  style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
            ),
            if (_selectedLevelNumber! < FillTheBlankLevel.allLevels.length)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startLevel(_selectedLevelNumber! + 1);
                },
                child: const Text('Next Level',
                    style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
              ),
          ],
        );
      },
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Progress?'),
          content: const Text('Are you sure you want to reset all your game progress? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _resetProgress();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _selectedLevelNumber == null ? 'Fill in the Blank' : 'Level $_selectedLevelNumber',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5B6DF0),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (_selectedLevelNumber != null) {
              setState(() {
                _selectedLevelNumber = null;
                _loadProgress();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (_selectedLevelNumber == null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _showResetDialog,
              tooltip: 'Reset Progress',
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _selectedLevelNumber == null
            ? _buildLevelSelection()
            : _buildGamePlay(),
      ),
    );
  }

  Widget _buildLevelSelection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Fill in the Blank',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
              childAspectRatio: 1.2,
            ),
            itemCount: FillTheBlankLevel.allLevels.length,
            itemBuilder: (context, index) {
              final level = FillTheBlankLevel.allLevels[index];
              final bool isLocked = level.levelNumber > _maxUnlockedLevel;
              final bool isCompleted = _completedLevels.contains(level.levelNumber);

              return _buildLevelButton(level.levelNumber, isLocked, isCompleted);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLevelButton(int levelNumber, bool isLocked, bool isCompleted) {
    return InkWell(
      onTap: isLocked ? null : () => _startLevel(levelNumber),
      child: Container(
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.grey.shade300
              : (isCompleted ? const Color(0xFF5B6DF0) : Colors.white),
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
            color: isLocked ? Colors.grey : const Color(0xFF5B6DF0),
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLocked ? Icons.lock : (isCompleted ? Icons.check_circle : Icons.grid_on),
              size: 48,
              color: isLocked ? Colors.grey.shade700 : (isCompleted ? Colors.white : const Color(0xFF5B6DF0)),
            ),
            const SizedBox(height: 12),
            Text(
              'Level $levelNumber',
              style: TextStyle(
                color: isLocked ? Colors.grey.shade700 : (isCompleted ? Colors.white : Colors.black87),
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

  Widget _buildGamePlay() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Drag the letters to fill in the blanks.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _currentLevel.words.length,
            itemBuilder: (context, wordIndex) {
              return _buildWordRow(wordIndex);
            },
          ),
        ),
        _buildLetterBank(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _checkAnswers,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B6DF0),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 5,
            ),
            child: const Text(
              'Check Answers',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordRow(int wordIndex) {
    final originalWord = _currentLevel.words[wordIndex].word.toUpperCase();
    final blankIndices = _blankIndices[wordIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(originalWord.length, (letterIndex) {
            final isBlank = blankIndices.contains(letterIndex);
            final letter = isBlank ? _userWords[wordIndex][letterIndex] : originalWord[letterIndex];

            return DragTarget<Map<String, dynamic>>(
              onWillAccept: (data) => isBlank && letter.isEmpty,
              onAccept: (data) {
                setState(() {
                  final draggedLetter = data['letter'] as String;
                  final bankIndex = data['bankIndex'] as int;
                  _userWords[wordIndex][letterIndex] = draggedLetter;
                  _bankUsed[bankIndex] = true;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: 35,
                  height: 45,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isBlank ? Colors.grey.shade200 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isBlank ? Colors.grey.shade400 : Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          // Feedback icon
          if (_isWordCorrect[wordIndex] != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                _isWordCorrect[wordIndex]! ? Icons.check_circle : Icons.cancel,
                color: _isWordCorrect[wordIndex]! ? Colors.green : Colors.red,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLetterBank() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children: List.generate(_letterBank.length, (index) {
        final letter = _letterBank[index];
        final isUsed = _bankUsed[index];

        return isUsed
            ? Container(width: 45, height: 45) // Empty space for used letters
            : Draggable<Map<String, dynamic>>(
                data: {'letter': letter, 'bankIndex': index},
                feedback: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B6DF0).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Container(width: 45, height: 45),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
      }),
    );
  }
}