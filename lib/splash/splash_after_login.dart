import 'package:flutter/material.dart';
import 'dart:async';
import '../pages/home_page.dart';

class SplashAfterLogin extends StatefulWidget {
  const SplashAfterLogin({super.key});

  @override
  State<SplashAfterLogin> createState() => _SplashAfterLoginState();
}

class _SplashAfterLoginState extends State<SplashAfterLogin>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  String _visibleText = "";
  final String _fullText = "Glamora";
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();

    //  G harfi büyümesi (1.5 sn ayarladım değişebilir belki)
    _logoController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _logoScale = Tween<double>(begin: 0.2, end: 1.0)
        .animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOutExpo));
    _logoController.forward();

    //  1.5 sn sonra harf harf yazı çıkmaya başlar
    Future.delayed(const Duration(milliseconds: 1500), () {
      int index = 0;
      _textTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
        if (index < _fullText.length) {
          setState(() {
            _visibleText += _fullText[index];
          });
          index++;
        } else {
          timer.cancel();
        }
      });
    });

    //  3.5 sn sonra HomePage'e geç
    Future.delayed(const Duration(milliseconds: 3500), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1739), // gece mavisi
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //  Askılı G logosu küçükten büyür
            ScaleTransition(
              scale: _logoScale,
              child: Image.asset(
                'assets/images/glamora_harf_logo.png',
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 35),

            //  Glamora yazısı harf harf çıkar
            if (_visibleText.isNotEmpty)
              Text(
                _visibleText,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                  letterSpacing: 1.3,
                  color: Color(0xFFF6EFD9),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
