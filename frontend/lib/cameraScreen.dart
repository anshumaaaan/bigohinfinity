// camera_screen.dart
import 'package:chess_vision/camera_controller_services.dart';
import 'package:chess_vision/chess_peaces%20algo.dart';
import 'package:chess_vision/image_storeage_services.dart';
import 'package:chess_vision/tflite_services.dart' show TFLiteService;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:async';
import 'image_processor.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraControllerService _cameraController;
  late ImageStorage _imageStorage;
  late ImageProcessor _imageProcessor;
  late TFLiteService _tfliteService;
  bool _isInitialized = false;
  bool _isCapturing = false;
  int _capturedCount = 0;
  late Size _screenSize;
  late double _squareSize;
  late Offset _squarePosition;
  bool _isModelLoaded = false;
  List<String>? _modelOutput;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _imageStorage = ImageStorage();
    _imageProcessor = ImageProcessor();
    _tfliteService = TFLiteService();
    _initServices();
  }

  Future<void> _initServices() async {
    await _initCamera();
    await _initTFLite();
  }

  Future<void> _initTFLite() async {
    try {
      await _tfliteService.initialize();
      setState(() {
        _isModelLoaded = _tfliteService.isInitialized;
      });
      print('TFLite model initialized: $_isModelLoaded');
    } catch (e) {
      print('Error initializing TFLite model: $e');
      setState(() {
        _isModelLoaded = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
    // Calculate square size (80% of the smallest dimension)
    _squareSize =
        (_screenSize.width < _screenSize.height
            ? _screenSize.width
            : _screenSize.height) *
        0.8;

    // Center the square
    _squarePosition = Offset(
      (_screenSize.width - _squareSize) / 2,
      (_screenSize.height - _squareSize - 150) /
          2, // Adjust for bottom controls
    );
  }

  Future<void> _initCamera() async {
    _cameraController = CameraControllerService();
    await _cameraController.initialize();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _toggleCapturing() {
    setState(() {
      _isCapturing = !_isCapturing;
    });

    if (_isCapturing) {
      _startCapturing();
    } else {
      _stopCapturing();
    }
  }

  void _startCapturing() {
    _cameraController.startCapturingAtInterval(
      duration: const Duration(milliseconds: 500),
      onImageCaptured: (Uint8List imageData) async {
        // Process the image - crop to square and divide
        final List<List<Uint8List>> processedImages = await _imageProcessor
            .processImage(imageData, _squarePosition, _squareSize);

        // Store the image grid
        _imageStorage.storeImageGrid(processedImages);
        setState(() {
          _capturedCount = _imageStorage.imageCount;
        });
      },
    );
  }

  void _stopCapturing() {
    _cameraController.stopCapturing();
  }

  void _resetCapturing() {
    setState(() {
      _capturedCount = 0;
      _isCapturing = false;
    });
    _imageStorage.clearImages();
    _cameraController.stopCapturing();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _tfliteService.dispose();
    super.dispose();
  }

  // Show debug information about the comparison
  void _showDebugInfo(bool isSimilar) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSimilar
              ? 'Image skipped (similar to previous)'
              : 'New image captured',
          style: TextStyle(color: isSimilar ? Colors.yellow : Colors.green),
        ),
        duration: const Duration(milliseconds: 500),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Interval Capture'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCapturing,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Camera preview
                _cameraController.buildPreview(),

                // Square overlay
                Positioned(
                  left: _squarePosition.dx,
                  top: _squarePosition.dy,
                  child: Container(
                    width: _squareSize,
                    height: _squareSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2.0),
                    ),
                  ),
                ),

                // Grid lines (8x8)
                Positioned(
                  left: _squarePosition.dx,
                  top: _squarePosition.dy,
                  child: CustomPaint(
                    size: Size(_squareSize, _squareSize),
                    painter: GridPainter(8, 8),
                  ),
                ),

                // TF Lite status indicator
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isModelLoaded ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _isModelLoaded ? 'Model Loaded' : 'Model Not Loaded',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),

                // Processing indicator
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Processing images with TensorFlow Lite...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Image grids captured: $_capturedCount',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isCapturing ? Colors.red : Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      onPressed: _toggleCapturing,
                      child: Text(
                        _isCapturing ? 'Stop' : 'Start',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      onPressed: () {
                        _processImagesAndShowResults();
                      },
                      child: const Text(
                        'Gallery',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGallery() {
    if (_imageStorage.imageCount == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No images captured yet')));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          child: Container(
            width: _screenSize.width * 0.9,
            height: _screenSize.height * 0.8,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Captured Image Grids',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _imageStorage.imageCount,
                    itemBuilder: (BuildContext listContext, int gridIndex) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Grid ${gridIndex + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 8,
                                  childAspectRatio: 1.0,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                ),
                            itemCount: 64, // 8x8 grid
                            itemBuilder: (
                              BuildContext gridContext,
                              int cellIndex,
                            ) {
                              final int row = cellIndex ~/ 8;
                              final int col = cellIndex % 8;
                              return Image.memory(
                                _imageStorage.getGridImage(gridIndex, row, col),
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          const Divider(height: 24),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _processImagesAndShowResults {
  ChessPositionDifference chessPositionDifference = ChessPositionDifference();
}

// GridPainter class for drawing the 8x8 grid
class GridPainter extends CustomPainter {
  final int horizontalLines;
  final int verticalLines;

  const GridPainter(this.horizontalLines, this.verticalLines);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..strokeWidth = 1.0;

    // Draw horizontal lines
    final double horizontalSpacing = size.height / horizontalLines;
    for (int i = 1; i < horizontalLines; i++) {
      final double y = horizontalSpacing * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    final double verticalSpacing = size.width / verticalLines;
    for (int i = 1; i < verticalLines; i++) {
      final double x = verticalSpacing * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
