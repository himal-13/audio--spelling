import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Uncomment for real persistence

// New: Define a complete Story Mode
class StoryMode {
  final int levelNumber;
  final String title;
  final List<StoryChapter> chapters;
  final List<Color> backgroundGradientColors; // For unique background per story

  StoryMode({
    required this.levelNumber,
    required this.title,
    required this.chapters,
    required this.backgroundGradientColors,
  });

  static List<StoryMode> get allStoryModes => [
        StoryMode(
          levelNumber: 1,
          title: "The Whispering Woods",
          backgroundGradientColors: [Color.fromARGB(255, 89, 0, 158), Color(0xFF5B6DF0)],
          chapters: [
            StoryChapter(
              narrative: "Our adventure begins in a cozy little cottage nestled deep within the Whispering Woods. A young explorer named Lily dreams of discovering ancient secrets. Her first quest is to find a magical ______. She needs it to guide her through the dense forest.",
              correctWord: "MAP",
              hintText: "A guide for navigation, often made of paper.",
              imageUrl: "https://placehold.co/600x200/59009E/FFFFFF?text=Whispering+Woods", // Placeholder image
            ),
            StoryChapter(
              narrative: "With the ancient map in hand, Lily ventured deeper into the woods. The path was winding, and shadows danced around her. Suddenly, she heard a soft rustling. It was a tiny, lost ______. Its long ears twitched nervously.",
              correctWord: "RABBIT",
              hintText: "A small, furry animal known for hopping.",
              imageUrl: "https://placehold.co/600x200/59009E/FFFFFF?text=Lost+Rabbit", // Placeholder image
            ),
            StoryChapter(
              narrative: "Lily helped the rabbit find its way back to its burrow. As a thank you, the rabbit showed her a hidden grove where a sparkling, mystical ______ bloomed under the moonlight. Its petals glowed softly.",
              correctWord: "FLOWER",
              hintText: "A beautiful, often fragrant, part of a plant.",
              imageUrl: "https://placehold.co/600x200/59009E/FFFFFF?text=Mystical+Grove", // Placeholder image
            ),
            StoryChapter(
              narrative: "The mystical flower glowed, illuminating a secret passage. Lily knew this was her chance to uncover the ancient secrets. She bravely stepped into the darkness, ready for the next ______. She knew it wouldn't be easy.",
              correctWord: "CHALLENGE",
              hintText: "A difficult task or problem that tests abilities.",
              imageUrl: "https://placehold.co/600x200/59009E/FFFFFF?text=Secret+Passage",
            ),
            StoryChapter(
              narrative: "Congratulations, explorer! You have completed the first part of Lily's adventure, a true ______. You've shown great courage and wisdom. More stories await!",
              correctWord: "QUEST",
              hintText: "A long and arduous search for something.",
              imageUrl: "https://placehold.co/600x200/59009E/FFFFFF?text=Adventure+Complete",
            ),
          ],
        ),
        StoryMode(
          levelNumber: 2,
          title: "The Crystal Caves",
          backgroundGradientColors: [Color(0xFF00796B), Color(0xFF00BFA5)], // Greenish-blue gradient
          chapters: [
            StoryChapter(
              narrative: "Deep beneath the earth, the Crystal Caves shimmered with untold beauty. Our new hero, Alex, sought the legendary Crystal of Wisdom. To enter, he needed to identify the glowing ______ embedded in the cave wall. It sparkled with inner light.",
              correctWord: "GEM",
              hintText: "A precious stone, often cut and polished.",
              imageUrl: "https://placehold.co/600x200/00796B/FFFFFF?text=Crystal+Caves",
            ),
            StoryChapter(
              narrative: "Inside, the path was treacherous. Alex had to cross a vast ______ using only a fragile, ancient structure. The drop below was dizzying.",
              correctWord: "CHASM",
              hintText: "A deep fissure in the earth, rock, or other surface.",
              imageUrl: "https://placehold.co/600x200/00796B/FFFFFF?text=Vast+Chasm",
            ),
            StoryChapter(
              narrative: "He encountered a riddle-speaking guardian. To pass, he had to spell the word for a source of light he carried in the darkness, a burning ______. It flickered, casting eerie shadows.",
              correctWord: "TORCH",
              hintText: "A portable light source, typically a stick with combustible material.",
              imageUrl: "https://placehold.co/600x200/00796B/FFFFFF?text=Riddle+Guardian",
            ),
            StoryChapter(
              narrative: "Finally, Alex stood before the Crystal of Wisdom, guarded by an ancient ______. Its scales gleamed, and smoke curled from its nostrils. It was a fearsome sight.",
              correctWord: "DRAGON",
              hintText: "A mythical monster resembling a giant reptile, typically winged and scaly.",
              imageUrl: "https://placehold.co/600x200/00796B/FFFFFF?text=Crystal+Dragon",
            ),
            StoryChapter(
              narrative: "With courage and wit, Alex outsmarted the dragon and claimed the Crystal. His journey through the caves was a true ______. He had overcome every obstacle.",
              correctWord: "TRIUMPH",
              hintText: "A great victory or achievement.",
              imageUrl: "https://placehold.co/600x200/00796B/FFFFFF?text=Triumph+Achieved",
            ),
          ],
        ),
        StoryMode(
          levelNumber: 3,
          title: "The Starship Odyssey",
          backgroundGradientColors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)], // Dark blue to light blue
          chapters: [
            StoryChapter(
              narrative: "Far in the future, Captain Eva piloted her starship, the 'Odyssey', through the vast expanse of space. Their mission: to reach a newly discovered ______. It was a world never before seen by humans.",
              correctWord: "PLANET",
              hintText: "A large celestial body that orbits a star.",
              imageUrl: "https://placehold.co/600x200/2C3E50/FFFFFF?text=Starship+Odyssey",
            ),
            StoryChapter(
              narrative: "Suddenly, an alarm blared! They were caught in a dangerous asteroid ______. Rocks of all sizes hurtled towards them.",
              correctWord: "FIELD",
              hintText: "An area containing many scattered objects.",
              imageUrl: "https://placehold.co/600x200/2C3E50/FFFFFF?text=Asteroid+Field",
            ),
            StoryChapter(
              narrative: "Eva expertly navigated through the debris, but their main engine needed a quick ______. Sparks flew as the engineers worked frantically.",
              correctWord: "REPAIR",
              hintText: "The act of fixing something that is damaged.",
              imageUrl: "https://placehold.co/600x200/2C3E50/FFFFFF?text=Engine+Repair",
            ),
            StoryChapter(
              narrative: "They landed on the new planet, a vibrant world filled with alien ______. Strange plants glowed and pulsed with light.",
              correctWord: "FLORA",
              hintText: "The plants of a particular region, habitat, or geological period.",
              imageUrl: "https://placehold.co/600x200/2C3E50/FFFFFF?text=Alien+Flora",
            ),
            StoryChapter(
              narrative: "The mission was a success! Eva and her crew had expanded humanity's knowledge of the ______. Their journey was a monumental achievement.",
              correctWord: "UNIVERSE",
              hintText: "All existing matter and space considered as a whole.",
              imageUrl: "https://placehold.co/600x200/2C3E50/FFFFFF?text=Cosmic+Discovery",
            ),
          ],
        ),
      ];
}

// StoryChapter class (no changes needed here, it's correct)
class StoryChapter {
  final String narrative;
  final String correctWord;
  final String hintText;
  final String? imageUrl; // Optional image for the chapter

  StoryChapter({
    required this.narrative,
    required this.correctWord,
    required this.hintText,
    this.imageUrl,
  });
}


class StoryModeGame extends StatefulWidget {
  const StoryModeGame({super.key});

  @override
  State<StoryModeGame> createState() => _StoryModeGameState();
}

class _StoryModeGameState extends State<StoryModeGame> {
  int? _selectedStoryModeNumber; // Tracks the selected story mode (level)
  late StoryMode _currentStoryMode; // The currently active story mode object
  int _currentChapterIndex = 0; // Index within the selected story mode's chapters

  final TextEditingController _textController = TextEditingController();
  String? _currentHintText; // Stores the hint text to display
  String? _feedbackMessage; // For correct/incorrect feedback

  // Set to store completed story modes
  Set<int> _completedStoryModes = {};

  @override
  void initState() {
    super.initState();
    _loadProgress(); // Load saved progress when the widget initializes
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Simulates loading progress from storage (e.g., SharedPreferences)
  void _loadProgress() async {
    // For actual persistence, uncomment the following:
    // final prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   _completedStoryModes = (prefs.getStringList('storyModeCompletedLevels') ?? [])
    //       .map(int.parse)
    //       .toSet();
    // });

    setState(() {
      // For initial run, ensure at least level 1 is accessible.
      // In a real app, you'd load from SharedPreferences.
      if (_completedStoryModes.isEmpty) {
        _completedStoryModes.add(0); // Add a dummy "level 0" to unlock level 1
      }
    });
  }

  // Simulates saving progress to storage (e.g., SharedPreferences)
  void _saveProgress() async {
    // For actual persistence, uncomment the following:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setStringList(
    //     'storyModeCompletedLevels', _completedStoryModes.map((e) => e.toString()).toList());
  }

  // Function to start a specific Story Mode
  void _startStoryMode(int storyModeNumber) {
    final storyMode = StoryMode.allStoryModes.firstWhere((sm) => sm.levelNumber == storyModeNumber);
    setState(() {
      _selectedStoryModeNumber = storyModeNumber;
      _currentStoryMode = storyMode;
      _currentChapterIndex = 0; // Start from the first chapter of the selected story
      _textController.clear(); // Clear text field for new story
      _currentHintText = null; // Clear hint
      _feedbackMessage = null; // Clear feedback
      _startChapter(); // Load the first chapter
    });
  }

  void _startChapter() {
    setState(() {
      _textController.clear(); // Clear text field for new chapter
      _currentHintText = null; // Clear hint
      _feedbackMessage = null; // Clear feedback

      if (_currentChapterIndex < _currentStoryMode.chapters.length) {
        // Chapter loaded
      } else {
        // All chapters completed for the current story mode
        _completedStoryModes.add(_selectedStoryModeNumber!); // Mark current story mode as completed
        _saveProgress(); // Save progress
        _showStoryCompletedDialog();
      }
    });
  }

  void _submitWord() {
    final currentChapter = _currentStoryMode.chapters[_currentChapterIndex];
    final enteredWord = _textController.text.trim().toUpperCase(); // Trim and uppercase for comparison

    if (enteredWord == currentChapter.correctWord.toUpperCase()) {
      setState(() {
        _feedbackMessage = "Correct!";
      });
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _currentChapterIndex++;
        });
        _startChapter(); // Load next chapter or show completion dialog
      });
    } else {
      setState(() {
        _feedbackMessage = "Try again!";
      });
      // Optionally clear the text field for another attempt
      // _textController.clear();
    }
  }

  void _showHint() {
    setState(() {
      _currentHintText = _currentStoryMode.chapters[_currentChapterIndex].hintText;
    });
  }

  void _resetInput() {
    setState(() {
      _textController.clear();
      _feedbackMessage = null;
      _currentHintText = null;
    });
  }

  void _showStoryCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: const Text('Story Completed!', style: TextStyle(color: Color.fromARGB(255, 89, 0, 158), fontWeight: FontWeight.bold)),
          content: Text('You\'ve reached the end of "${_currentStoryMode.title}". Great job!', style: const TextStyle(color: Colors.black87)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                setState(() {
                  _selectedStoryModeNumber = null; // Go back to story mode selection
                });
              },
              child: const Text('Back to Story Modes', style: TextStyle(color: Color.fromARGB(255, 89, 0, 158), fontWeight: FontWeight.bold)),
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
        backgroundColor: const Color.fromARGB(255, 89, 0, 158), // Default Story Mode button color
        title: Text(
          _selectedStoryModeNumber == null ? 'Select Story' : 'Story Mode: ${_currentStoryMode.title}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (_selectedStoryModeNumber != null) {
              setState(() {
                _selectedStoryModeNumber = null; // Go back to story mode selection
              });
            } else {
              Navigator.pop(context); // Go back to PlayPage
            }
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _selectedStoryModeNumber == null
                ? [const Color.fromARGB(255, 89, 0, 158), const Color(0xFF5B6DF0)] // Default gradient for selection screen
                : _currentStoryMode.backgroundGradientColors, // Story-specific gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _selectedStoryModeNumber == null
              ? _buildStoryModeSelection()
              : _buildStoryGameplay(),
        ),
      ),
    );
  }

  // Builds the story mode selection screen
  Widget _buildStoryModeSelection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Choose Your Story',
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
            itemCount: StoryMode.allStoryModes.length,
            itemBuilder: (context, index) {
              final storyMode = StoryMode.allStoryModes[index];
              // Check if the previous story mode is completed to unlock this one
              final bool isLocked = !_completedStoryModes.contains(storyMode.levelNumber - 1);
              final bool isCompleted = _completedStoryModes.contains(storyMode.levelNumber);

              return _buildStoryModeButton(storyMode, isLocked, isCompleted);
            },
          ),
        ),
      ],
    );
  }

  // Builds a single story mode selection button
  Widget _buildStoryModeButton(StoryMode storyMode, bool isLocked, bool isCompleted) {
    return InkWell(
      onTap: isLocked ? null : () => _startStoryMode(storyMode.levelNumber), // Disable tap if locked
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
                : (isCompleted ? Colors.green.shade700 : storyMode.backgroundGradientColors.first), // Use story's primary color
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLocked ? Icons.lock : (isCompleted ? Icons.check_circle : Icons.menu_book),
              size: 48,
              color: isLocked ? Colors.white : (isCompleted ? Colors.white : storyMode.backgroundGradientColors.first),
            ),
            const SizedBox(height: 12),
            Text(
              storyMode.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isLocked ? Colors.white : (isCompleted ? Colors.white : const Color(0xFF5B6DF0)),
                fontSize: 20,
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

  // Builds the main story gameplay screen
  Widget _buildStoryGameplay() {
    if (_currentChapterIndex >= _currentStoryMode.chapters.length) {
      // This state should ideally be handled by _showStoryCompletedDialog
      return const Center(child: CircularProgressIndicator());
    }

    final currentChapter = _currentStoryMode.chapters[_currentChapterIndex];
    final totalChapters = _currentStoryMode.chapters.length;
    final progress = (_currentChapterIndex + 1) / totalChapters; // Calculate progress

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Level Progress Indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
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
                    'Chapter ${_currentChapterIndex + 1} of $totalChapters',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (currentChapter.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    currentChapter.imageUrl!,
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            Text(
              currentChapter.narrative,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),
            // User input for the missing word
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type the missing word...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.words, // Capitalize first letter
              onSubmitted: (_) => _submitWord(), // Allow submitting with keyboard enter
            ),
            const SizedBox(height: 20),
            if (_feedbackMessage != null)
              Text(
                _feedbackMessage!,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _feedbackMessage == "Correct!" ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.send,
                  label: 'Submit',
                  color: Colors.blueAccent,
                  onTap: _submitWord,
                ),
                _buildActionButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  color: Colors.redAccent,
                  onTap: _resetInput,
                ),
                _buildActionButton(
                  icon: Icons.lightbulb_outline,
                  label: 'Hint',
                  color: Colors.yellow.shade700,
                  onTap: _showHint,
                ),
              ],
            ),
            if (_currentHintText != null)
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper to build action buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
