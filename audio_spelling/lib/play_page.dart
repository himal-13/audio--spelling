import 'package:audio_spelling/pages/classic_spelling.dart';
import 'package:audio_spelling/pages/story_mode.dart';
import 'package:audio_spelling/pages/timed_challenge.dart';
import 'package:audio_spelling/pages/word_search.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  // State variables for settings
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _areNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load settings when the widget initializes
  }

  // Method to load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
      _isMusicEnabled = prefs.getBool('isMusicEnabled') ?? true;
      _areNotificationsEnabled = prefs.getBool('areNotificationsEnabled') ?? true;
    });
  }

  // Method to save settings to SharedPreferences
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B6DF0),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showSettingsBottomSheet(context);
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildTopBackground(context),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    'Spelling Game',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildGameModeButton(
                          context,
                          'Classic Spelling',
                          Icons.school_outlined,
                          const Color(0xFFFF9F40),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ClassicalSpellingGame(),
                              ),
                            );
                          },
                        ),
                        _buildGameModeButton(
                          context,
                          'Word Search',
                          Icons.search,
                          const Color(0xFF4AC2D6),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WordSearchGame(),
                              ),
                            );
                          },
                        ),
                        _buildGameModeButton(
                          context,
                          'Timed Challenge',
                          Icons.timer_outlined,
                          const Color.fromARGB(255, 19, 184, 0),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TimedSpellingChallenge(),
                              ),
                            );
                          },
                        ),
                        _buildGameModeButton(
                          context,
                          'Story Mode',
                          Icons.menu_book,
                          const Color.fromARGB(255, 89, 0, 158),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StoryModeGame(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBackground(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: const BoxDecoration(
        color: Color(0xFF5B6DF0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.book, color: Colors.white, size: 80),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModeButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    final VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
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

  // Method to show settings bottom sheet
  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return StatefulBuilder( // Use StatefulBuilder to update the bottom sheet's state
          builder: (BuildContext context, StateSetter setStateInsideBottomSheet) {
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
                    'Settings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const Divider(height: 30, thickness: 1),
                  SwitchListTile(
                    title: const Text(
                      'Sound Volume',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    secondary: const Icon(Icons.volume_up, color: Color(0xFF5B6DF0)),
                    value: _isSoundEnabled,
                    onChanged: (bool value) {
                      setStateInsideBottomSheet(() {
                        _isSoundEnabled = value;
                      });
                      _saveSetting('isSoundEnabled', value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Background Music',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    secondary: const Icon(Icons.music_note, color: Color(0xFF5B6DF0)),
                    value: _isMusicEnabled,
                    onChanged: (bool value) {
                      setStateInsideBottomSheet(() {
                        _isMusicEnabled = value;
                      });
                      _saveSetting('isMusicEnabled', value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Notifications',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    secondary: const Icon(Icons.notifications, color: Color(0xFF5B6DF0)),
                    value: _areNotificationsEnabled,
                    onChanged: (bool value) {
                      setStateInsideBottomSheet(() {
                        _areNotificationsEnabled = value;
                      });
                      _saveSetting('areNotificationsEnabled', value);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
  // Kept for reference if other non-switch options are added later
}
