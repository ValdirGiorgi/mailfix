import 'dart:math' show min, max;
import '../interfaces/similarity_algorithm.dart';

/// Jaro-Winkler string similarity algorithm.
class JaroWinklerAlgorithm implements SimilarityAlgorithm {
  JaroWinklerAlgorithm({double scalingFactor = 0.1, int prefixMaxLength = 4})
    : _scalingFactor = scalingFactor,
      _prefixMaxLength = prefixMaxLength;
  @override
  String get name => 'Jaro-Winkler';

  final double _scalingFactor;
  final int _prefixMaxLength;

  @override
  int calculate(String source, String target) {
    final similarity = _jaroWinklerSimilarity(source, target);
    return ((1.0 - similarity) * 10).round();
  }

  double _jaroWinklerSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    final jaroSimilarity = _jaroSimilarity(s1, s2);
    final prefixLength = _commonPrefixLength(s1, s2);
    return jaroSimilarity +
        (prefixLength * _scalingFactor * (1 - jaroSimilarity));
  }

  int _commonPrefixLength(String s1, String s2) {
    final maxLength = min(_prefixMaxLength, min(s1.length, s2.length));
    var i = 0;
    while (i < maxLength && s1[i] == s2[i]) {
      i++;
    }
    return i;
  }

  double _jaroSimilarity(String s1, String s2) {
    final matchDistance = (max(s1.length, s2.length) ~/ 2) - 1;
    final s1Matches = List<bool>.filled(s1.length, false);
    final s2Matches = List<bool>.filled(s2.length, false);
    final int matchingChars = _findMatches(
      s1,
      s2,
      matchDistance,
      s1Matches,
      s2Matches,
    );
    if (matchingChars == 0) return 0.0;
    final transpositions = _countTranspositions(s1, s2, s1Matches, s2Matches);
    final m = matchingChars.toDouble();
    return (m / s1.length + m / s2.length + (m - transpositions / 2) / m) / 3;
  }

  int _findMatches(
    String s1,
    String s2,
    int matchDistance,
    List<bool> s1Matches,
    List<bool> s2Matches,
  ) {
    var matchingChars = 0;
    for (var i = 0; i < s1.length; i++) {
      final start = max(0, i - matchDistance);
      final end = min(i + matchDistance + 1, s2.length);
      for (var j = start; j < end; j++) {
        if (!s2Matches[j] && s1[i] == s2[j]) {
          s1Matches[i] = true;
          s2Matches[j] = true;
          matchingChars++;
          break;
        }
      }
    }
    return matchingChars;
  }

  int _countTranspositions(
    String s1,
    String s2,
    List<bool> s1Matches,
    List<bool> s2Matches,
  ) {
    var transpositions = 0;
    var k = 0;
    for (var i = 0; i < s1.length; i++) {
      if (!s1Matches[i]) continue;
      while (!s2Matches[k]) k++;
      if (s1[i] != s2[k]) transpositions++;
      k++;
    }
    return transpositions;
  }
}
