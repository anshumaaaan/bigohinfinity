// image_storage.dart
import 'dart:typed_data';

class ImageStorage {
  // Store a list of image grids - each grid is a 2D array of images (8x8)
  final List<List<List<Uint8List>>> _imageGrids = [];

  // Store a single image (original version)
  void storeImage(Uint8List imageData) {
    _imageGrids.add([
      [imageData],
    ]);
  }

  // Store a 8x8 grid of images
  void storeImageGrid(List<List<Uint8List>> imageGrid) {
    _imageGrids.add(imageGrid);
  }

  // Get an individual image from a specific grid and cell position
  Uint8List getGridImage(int gridIndex, int row, int col) {
    if (gridIndex < 0 || gridIndex >= _imageGrids.length) {
      throw RangeError('Grid index out of bounds');
    }

    if (row < 0 || row >= _imageGrids[gridIndex].length) {
      throw RangeError('Row index out of bounds');
    }

    if (col < 0 || col >= _imageGrids[gridIndex][row].length) {
      throw RangeError('Column index out of bounds');
    }

    return _imageGrids[gridIndex][row][col];
  }

  // Get an entire grid of images
  List<List<Uint8List>> getImageGrid(int gridIndex) {
    if (gridIndex < 0 || gridIndex >= _imageGrids.length) {
      throw RangeError('Grid index out of bounds');
    }

    return _imageGrids[gridIndex];
  }

  // Get all grids (for legacy compatibility)
  Uint8List getImage(int index) {
    if (index < 0 || index >= _imageGrids.length) {
      throw RangeError('Index out of bounds');
    }

    // Return the first image from the grid (for legacy compatibility)
    return _imageGrids[index][0][0];
  }

  // Get all image grids
  List<List<List<Uint8List>>> getAllImageGrids() {
    return List.unmodifiable(_imageGrids);
  }

  // Clear all stored image grids
  void clearImages() {
    _imageGrids.clear();
  }

  // Count of stored image grids
  int get imageCount => _imageGrids.length;
}
