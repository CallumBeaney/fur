import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fur/singleton.dart';

// TO RUN LOCALLY: flutter run -d chrome
// flutter build web

const int _imageTransitionRateInMilliseconds = 3500;
const int _imageFadeDurationInMilliseconds = 2250;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Stopwatch timer = Stopwatch()..start();
  await setupSingleton();
  timer.stop();
  // print('\n\tElapsed time for setup\n: ${timer.elapsed}');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // const bool userOnMobileOrDesktop = kIsWeb; // this is a global constant defined by framework

    return MaterialApp(
      title: 'FUR by KOJI KITAGAWA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FUR by KOJI KITAGAWA'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    /// This determines how often the images change.
    /// I am simply too lazy to instigate a proper cubit-based state machine for such a simple program and I'm sorry but also not
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: _imageTransitionRateInMilliseconds),
        (timer) async {
      if (mounted) {
        setState(() {
          if (_currentIndex + 1 == locator<List<AssetImage>>().length) {
            locator<List<AssetImage>>().shuffle();
            _currentIndex = 0;
          } else {
            _currentIndex = _currentIndex + 1;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  dynamic getImage(int index) {
    if (index == 0) {
      /// first image ever loaded/image in sequence
      return Image(image: locator<List<AssetImage>>()[index], fit: BoxFit.cover);
    } else {
      return FadeInImage(
        placeholder: locator<List<AssetImage>>()[index - 1],
        image: locator<List<AssetImage>>()[index],
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AnimatedSwitcher(
            /// this code determines the fading behaviour
            duration: const Duration(milliseconds: _imageFadeDurationInMilliseconds),
            child: SizedBox(
              key: ValueKey<int>(_currentIndex),
              // These make the image fullscreen, and handles user resizing for you.
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: getImage(_currentIndex),
            ),
          ),
          const Positioned(
            bottom: 30.0,
            right: 40.0,
            child: Text(
              'FUR\nKOJI KITAGAWA',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15.0,
                color: Color.fromARGB(255, 230, 230, 230),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
