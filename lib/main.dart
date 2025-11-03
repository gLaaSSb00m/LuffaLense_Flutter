import 'package:flutter/material.dart';
import 'second_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'LuffaLense',
        home: HomePage(),
        debugShowCheckedModeBanner: false,
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  // Control button slide-in animation
  double _buttonValue = 0.0;

  @override
  void initState() {
    super.initState();

    // Logo floating animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.05),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start button slide-in after short delay
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        setState(() => _buttonValue = 1.0);
      }
    });
  }

  // THIS IS THE KEY: Reset animation when coming back
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _buttonValue = 0.0; // Reset
        });
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) setState(() => _buttonValue = 1.0);
        });
      }
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
      backgroundColor: const Color(0xFFF7DABF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Frame.png', fit: BoxFit.cover),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Floating Logo
                    SlideTransition(
                      position: _offsetAnimation,
                      child: Image.asset('assets/images/LuffaLense.png', width: 250),
                    ),
                    const SizedBox(height: 30),

                    // BUTTON: Slides in from left with delay — EVERY TIME
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: _buttonValue),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        final offset = Offset(-400 * (1 - value), 0);
                        return Transform.translate(
                          offset: offset,
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 800),
                              pageBuilder: (_, __, ___) => const SecondPage(),
                              transitionsBuilder: (_, animation, __, child) {
                                final slide = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                                    .chain(CurveTween(curve: Curves.easeOutCubic))
                                    .animate(animation);
                                return SlideTransition(position: slide, child: child);
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 5,
                        ),
                        child: Ink(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF508D44), Color(0xFFABE061)]),
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          child: Container(
                            width: 250,
                            height: 60,
                            alignment: Alignment.center,
                            child: const Text(
                              'Get Started',
                              style: TextStyle(fontSize: 24, color: Colors.white),
                            ),
                          ),
                        ),
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