// camera_controller.dart
import 'package:camera/camera.dart';
import 'package:chess_vision/timer_services.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';

class CameraControllerService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  TimerService? _timerService;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      _controller = CameraController(
        _cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
      rethrow;
    }
  }

  Widget buildPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: Text('Camera not initialized'));
    }

    return CameraPreview(_controller!);
  }

  void startCapturingAtInterval({
    required Duration duration,
    required Function(Uint8List) onImageCaptured,
  }) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    _timerService = TimerService();
    _timerService!.startTimer(
      interval: duration,
      callback: () async {
        await _captureImage(onImageCaptured);
      },
    );
  }

  Future<void> _captureImage(Function(Uint8List) onImageCaptured) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _controller!.takePicture();
      final Uint8List imageData = await photo.readAsBytes();
      onImageCaptured(imageData);
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  void stopCapturing() {
    _timerService?.stopTimer();
  }

  void dispose() {
    stopCapturing();
    _controller?.dispose();
  }
}
