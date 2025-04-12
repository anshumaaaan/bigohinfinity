// chess_position_difference.dart
import 'package:flutter/material.dart';

class ChessPositionDifference {
  // Method to find differences between two chess board positions
  // Returns a list of changes in chess notation (e.g., "b4")
  static List<String> findPositionDifferences(
    List<List<String>> previousPosition,
    List<List<String>> currentPosition,
  ) {
    // Validate input dimensions
    if (previousPosition.length != 8 ||
        currentPosition.length != 8 ||
        previousPosition[0].length != 8 ||
        currentPosition[0].length != 8) {
      throw ArgumentError('Both positions must be 8x8 matrices');
    }

    final List<String> differences = [];
    final Map<String, List<Point>> removedPieces = {};
    final Map<String, List<Point>> addedPieces = {};

    // Chess file labels (columns)
    final List<String> files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

    // Compare each square
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final String prev = previousPosition[row][col];
        final String current = currentPosition[row][col];

        // If the pieces are different
        if (prev != current) {
          // Convert to chess notation (e.g., "b4")
          final String notation = files[col] + (8 - row).toString();

          // Track pieces that were removed (from previous position)
          if (prev != 'empty' && prev != '') {
            if (!removedPieces.containsKey(prev)) {
              removedPieces[prev] = [];
            }
            removedPieces[prev]!.add(Point(row, col));
          }

          // Track pieces that were added (to current position)
          if (current != 'empty' && current != '') {
            if (!addedPieces.containsKey(current)) {
              addedPieces[current] = [];
            }
            addedPieces[current]!.add(Point(row, col));
          }

          // Add the changed square to differences
          differences.add(notation);
        }
      }
    }

    // Detect moves (when a piece type appears in both removed and added lists)
    final List<String> detectedMoves = _detectMoves(
      removedPieces,
      addedPieces,
      files,
    );
    if (detectedMoves.isNotEmpty) {
      return detectedMoves;
    }

    return differences;
  }

  // Helper method to detect piece movements
  static List<String> _detectMoves(
    Map<String, List<Point>> removedPieces,
    Map<String, List<Point>> addedPieces,
    List<String> files,
  ) {
    final List<String> moves = [];

    // For each piece type that was both removed and added
    for (final pieceType in removedPieces.keys) {
      if (addedPieces.containsKey(pieceType)) {
        final List<Point> removedPoints = removedPieces[pieceType]!;
        final List<Point> addedPoints = addedPieces[pieceType]!;

        // Simple case: one piece of this type moved
        if (removedPoints.length == 1 && addedPoints.length == 1) {
          final Point from = removedPoints[0];
          final Point to = addedPoints[0];

          // Create move notation (e.g., "b2-b4" or just "b4" for destination)
          final String fromNotation =
              files[from.col] + (8 - from.row).toString();
          final String toNotation = files[to.col] + (8 - to.row).toString();

          // Return just the destination square
          moves.add(toNotation);
          // Alternatively, return the full move: moves.add('$fromNotation-$toNotation');
        }
        // If multiple pieces of same type moved, return all possible destinations
        else if (removedPoints.length == addedPoints.length) {
          for (final Point to in addedPoints) {
            final String toNotation = files[to.col] + (8 - to.row).toString();
            moves.add(toNotation);
          }
        }
      }
    }

    return moves;
  }
}

// Simple point class to represent row/col positions
class Point {
  final int row;
  final int col;

  Point(this.row, this.col);

  @override
  String toString() => '($row, $col)';
}

// Example usage
void main() {
  // Previous board state (each cell contains piece name or 'empty')
  final List<List<String>> previousPosition = [
    [
      'black_rook',
      'black_knight',
      'black_bishop',
      'black_queen',
      'black_king',
      'black_bishop',
      'black_knight',
      'black_rook',
    ],
    [
      'black_pawn',
      'black_pawn',
      'black_pawn',
      'black_pawn',
      'black_pawn',
      'black_pawn',
      'black_pawn',
      'black_pawn',
    ],
    ['empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty'],
    ['empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty'],
    ['empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty'],
    ['empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty'],
    [
      'white_pawn',
      'white_pawn',
      'white_pawn',
      'white_pawn',
      'white_pawn',
      'white_pawn',
      'white_pawn',
      'white_pawn',
    ],
    [
      'white_rook',
      'white_knight',
      'white_bishop',
      'white_queen',
      'white_king',
      'white_bishop',
      'white_knight',
      'white_rook',
    ],
  ];

  // Current board state (after e2-e4 move)
  final List<List<String>> currentPosition = [
    [
      'black_rook',
      'black_knight',
      'black_bishop',
      'black_queen',
      'black_king',
      'black_bishop',
      'black_knight',
      'black_rook',
    ],
    [
      'black_pawn',
      'black_pawn',
      'black_pawn',
      'black_pawn',
      'black_pawn',
      'black_pawn',
      'black_pawn',
      'black_pawn',
    ],
    ['empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty'],
    ['empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty'],
    [
      'empty',
      'empty',
      'empty',
      'empty',
      'white_pawn',
      'empty',
      'empty',
      'empty',
    ],
    ['empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty', 'empty'],
    [
      'white_pawn',
      'white_pawn',
      'white_pawn',
      'white_pawn',
      'empty',
      'white_pawn',
      'white_pawn',
      'white_pawn',
    ],
    [
      'white_rook',
      'white_knight',
      'white_bishop',
      'white_queen',
      'white_king',
      'white_bishop',
      'white_knight',
      'white_rook',
    ],
  ];

  // Find differences
  final List<String> differences =
      ChessPositionDifference.findPositionDifferences(
        previousPosition,
        currentPosition,
      );

  print('Detected changes: $differences');
  // Output: Detected changes: [e4]
}
