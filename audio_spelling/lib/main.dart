import 'package:audio_spelling/play_page.dart';
import 'package:flutter/material.dart';

void main() async{
    WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter widgets are initialized
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spelling Test App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SpellingTestScreen(),
    );
  }
}

class SpellingTestScreen extends StatelessWidget {
  const SpellingTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A1B9A), // Purple background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "SPELLING TEST" button/container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 10.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107), // Yellow background
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Text(
                  'SPELLING\nTEST',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto', // Assuming a similar font
                    fontSize: 40,
                    fontWeight: FontWeight.w900, // Extra bold
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Pencil image
              Transform.rotate(
                angle: 0.5, // Slight rotation for a dynamic look
                child: Image.asset(
                  'assets/images/pencil.png', // Ensure you have a pencil image in your assets
                  height: 160,
                ),
              ),
              const SizedBox(height: 40),

              // "START" button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlayPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Green background
                  minimumSize: const Size(double.infinity, 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  shadowColor: Colors.black.withOpacity(0.4),
                  elevation: 5,
                ),
                child: const Text(
                  'START',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // "OPTIONS" button
              ElevatedButton(
                onPressed: () {
                  // Handle OPTIONS button press
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800), // Orange background
                  minimumSize: const Size(double.infinity, 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  shadowColor: Colors.black.withOpacity(0.4),
                  elevation: 5,
                ),
                child: const Text(
                  'OPTIONS',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Spacing for the bottom question mark icon
              const Spacer(),

              // Question mark icon
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    // Handle help icon press
                  },
                ),
              ),

              const SizedBox(height: 20), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
