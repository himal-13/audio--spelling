import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game state
  int _score = 0;
  int _level = 1;
  int _lives = 3;
  int _combo = 0;
  int _timeLeft = 60;
  bool _gameOver = false;
  late ConfettiController _confettiController;
  
  // Word lists by difficulty
  final List<String> _easyWords = ['CAT', 'DOG', 'SUN', 'MOON', 'STAR', 'TREE', 'FISH', 'BIRD'];
  final List<String> _mediumWords = ['APPLE', 'HOUSE', 'WATER', 'SMILE', 'MUSIC', 'PHONE', 'CLOUD', 'BEACH'];
  final List<String> _hardWords = ['PYTHON', 'DRAGON', 'SPRING', 'WINTER', 'SILVER', 'GOLDEN', 'BEAUTY', 'POWER'];
  final List<String> _expertWords = ['UNIVERSE', 'COMPUTER', 'BUTTERFLY', 'ADVENTURE', 'CHALLENGE', 'MYSTERIOUS'];
  
  // Current game state
  String _currentWord = '';
  List<String> _scrambledLetters = [];
  List<String> _selectedLetters = [];
  List<String> _hintLetters = [];
  Timer? _gameTimer;
  bool _showHintUI = false;
  int _hintCooldown = 0;
  
  // Power-ups
  int _shuffleCount = 3;
  int _freezeCount = 2;
  int _bombCount = 2;
  bool _isFrozen = false;
  int _freezeTimeLeft = 0;
  
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _startNewGame();
    _startTimer();
  }
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }
  
  void _startNewGame() {
    setState(() {
      _score = 0;
      _level = 1;
      _lives = 3;
      _combo = 0;
      _timeLeft = 60;
      _gameOver = false;
      _shuffleCount = 3;
      _freezeCount = 2;
      _bombCount = 2;
      _isFrozen = false;
    });
    _generateNewWord();
  }
  
  void _startTimer() {
    _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_gameOver) {
        timer.cancel();
        return;
      }
      
      if (_isFrozen) {
        setState(() {
          _freezeTimeLeft--;
          if (_freezeTimeLeft <= 0) {
            _isFrozen = false;
          }
        });
        return;
      }
      
      setState(() {
        _timeLeft--;
        if (_hintCooldown > 0) _hintCooldown--;
      });
      
      if (_timeLeft <= 0) {
        _loseLife();
      }
    });
  }
  
  void _generateNewWord() {
    List<String> wordList;
    
    if (_level <= 3) {
      wordList = _easyWords;
    } else if (_level <= 6) {
      wordList = _mediumWords;
    } else if (_level <= 9) {
      wordList = _hardWords;
    } else {
      wordList = _expertWords;
    }
    
    _currentWord = wordList[Random().nextInt(wordList.length)];
    _scrambleWord();
    _selectedLetters.clear();
    _showHintUI = false;
    
    // Generate hint letters (20% of the word)
    _hintLetters = [];
    int hintCount = max(1, (_currentWord.length * 0.2).ceil());
    List<int> hintIndices = List.generate(_currentWord.length, (i) => i)..shuffle();
    
    for (int i = 0; i < hintCount && i < hintIndices.length; i++) {
      _hintLetters.add(_currentWord[hintIndices[i]]);
    }
  }
  
  void _scrambleWord() {
    List<String> letters = _currentWord.split('');
    letters.shuffle();
    _scrambledLetters = letters;
  }
  
  void _onLetterTap(String letter) {
    if (_gameOver || _selectedLetters.length >= _currentWord.length) return;
    
    setState(() {
      _selectedLetters.add(letter);
    });
    
    _checkWord();
  }
  
  void _checkWord() {
    if (_selectedLetters.length == _currentWord.length) {
      String attemptedWord = _selectedLetters.join();
      
      if (attemptedWord == _currentWord) {
        // Correct word
        _onCorrectWord();
      } else {
        // Wrong word
        _onWrongWord();
      }
    }
  }
  
  void _onCorrectWord() {
    int basePoints = _currentWord.length * 10;
    int comboBonus = _combo * 5;
    int timeBonus = (_timeLeft ~/ 10) * 5;
    int levelMultiplier = _level;
    
    int points = (basePoints + comboBonus + timeBonus) * levelMultiplier;
    
    setState(() {
      _score += points;
      _combo++;
      _timeLeft = min(60, _timeLeft + 10); // Add time for correct answer
      
      if (_combo % 3 == 0) {
        _level++;
        _confettiController.play();
      }
    });
    
    _showSuccessAnimation();
    Future.delayed(Duration(milliseconds: 800), () {
      _generateNewWord();
    });
  }
  
  void _onWrongWord() {
    setState(() {
      _combo = 0;
      _selectedLetters.clear();
    });
    
    _showErrorAnimation();
  }
  
  void _loseLife() {
    setState(() {
      _lives--;
      _combo = 0;
      _timeLeft = 60;
    });
    
    if (_lives <= 0) {
      setState(() {
        _gameOver = true;
      });
    } else {
      _generateNewWord();
    }
  }
  
  void _useShuffle() {
    if (_shuffleCount > 0) {
      setState(() {
        _shuffleCount--;
        _scrambleWord();
        _selectedLetters.clear();
      });
    }
  }
  
  void _useFreeze() {
    if (_freezeCount > 0 && !_isFrozen) {
      setState(() {
        _freezeCount--;
        _isFrozen = true;
        _freezeTimeLeft = 10;
      });
    }
  }
  
  void _useBomb() {
    if (_bombCount > 0 && _selectedLetters.isNotEmpty) {
      setState(() {
        _bombCount--;
        _selectedLetters.removeLast();
      });
    }
  }
  
  void _showHint() {
    if (_hintCooldown == 0) {
      setState(() {
        _showHintUI = true;
        _hintCooldown = 30; // 30 second cooldown
      });
    }
  }
  
  void _showSuccessAnimation() {
    // Would typically use animations package for more complex animations
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfect! +${_combo > 1 ? ' Combo x$_combo!' : ''}'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _showErrorAnimation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Try again!'),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  Widget _buildLetterButton(String letter, int index) {
    bool isSelected = _selectedLetters.length > index && _selectedLetters[index] == letter;
    bool isHint = _hintLetters.contains(letter) && _showHintUI;
    
    return GestureDetector(
      onTap: () => _onLetterTap(letter),
      child: Container(
        margin: EdgeInsets.all(4),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : (isHint ? Colors.orange.shade100 : Colors.white),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isHint ? Colors.orange : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSelectedLetters() {
    return Container(
      height: 80,
      margin: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_currentWord.length, (index) {
          String letter = index < _selectedLetters.length ? _selectedLetters[index] : '';
          return Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildPowerUpButton(String icon, String count, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 20)),
            Text(count, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Header with score and stats
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text('SCORE', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(_score.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('LEVEL', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('$_level', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('COMBO', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('x$_combo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Lives and time
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.red),
                          SizedBox(width: 8),
                          Text('$_lives', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.timer, color: _isFrozen ? Colors.blue : Colors.green),
                          SizedBox(width: 8),
                          Text(
                            '$_timeLeft',
                            style: TextStyle(
                              fontSize: 18,
                              color: _timeLeft <= 10 ? Colors.red : Colors.black,
                            ),
                          ),
                          if (_isFrozen) ...[
                            SizedBox(width: 8),
                            Text('(Frozen: $_freezeTimeLeft)', style: TextStyle(color: Colors.blue)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Selected letters area
                _buildSelectedLetters(),
                
                SizedBox(height: 20),
                
                // Scrambled letters grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _scrambledLetters.length,
                    itemBuilder: (context, index) {
                      return _buildLetterButton(_scrambledLetters[index], index);
                    },
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Power-ups and controls
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPowerUpButton(
                        '🔀',
                        '$_shuffleCount',
                        _useShuffle,
                        Colors.purple.shade100,
                      ),
                      _buildPowerUpButton(
                        '❄️',
                        '$_freezeCount',
                        _useFreeze,
                        Colors.blue.shade100,
                      ),
                      _buildPowerUpButton(
                        '💣',
                        '$_bombCount',
                        _useBomb,
                        Colors.orange.shade100,
                      ),
                      GestureDetector(
                        onTap: _showHint,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _hintCooldown > 0 ? Colors.grey.shade300 : Colors.yellow.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text('💡', style: TextStyle(fontSize: 20)),
                              Text(
                                _hintCooldown > 0 ? '${_hintCooldown}s' : 'Hint',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Confetti animation
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 20,
            minBlastForce: 15,
          ),
          
          // Game over overlay
          if (_gameOver)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Game Over!',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Final Score: $_score',
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                        'Level Reached: $_level',
                        style: TextStyle(fontSize: 20, color: Colors.blue),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _startNewGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        ),
                        child: Text(
                          'Play Again',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}