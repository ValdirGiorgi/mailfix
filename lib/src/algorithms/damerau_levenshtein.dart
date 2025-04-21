import 'dart:math' show min;
import '../interfaces/similarity_algorithm.dart';

// Damerau-Levenshtein distance algorithm implementation
class DamerauLevenshteinAlgorithm implements SimilarityAlgorithm {
  @override
  String get name => 'Damerau-Levenshtein';

  @override
  int calculate(String source, String target) {
    if (source == target) return 0;
    if (source.isEmpty) return target.length;
    if (target.isEmpty) return source.length;

    final rows = source.length + 1;
    final cols = target.length + 1;
    final matrix = List<List<int>>.generate(
      rows,
      (_) => List<int>.filled(cols, 0),
    );

    for (var row = 0; row < rows; row++) {
      matrix[row][0] = row;
    }

    for (var col = 0; col < cols; col++) {
      matrix[0][col] = col;
    }

    for (var row = 1; row < rows; row++) {
      for (var col = 1; col < cols; col++) {
        final cost = source[row - 1] == target[col - 1] ? 0 : 1;
        matrix[row][col] = [
          matrix[row - 1][col] + 1, // deletion
          matrix[row][col - 1] + 1, // insertion
          matrix[row - 1][col - 1] + cost, // substitution
        ].reduce(min);

        if (row > 1 &&
            col > 1 &&
            source[row - 1] == target[col - 2] &&
            source[row - 2] == target[col - 1]) {
          matrix[row][col] = min(
            matrix[row][col],
            matrix[row - 2][col - 2] + cost, // transposition
          );
        }
      }
    }

    return matrix[source.length][target.length];
  }
}
