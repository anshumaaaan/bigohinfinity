// Project Structure:
// - lib/
//   - main.dart (main app entry point)
//   - camera_screen.dart (camera UI screen)
//   - camera_controller.dart (camera functionality)
//   - image_storage.dart (storage functionality)
//   - timer_service.dart (timer functionality)

// main.dart
import 'package:chess_vision/cameraScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Interval Capture',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CameraScreen(),
    );
  }
}
