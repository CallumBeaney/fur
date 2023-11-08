import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fur/singleton.dart';

// TO RUN LOCALLY: flutter run -d chrome
// flutter build web

const int _transitionRateInMs = 3500;
const int _fadeDurationInMs = 2000;

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
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: _transitionRateInMs), (timer) async {
      if (mounted) {
        setState(() {
          if (_currentIndex + 1 == locator<List<AssetImage>>().length) {
            locator<List<AssetImage>>().shuffle();
            _currentIndex = 0;
          } else {
            _currentIndex++;
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

  dynamic getImageWithBrightFadeTransition(int index) {
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

  Widget getImageWithMergeTransition(int index) {
    // print('$index -- ${locator<List<AssetImage>>()[index].assetName}');
    if (index == 0) {
      return Image(
        image: locator<List<AssetImage>>()[index],
        fit: BoxFit.cover,
      );
    } else {
      return Stack(
        fit: StackFit.expand, // the stack will expand to the sixe of the SizedBox hosting it below.
        children: [
          Opacity(
            /// Opacity gets a double from 0 - 1. You get the remainder of the transition rate e.g. where tick is 350 and transitionRate is 3500, (350ms MOD 3500ms) resolves to a remainder of 350, and then divide that result by the transitionRate so e.g. 350/3500 = 0.1. And 1 - 0.1 = 0.9, so the opacity will be 0.9 so this image image will be mostly solid. This way this top Opacity layer begins at 1 and goes down to 0.
            /// The opposite happens in the other opacity-wrapped image layer in this Stack.
            /// Because the transitionRate and the max duration of the timer correspond, the modulo operation is superfluous.
            opacity: 1 - (_timer!.tick % _transitionRateInMs) / _transitionRateInMs,
            child: Image(
              image: locator<List<AssetImage>>()[index - 1],
              fit: BoxFit.cover,
            ),
          ),
          Opacity(
            opacity: (_timer!.tick % _transitionRateInMs) / _transitionRateInMs,
            child: Image(
              image: locator<List<AssetImage>>()[index],
              fit: BoxFit.cover,
            ),
          ),
        ],
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
            duration: const Duration(milliseconds: _fadeDurationInMs),
            child: SizedBox(
              key: ValueKey<int>(_currentIndex),
              // These make the image fullscreen, and handles user resizing for you.
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: getImageWithMergeTransition(_currentIndex),
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
