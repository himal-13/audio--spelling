import 'package:flutter/material.dart';


class PlayPage extends StatelessWidget {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5B6DF0),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
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
                        ),
                        _buildGameModeButton(
                          context,
                          'Word Search',
                          Icons.search,
                          const Color(0xFF4AC2D6),
                        ),
                        _buildGameModeButton(
                          context,
                          'Timed Challenge',
                          Icons.timer_outlined,
                          const Color.fromARGB(255, 19, 184, 0),
                        ),
                        _buildGameModeButton(
                          context,
                          'Story Mode',
                          Icons.menu_book,
                          const Color.fromARGB(255, 89, 0, 158),
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
            // The image had a custom icon with a graduation hat. This is a placeholder.
            // You can replace this with an Image.asset for a custom icon.
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
  ) {
    return InkWell(
      onTap: () {
        // Handle game mode selection
        // For example: Navigator.push(context, MaterialPageRoute(builder: (_) => GameModeScreen(title)));
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
}
