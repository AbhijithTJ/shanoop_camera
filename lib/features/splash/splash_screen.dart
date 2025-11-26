import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vintage_fiesta/main.dart';
import 'package:vintage_fiesta/features/template_overlay/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _iconSlideAnimation;
  late Animation<double> _iconFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _taglineSlideAnimation;
  late Animation<double> _taglineFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Icon Animation
    _iconFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _iconSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Title Animation
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );
    _titleSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );

    // Tagline Animation
    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );
    _taglineSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate to main camera screen after delay
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryColor,
              AppConstants.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              FadeTransition(
                opacity: _iconFadeAnimation,
                child: SlideTransition(
                  position: _iconSlideAnimation,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20), // Add some padding inside the container
                    child: Image.asset(
                      'assets/logo_and_appIcon/app_icon.png',
                      fit: BoxFit.contain, // Ensure the image fits within the container
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // App name
              FadeTransition(
                opacity: _titleFadeAnimation,
                child: SlideTransition(
                  position: _titleSlideAnimation,
                  child: const Text(
                    'Vintage Fiesta',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              FadeTransition(
                opacity: _taglineFadeAnimation,
                child: SlideTransition(
                  position: _taglineSlideAnimation,
                  child: Text(
                    'Your memories, stylized.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}