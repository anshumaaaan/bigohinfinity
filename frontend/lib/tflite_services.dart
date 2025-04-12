// tflite_service.dart
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  Interpreter? _interpreter;
  bool _isInitialized = false;

  // Initialize the TensorFlow Lite interpreter
  Future<void> initialize() async {
    try {
      // Load the model
      _interpreter = await Interpreter.fromAsset('assets/chessVission.tflite');
      _isInitialized = true;
      print('TFLite model loaded successfully');
    } catch (e) {
      print('Error loading TFLite model: $e');
      _isInitialized = false;
    }
  }

  // Check if the interpreter is initialized
  bool get isInitialized => _isInitialized;

  // Process a grid of images and get predictions
  Future<List<String>> processImageGrid(List<List<Uint8List>> imageGrid) async {
    if (!_isInitialized || _interpreter == null) {
      throw Exception('TFLite interpreter not initialized');
    }

    final List<String> results = [];

    // Process each cell in the grid
    for (int row = 0; row < imageGrid.length; row++) {
      for (int col = 0; col < imageGrid[row].length; col++) {
        final Uint8List cellImage = imageGrid[row][col];
        final String prediction = await _processSingleImage(cellImage);
        results.add('$row,$col: $prediction');
      }
    }

    return results;
  }

  // Process a single image and get prediction
  Future<String> _processSingleImage(Uint8List imageBytes) async {
    if (!_isInitialized || _interpreter == null) {
      throw Exception('TFLite interpreter not initialized');
    }

    // Decode the image
    final img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      return 'Error: Could not decode image';
    }

    try {
      // Resize image to match model input size (assuming model expects 224x224)
      final img.Image resizedImage = img.copyResize(
        image,
        width: 224,
        height: 224,
      );

      // Convert image to input tensor format (float32 values between 0-1)
      final inputTensor = _imageToTensor(resizedImage);

      // Define output tensor
      final outputTensor = List<List<double>>.filled(
        1,
        List<double>.filled(13, 0), // Assuming 13 chess piece classes
      );

      // Run inference
      _interpreter!.run(inputTensor, outputTensor);

      // Process output (get class with highest probability)
      final List<double> output = outputTensor[0];
      final int maxIndex = _getMaxIndex(output);

      // Convert to chess piece name
      final String piece = _indexToPiece(maxIndex);

      return piece;
    } catch (e) {
      print('Error processing image: $e');
      return 'Error: Processing failed';
    }
  }

  // Convert image to input tensor
  List<List<List<List<double>>>> _imageToTensor(img.Image image) {
    // Create input tensor of shape [1, 224, 224, 3]
    final tensor = List.generate(
      1,
      (_) => List.generate(
        image.height,
        (_) => List.generate(image.width, (_) => List.filled(3, 0.0)),
      ),
    );

    // Fill tensor with normalized pixel values
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        // Normalize to [0, 1]
        tensor[0][y][x][0] = pixel.r / 255.0;
        tensor[0][y][x][1] = pixel.g / 255.0;
        tensor[0][y][x][2] = pixel.b / 255.0;
      }
    }

    return tensor;
  }

  // Get the index with the highest value
  int _getMaxIndex(List<double> array) {
    double maxValue = array[0];
    int maxIndex = 0;

    for (int i = 1; i < array.length; i++) {
      if (array[i] > maxValue) {
        maxValue = array[i];
        maxIndex = i;
      }
    }

    return maxIndex;
  }

  // Convert model output index to chess piece name
  String _indexToPiece(int index) {
    // This mapping should match your model's output classes
    final pieces = [
      'empty', // 0
      'white_pawn', // 1
      'white_knight', // 2
      'white_bishop', // 3
      'white_rook', // 4
      'white_queen', // 5
      'white_king', // 6
      'black_pawn', // 7
      'black_knight', // 8
      'black_bishop', // 9
      'black_rook', // 10
      'black_queen', // 11
      'black_king', // 12
    ];

    if (index >= 0 && index < pieces.length) {
      return pieces[index];
    } else {
      return 'unknown';
    }
  }

  // Dispose resources
  void dispose() {
    _interpreter?.close();
  }
}
