import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

// New class to store a found word and its path
class FoundWord {
  final String word;
  final List<Offset> path;

  FoundWord(this.word, this.path);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoundWord &&
          runtimeType == other.runtimeType &&
          word == other.word;

  @override
  int get hashCode => word.hashCode;
}

// Define a data structure for a Word Search game level
class WordSearchLevel {
  final int levelNumber;
  final int gridSize;
  final List<String> wordsToFind;

  WordSearchLevel({required this.levelNumber, required this.gridSize, required this.wordsToFind});

  static List<WordSearchLevel> get allLevels => [
        WordSearchLevel(
          levelNumber: 1,
          gridSize: 8, // Smaller grid for easier start
          wordsToFind: ['CAT', 'DOG', 'SUN', 'RUN', 'JUMP', 'FISH'],
        ),
        WordSearchLevel(
          levelNumber: 2,
          gridSize: 9,
          wordsToFind: ['APPLE', 'HOUSE', 'TABLE', 'CHAIR', 'WATER', 'BIRD', 'TREE'],
        ),
        WordSearchLevel(
          levelNumber: 3,
          gridSize: 10,
          wordsToFind: ['ELEPHANT', 'COMPUTER', 'KEYBOARD', 'MOUNTAIN', 'OCEAN', 'RIVER', 'CLOUD', 'FOREST'],
        ),
        WordSearchLevel(
          levelNumber: 4,
          gridSize: 12, // Larger grid, more words
          wordsToFind: ['PROGRAMMING', 'DEVELOPER', 'APPLICATION', 'INTELLIGENCE', 'ENGINEERING', 'SOFTWARE', 'ALGORITHM', 'DATABASE', 'NETWORK', 'INTERNET'],
        ),
      ];
}


class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key});

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  int? _selectedLevelNumber; // Tracks the selected level number
  late int _currentGridSize; // Grid size for the current level
  late List<String> _currentWordsToFind; // Words for the current level

  List<List<String>> _grid = [];
  List<FoundWord> _foundWords = []; // Stores FoundWord objects
  List<Offset> _currentSelectionPath = []; // Stores grid coordinates of current selection
  Offset? _startSelection;
  Offset? _endSelection;

  // GlobalKey to get the RenderBox of the grid container
  final GlobalKey _gridContainerKey = GlobalKey();

  // Set to store completed levels for Word Search
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
      _completedLevels = (prefs.getStringList('wordSearchCompletedLevels') ?? [])
          .map(int.parse) // Convert string back to int
          .toSet(); // Convert list to set

      // Determine the max unlocked level
      if (_completedLevels.isEmpty) {
        _maxUnlockedLevel = 1; // Start with Level 1 unlocked
      } else {
        _maxUnlockedLevel = (_completedLevels.reduce(max) + 1); // Max completed + 1
        // Ensure _maxUnlockedLevel does not exceed total levels + 1
        if (_maxUnlockedLevel > WordSearchLevel.allLevels.length + 1) {
          _maxUnlockedLevel = WordSearchLevel.allLevels.length + 1;
        }
      }
    });
  }

  // Saves progress to SharedPreferences
  void _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the set of completed levels to a list of strings for storage
    await prefs.setStringList(
        'wordSearchCompletedLevels', _completedLevels.map((e) => e.toString()).toList());
  }

  // Function to start a specific Word Search level
  void _startLevel(int levelNumber) {
    final level = WordSearchLevel.allLevels.firstWhere((lvl) => lvl.levelNumber == levelNumber);
    setState(() {
      _selectedLevelNumber = levelNumber;
      _currentGridSize = level.gridSize;
      _currentWordsToFind = List.from(level.wordsToFind); // Make a mutable copy
      _foundWords.clear(); // Clear found words for the new level
      _generateGrid(); // Generate grid for the selected level
    });
  }

  // Generates the word search grid
  void _generateGrid() {
    _grid = List.generate(_currentGridSize, (_) => List.filled(_currentGridSize, ''));
    _foundWords.clear();

    // Sort words by length descending to place longer words first
    _currentWordsToFind.sort((a, b) => b.length.compareTo(a.length));

    // Place words on the grid
    for (String word in _currentWordsToFind) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 100) { // Limit attempts to prevent infinite loops
        final direction = Random().nextInt(8); // 0:horiz, 1:vert, 2:diag_down_right, 3:diag_up_right, etc.
        final startRow = Random().nextInt(_currentGridSize);
        final startCol = Random().nextInt(_currentGridSize);

        if (_tryPlaceWord(word, startRow, startCol, direction)) {
          placed = true;
        }
        attempts++;
      }
    }

    // Fill remaining empty cells with random letters
    _fillEmptyCells();

    setState(() {}); // Update UI after grid generation
  }

  // Tries to place a word on the grid
  bool _tryPlaceWord(String word, int r, int c, int direction) {
    int dr = 0, dc = 0; // delta row, delta column
    switch (direction) {
      case 0: dr = 0; dc = 1; break; // Horizontal (left to right)
      case 1: dr = 1; dc = 0; break; // Vertical (top to bottom)
      case 2: dr = 1; dc = 1; break; // Diagonal (down-right)
      case 3: dr = 1; dc = -1; break; // Diagonal (down-left)
      case 4: dr = 0; dc = -1; break; // Horizontal (right to left)
      case 5: dr = -1; dc = 0; break; // Vertical (bottom to top)
      case 6: dr = -1; dc = 1; break; // Diagonal (up-right)
      case 7: dr = -1; dc = -1; break; // Diagonal (up-left)
    }

    // Check if word fits and doesn't conflict
    for (int i = 0; i < word.length; i++) {
      int curR = r + i * dr;
      int curC = c + i * dc;

      if (curR < 0 || curR >= _currentGridSize || curC < 0 || curC >= _currentGridSize) {
        return false; // Out of bounds
      }
      if (_grid[curR][curC] != '' && _grid[curR][curC] != word[i]) {
        return false; // Conflict with existing letter
      }
    }

    // Place the word
    for (int i = 0; i < word.length; i++) {
      int curR = r + i * dr;
      int curC = c + i * dc;
      _grid[curR][curC] = word[i].toUpperCase();
    }
    return true;
  }

  // Fills empty cells with random letters
  void _fillEmptyCells() {
    final random = Random();
    const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int r = 0; r < _currentGridSize; r++) {
      for (int c = 0; c < _currentGridSize; c++) {
        if (_grid[r][c] == '') {
          _grid[r][c] = alphabet[random.nextInt(alphabet.length)];
        }
      }
    }
  }

  // Converts global position to grid coordinates using the specific RenderBox
  Offset _getGridCoordinates(Offset globalPosition, RenderBox gridRenderBox) {
    final localPosition = gridRenderBox.globalToLocal(globalPosition);

    // The padding is 16.0 on all sides, so the actual grid area starts after this padding.
    // The cellSize is calculated based on the *inner* width of the container.
    final double padding = 16.0;
    final double innerGridWidth = gridRenderBox.size.width - (2 * padding);
    final double cellSize = innerGridWidth / _currentGridSize;

    // Calculate column and row relative to the inner grid area
    final int col = ((localPosition.dx - padding) / cellSize).floor();
    final int row = ((localPosition.dy - padding) / cellSize).floor();

    // Ensure coordinates are within bounds
    if (col < 0 || col >= _currentGridSize || row < 0 || row >= _currentGridSize) {
      return const Offset(-1, -1); // Invalid coordinates
    }

    return Offset(col.toDouble(), row.toDouble());
  }

  // Handles drag start
  void _onPanStart(DragStartDetails details) {
    final RenderBox? gridRenderBox = _gridContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (gridRenderBox == null) return;

    final startCoords = _getGridCoordinates(details.globalPosition, gridRenderBox);
    if (startCoords.dx < 0 || startCoords.dy < 0) return; // Invalid coordinates

    setState(() {
      _startSelection = startCoords;
      _currentSelectionPath = [_startSelection!];
      _endSelection = null;
    });
  }

  // Handles drag update
  void _onPanUpdate(DragUpdateDetails details) {
    if (_startSelection == null) return; // Must have a start point

    final RenderBox? gridRenderBox = _gridContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (gridRenderBox == null) return;

    final endCoords = _getGridCoordinates(details.globalPosition, gridRenderBox);
    if (endCoords.dx < 0 || endCoords.dy < 0) return; // Invalid coordinates

    setState(() {
      _endSelection = endCoords;
      _currentSelectionPath = _getCellsInSelection(_startSelection!, _endSelection!);
    });
  }

  // Handles drag end
  void _onPanEnd(DragEndDetails details) {
    if (_startSelection != null && _endSelection != null) {
      _checkSelection();
    }
    setState(() {
      _startSelection = null;
      _endSelection = null;
      _currentSelectionPath = [];
    });
  }

  // Gets all cells between start and end selection (for straight lines only)
  List<Offset> _getCellsInSelection(Offset start, Offset end) {
    List<Offset> cells = [];
    int startCol = start.dx.toInt();
    int startRow = start.dy.toInt();
    int endCol = end.dx.toInt();
    int endRow = end.dy.toInt();

    // Ensure within grid bounds
    if (startCol < 0 || startCol >= _currentGridSize || startRow < 0 || startRow >= _currentGridSize ||
        endCol < 0 || endCol >= _currentGridSize || endRow < 0 || endRow >= _currentGridSize) {
      return [];
    }

    // Check for straight line (horizontal, vertical, diagonal)
    bool isHorizontal = startRow == endRow;
    bool isVertical = startCol == endCol;
    bool isDiagonal = (startRow - endRow).abs() == (startCol - endCol).abs();

    if (!isHorizontal && !isVertical && !isDiagonal) {
      return [start]; // Only allow straight lines
    }

    int dr = 0, dc = 0;
    if (startRow < endRow) dr = 1; else if (startRow > endRow) dr = -1;
    if (startCol < endCol) dc = 1; else if (startCol > endCol) dc = -1;

    int curR = startRow;
    int curC = startCol;

    while (true) {
      cells.add(Offset(curC.toDouble(), curR.toDouble()));
      if (curR == endRow && curC == endCol) break;
      curR += dr;
      curC += dc;
    }
    return cells;
  }

  // Checks if the selected word is correct
  void _checkSelection() {
    if (_currentSelectionPath.isEmpty) return;

    String selectedWord = '';
    for (Offset cell in _currentSelectionPath) {
      int r = cell.dy.toInt();
      int c = cell.dx.toInt();
      if (r >= 0 && r < _currentGridSize && c >= 0 && c < _currentGridSize) {
        selectedWord += _grid[r][c];
      }
    }

    // Check if the word is in the list of words to find (forward or reversed)
    bool foundForward = _currentWordsToFind.contains(selectedWord);
    bool foundBackward = _currentWordsToFind.contains(selectedWord.split('').reversed.join());

    String? wordToMark;
    if (foundForward && !_foundWords.any((fw) => fw.word == selectedWord)) {
      wordToMark = selectedWord;
    } else if (foundBackward && !_foundWords.any((fw) => fw.word == selectedWord.split('').reversed.join())) {
      wordToMark = selectedWord.split('').reversed.join();
    }

    if (wordToMark != null) {
      setState(() {
        _foundWords.add(FoundWord(wordToMark!, List.from(_currentSelectionPath))); // Store path

        // Check if all words in the current level are found
        if (_foundWords.length == _currentWordsToFind.length) {
          if (!_completedLevels.contains(_selectedLevelNumber!)) {
            _completedLevels.add(_selectedLevelNumber!); // Mark current level as completed
            _saveProgress(); // Save progress
          }
          _showCompletionDialog();
        }
      });
    } else {
      // Optional: Show "Not a word" feedback
      // _showFeedbackDialog('Not a Word', 'That\'s not one of the words to find.');
    }
  }

  // Shows a feedback dialog
 

  // Shows a dialog when the level is completed
  void _showCompletionDialog() {
    // Add the completed level to the set and save it before the dialog appears
    if (!_completedLevels.contains(_selectedLevelNumber!)) {
      _completedLevels.add(_selectedLevelNumber!);
      _saveProgress(); // Ensure progress is saved
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFF5E6CC), // Match UI image background
          title: const Text('Level Completed!', style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
          content: Text('Congratulations! You finished Level $_selectedLevelNumber.', style: const TextStyle(color: Color(0xFF8B5A2B))),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                setState(() {
                  _selectedLevelNumber = null; // Go back to level selection
                });
              },
              child: const Text('Back to Levels', style: TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
            ),
            if (_selectedLevelNumber! < WordSearchLevel.allLevels.length)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _startLevel(_selectedLevelNumber! + 1); // Start next level
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
        backgroundColor: const Color(0xFFF5E6CC),
        elevation: 0, // No shadow
        title: Text(
          _selectedLevelNumber == null ? 'Select Level' : 'Level $_selectedLevelNumber',
          style: const TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF8B5A2B)),
          onPressed: () {
            if (_selectedLevelNumber != null) {
              setState(() {
                _selectedLevelNumber = null; // Go back to level selection
              });
            } else {
              Navigator.pop(context); // Go back
            }
          },
        ),
      ),
      body: SafeArea(
        child: _selectedLevelNumber == null
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
            itemCount: WordSearchLevel.allLevels.length,
            itemBuilder: (context, index) {
              final level = WordSearchLevel.allLevels[index];
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
              isLocked ? Icons.lock : (isCompleted ? Icons.check_circle : Icons.search),
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
    // Defensive checks for current level data
    if (_selectedLevelNumber == null || _currentWordsToFind.isEmpty) {
      return const Center(child: Text("Error: Level data not loaded.", style: TextStyle(color: Colors.black87)));
    }

    return Column(
      children: [
        // Word list to find
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Find these words:',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B5A2B),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Adjust based on word length
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _currentWordsToFind.length,
            itemBuilder: (context, index) {
              final word = _currentWordsToFind[index];
              final isFound = _foundWords.any((fw) => fw.word == word); // Correct check
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isFound ? const Color(0xFF8B5A2B) : const Color(0xFFFDF0D5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF8D7C6A)),
                ),
                child: Text(
                  word,
                  style: TextStyle(
                    color: isFound ? Colors.white : const Color(0xFF8B5A2B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: isFound ? TextDecoration.lineThrough : TextDecoration.none,
                    decorationColor: isFound ? Colors.white : const Color(0xFF8B5A2B),
                    decorationThickness: 2,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Word Search Grid
        Expanded(
          flex: 3,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double cellSize = (constraints.maxWidth - 32) / _currentGridSize; // 32 for padding
              return GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Container(
                  key: _gridContainerKey, // Assign the GlobalKey here
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _currentGridSize,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: _currentGridSize * _currentGridSize,
                    itemBuilder: (context, index) {
                      final row = index ~/ _currentGridSize;
                      final col = index % _currentGridSize;
                      final letter = _grid[row][col];

                      // Determine if the current cell is part of the active selection path
                      final isSelected = _currentSelectionPath.contains(Offset(col.toDouble(), row.toDouble()));

                      // Determine if the current cell is part of any *found* word's path
                      final bool isCellInFoundWord = _foundWords.any((foundWord) =>
                          foundWord.path.contains(Offset(col.toDouble(), row.toDouble())));

                      return Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF8B5A2B) // New selection color
                              : (isCellInFoundWord ? Colors.green.shade700.withOpacity(0.4) : const Color(0xFFD4C7B7).withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isCellInFoundWord ? Colors.green.shade900 : const Color(0xFF8D7C6A).withOpacity(0.2),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          letter,
                          style: TextStyle(
                            color: isSelected || isCellInFoundWord ? Colors.white : const Color(0xFF8B5A2B),
                            fontSize: cellSize * 0.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _generateGrid,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5A2B), // New button color
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 5,
            ),
            child: const Text(
              'Reset', // Changed from New Game to New Puzzle
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
