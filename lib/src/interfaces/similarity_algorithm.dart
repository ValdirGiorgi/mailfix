// Interface for email similarity algorithms
abstract class SimilarityAlgorithm {
  String get name;
  int calculate(String source, String target);
}
