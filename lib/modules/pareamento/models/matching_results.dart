// Local do arquivo: lib/modules/pareamento/models/matching_results.dart

class MatchingResult {
  final String donorId;
  final String donorName;
  final String donorPhotoUrl;
  final int eggCount;
  final double phenotypePercentage;
  final double photoPercentage;
  final double finalCompatibilityPercentage;
  final Map<String, dynamic> donorDetails;

  MatchingResult({
    required this.donorId,
    required this.donorName,
    required this.donorPhotoUrl,
    required this.eggCount,
    required this.phenotypePercentage,
    required this.photoPercentage,
    required this.finalCompatibilityPercentage,
    required this.donorDetails,
  });
}