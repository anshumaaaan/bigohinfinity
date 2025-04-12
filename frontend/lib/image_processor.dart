// image_processor.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageProcessor {
  // Process the image:
  // 1. Crop to the square indicated by position and size
  // 2. Divide into 8x8 grid (64 images)
  Future<List<List<Uint8List>>> processImage(
    Uint8List imageData,
    Offset squarePosition,
    double squareSize,
  ) async {
    // First convert the image bytes to ui.Image
    final ui.Image originalImage = await _bytesToImage(imageData);

    // Calculate scale factor (ratio between screen coordinates and image coordinates)
    final double scaleX = originalImage.width / squarePosition.dx / 2;
    final double scaleY = originalImage.height / squarePosition.dy / 2;

    // Calculate the crop rectangle in image coordinates
    final int cropX = (squarePosition.dx * scaleX).toInt();
    final int cropY = (squarePosition.dy * scaleY).toInt();
    final int cropSize = (squareSize * scaleX).toInt();

    // Ensure crop rectangle is within image bounds
    final int adjustedCropX = cropX.clamp(0, originalImage.width - 1);
    final int adjustedCropY = cropY.clamp(0, originalImage.height - 1);
    final int adjustedCropSize = cropSize.clamp(
      1,
      min(
        originalImage.width - adjustedCropX,
        originalImage.height - adjustedCropY,
      ),
    );

    // Crop the image to the square
    final ui.Image croppedImage = await _cropImage(
      originalImage,
      adjustedCropX,
      adjustedCropY,
      adjustedCropSize,
      adjustedCropSize,
    );

    // Divide the cropped image into 8x8 grid
    return _divideImage(croppedImage, 8, 8);
  }

  // Helper function to convert bytes to ui.Image
  Future<ui.Image> _bytesToImage(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  // Helper function to crop an image
  Future<ui.Image> _cropImage(
    ui.Image image,
    int x,
    int y,
    int width,
    int height,
  ) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Paint only the cropped portion
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(
        x.toDouble(),
        y.toDouble(),
        width.toDouble(),
        height.toDouble(),
      ),
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint(),
    );

    final ui.Picture picture = recorder.endRecording();
    final ui.Image croppedImage = await picture.toImage(width, height);

    return croppedImage;
  }

  // Helper function to divide an image into a grid
  Future<List<List<Uint8List>>> _divideImage(
    ui.Image image,
    int rows,
    int cols,
  ) async {
    final List<List<Uint8List>> gridImages = List.generate(
      rows,
      (_) => List.generate(cols, (_) => Uint8List(0)),
    );

    final int cellWidth = (image.width / cols).floor();
    final int cellHeight = (image.height / rows).floor();

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        // Crop a cell from the image
        final ui.Image cellImage = await _cropImage(
          image,
          j * cellWidth,
          i * cellHeight,
          cellWidth,
          cellHeight,
        );

        // Convert to bytes
        final ByteData? byteData = await cellImage.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData != null) {
          gridImages[i][j] = byteData.buffer.asUint8List();
        }
      }
    }

    return gridImages;
  }

  // Helper function to find minimum of two numbers
  int min(int a, int b) => a < b ? a : b;
}
