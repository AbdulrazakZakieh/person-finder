import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:person_finder/PersonImageUpload.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final List<PageViewModel> pages = [
    PageViewModel(
      title: "Welcome to Person Finder",
      body: "Find a person in an image",
      image: Image.asset(
        'assets/images/logo.png',
        alignment: Alignment.center,
        fit: BoxFit.scaleDown,
        height: 150,
        scale: 0.5,
      ),
    ),
    PageViewModel(
      title: "Step 1",
      body: "Upload an image of the person you want to find",
      image: Icon(Icons.upload_file),
    ),
    PageViewModel(
      title: "Step 2",
      body:
          "Upload an image or take a photo to find the person you are looking for",
      image: Icon(Icons.search_off_rounded),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Person Finder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade900),
          useMaterial3: true,
        ),
        home: Builder(
            builder: (context) => IntroductionScreen(
                  pages: pages,
                  onDone: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PersonImageUpload()),
                    );
                  },
                  onSkip: () {},
                  showSkipButton: true,
                  skip: const Text('Skip'),
                  done: const Text('Done'),
                  next: const Icon(Icons.arrow_forward),
                  dotsDecorator: DotsDecorator(
                    size: const Size(10.0, 10.0),
                    color: Colors.grey,
                    activeColor: Colors.blue,
                    activeSize: const Size(22.0, 10.0),
                    activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                )));
  }
}
