class WordPuzzle {
  final String word;
  final String hint;
  final String category;
  final List<String> scrambledLetters;

  WordPuzzle({
    required this.word,
    required this.hint,
    required this.category,
  }) : scrambledLetters = (word.split('')..shuffle());

  bool isCorrect(List<String> currentOrder) {
    return currentOrder.join() == word;
  }
}

class WordsRepository {
  static List<WordPuzzle> getQuickPlayWords() {
    return [
      // Science Words
      WordPuzzle(word: 'GRAVITY', hint: 'Apple fall reason', category: 'Science'),
      WordPuzzle(word: 'CELL', hint: 'Life basic unit', category: 'Science'),
      WordPuzzle(word: 'ATOM', hint: 'Matter tiny piece', category: 'Science'),
      WordPuzzle(word: 'GENE', hint: 'DNA trait carrier', category: 'Science'),
      WordPuzzle(word: 'ORBIT', hint: 'Planet path circle', category: 'Science'),
      WordPuzzle(word: 'FORCE', hint: 'Push or pull', category: 'Science'),
      WordPuzzle(word: 'WAVES', hint: 'Light sound travel', category: 'Science'),
      WordPuzzle(word: 'SPACE', hint: 'Star empty area', category: 'Science'),

      // Profession Words
      WordPuzzle(word: 'DOCTOR', hint: 'Medical treatment person', category: 'Professions'),
      WordPuzzle(word: 'TEACHER', hint: 'Knowledge sharer', category: 'Professions'),
      WordPuzzle(word: 'ARTIST', hint: 'Creative work maker', category: 'Professions'),
      WordPuzzle(word: 'LAWYER', hint: 'Legal case handler', category: 'Professions'),
      WordPuzzle(word: 'CHEF', hint: 'Food preparation expert', category: 'Professions'),
      WordPuzzle(word: 'NURSE', hint: 'Patient care giver', category: 'Professions'),
      WordPuzzle(word: 'ACTOR', hint: 'Role performer', category: 'Professions'),
      WordPuzzle(word: 'WRITER', hint: 'Story creator', category: 'Professions'),

      // Geography Words
      WordPuzzle(word: 'RIVER', hint: 'Flowing water body', category: 'Geography'),
      WordPuzzle(word: 'MOUNTAIN', hint: 'High land form', category: 'Geography'),
      WordPuzzle(word: 'DESERT', hint: 'Dry sandy area', category: 'Geography'),
      WordPuzzle(word: 'ISLAND', hint: 'Water surrounded land', category: 'Geography'),
      WordPuzzle(word: 'FOREST', hint: 'Tree dense area', category: 'Geography'),
      WordPuzzle(word: 'OCEAN', hint: 'Large sea body', category: 'Geography'),
      WordPuzzle(word: 'VALLEY', hint: 'Hill low area', category: 'Geography'),
      WordPuzzle(word: 'BEACH', hint: 'Sand water meeting', category: 'Geography'),

      // History Words
      WordPuzzle(word: 'KING', hint: 'Royal ruler male', category: 'History'),
      WordPuzzle(word: 'WAR', hint: 'Armed conflict', category: 'History'),
      WordPuzzle(word: 'EMPIRE', hint: 'Large ruled territory', category: 'History'),
      WordPuzzle(word: 'TRIBE', hint: 'Ancient community', category: 'History'),
      WordPuzzle(word: 'RUINS', hint: 'Ancient remains', category: 'History'),
      WordPuzzle(word: 'QUEEN', hint: 'Royal ruler female', category: 'History'),
      WordPuzzle(word: 'CASTLE', hint: 'Fortified building', category: 'History'),
      WordPuzzle(word: 'BATTLE', hint: 'Military fight', category: 'History'),

      // Technology Words
      WordPuzzle(word: 'CODE', hint: 'Programming instructions', category: 'Technology'),
      WordPuzzle(word: 'APP', hint: 'Mobile software', category: 'Technology'),
      WordPuzzle(word: 'DATA', hint: 'Information pieces', category: 'Technology'),
      WordPuzzle(word: 'WIFI', hint: 'Wireless internet', category: 'Technology'),
      WordPuzzle(word: 'CLOUD', hint: 'Online storage', category: 'Technology'),
      WordPuzzle(word: 'EMAIL', hint: 'Electronic message', category: 'Technology'),
      WordPuzzle(word: 'VIDEO', hint: 'Moving images', category: 'Technology'),
      WordPuzzle(word: 'PHONE', hint: 'Communication device', category: 'Technology'),
    ];
  }

  static List<WordPuzzle> getRandomPuzzles(int count) {
    final allWords = getQuickPlayWords();
    allWords.shuffle();
    return allWords.take(count).toList();
  }
}