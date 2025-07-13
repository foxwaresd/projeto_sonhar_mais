import 'dart:math';
import '../models/donor.dart';
import '../models/matching_results.dart';
import '../models/reciver.dart'; // Corrija para 'receiver.dart' se o nome do arquivo estiver assim

class MatchingService {
  static const double PHENOTYPE_WEIGHT = 0.70;
  static const double PHOTO_WEIGHT = 0.30;

  double _calculatePhenotypeScore(Receiver receiver, Donor donor) {
    // ... (esta função está correta, sem alterações) ...
    double score = 0.0;
    const double RACA_WEIGHT = 0.15;
    const double COR_PELE_WEIGHT = 0.15;
    const double COR_OLHOS_WEIGHT = 0.15;
    const double COR_CABELO_WEIGHT = 0.15;
    const double TIPO_CABELO_WEIGHT = 0.15;
    const double ALTURA_WEIGHT = 0.25;

    if (donor.raca != null && (donor.raca == receiver.raca1 || donor.raca == receiver.raca2)) score += RACA_WEIGHT;
    if (donor.corPeleFitzpatrick != null && (donor.corPeleFitzpatrick == receiver.corPeleFitzpatrick1 || donor.corPeleFitzpatrick == receiver.corPeleFitzpatrick2)) score += COR_PELE_WEIGHT;
    if (donor.corOlhos != null && (donor.corOlhos == receiver.corOlhos1 || donor.corOlhos == receiver.corOlhos2)) score += COR_OLHOS_WEIGHT;
    if (donor.corCabelo != null && (donor.corCabelo == receiver.corCabelo1 || donor.corCabelo == receiver.corCabelo2)) score += COR_CABELO_WEIGHT;
    if (donor.tipoCabelo != null && (donor.tipoCabelo == receiver.tipoCabelo1 || donor.tipoCabelo == receiver.tipoCabelo2)) score += TIPO_CABELO_WEIGHT;

    if (donor.alturaCm != null && (receiver.altura1Cm != null || receiver.altura2Cm != null)) {
      const double VARIATION = 20.0;
      bool alturaMatch = false;
      if (receiver.altura1Cm != null && (donor.alturaCm! - receiver.altura1Cm!).abs() <= VARIATION) alturaMatch = true;
      if (!alturaMatch && receiver.altura2Cm != null && (donor.alturaCm! - receiver.altura2Cm!).abs() <= VARIATION) alturaMatch = true;
      if (alturaMatch) score += ALTURA_WEIGHT;
    }
    return score;
  }

  /// **LÓGICA CORRIGIDA E MAIS ROBUSTA**
  /// Calcula a similaridade facial localmente em Dart.
  double _getFaceSimilarityScore(Receiver receiver, Donor donor) {

    // Função auxiliar para extrair e converter o embedding de forma segura
    List<double>? parseEmbedding(Map<String, dynamic>? rawData, String entityId) {
      if (rawData == null || rawData['faceEmbedding'] == null || rawData['faceEmbedding'] is! List) {
        print('[DEBUG] Embedding não encontrado ou com formato inválido para o ID: $entityId');
        return null;
      }
      try {
        return (rawData['faceEmbedding'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList();
      } catch (e) {
        print('[DEBUG] Erro ao converter embedding para o ID: $entityId. Erro: $e');
        return null;
      }
    }

    // Extrai os embeddings diretamente dos dados brutos no momento do uso
    final receiverEmbedding = parseEmbedding(receiver.rawData, receiver.id);
    final donorEmbedding = parseEmbedding(donor.rawData, donor.id);

    if (receiverEmbedding == null || donorEmbedding == null) {
      return 0.0;
    }

    if (receiverEmbedding.length != donorEmbedding.length || receiverEmbedding.length != 128) {
      return 0.0;
    }

    double sumOfSquares = 0.0;
    for (int i = 0; i < receiverEmbedding.length; i++) {
      final diff = receiverEmbedding[i] - donorEmbedding[i];
      sumOfSquares += diff * diff;
    }
    final distance = sqrt(sumOfSquares);
    final similarity = max(0.0, 1.0 - distance);

    print('[DEBUG] Doadora ${donor.id} vs Receptora ${receiver.id} -> Distância: ${distance.toStringAsFixed(4)}, Similaridade: ${similarity.toStringAsFixed(4)}');

    return similarity;
  }

  /// Função principal para encontrar as doadoras mais compatíveis.
  List<MatchingResult> findTopDonors(Receiver receiver, List<Donor> allDonors) {
    List<MatchingResult> results = [];

    for (var donor in allDonors) {
      // Filtro rigoroso: Tipo Sanguíneo
      bool tipoSanguineoMatch = false;
      if (donor.tipoSanguineo != null) {
        if (receiver.tipoSanguineo1 != null && donor.tipoSanguineo == receiver.tipoSanguineo1) {
          tipoSanguineoMatch = true;
        }
        if (!tipoSanguineoMatch && receiver.tipoSanguineo2 != null && donor.tipoSanguineo == receiver.tipoSanguineo2) {
          tipoSanguineoMatch = true;
        }
      }
      if (!tipoSanguineoMatch) {
        continue;
      }

      final phenotypeScore = _calculatePhenotypeScore(receiver, donor);
      final photoScore = _getFaceSimilarityScore(receiver, donor);
      final finalScore = (phenotypeScore * PHENOTYPE_WEIGHT) + (photoScore * PHOTO_WEIGHT);

      results.add(MatchingResult(
        donorId: donor.id,
        donorName: donor.nomeCompleto,
        donorPhotoUrl: donor.fotoPerfilUrl ?? 'https://via.placeholder.com/150',
        eggCount: int.tryParse(donor.ovulos ?? '0') ?? 0,
        phenotypePercentage: phenotypeScore * 100,
        photoPercentage: photoScore * 100,
        finalCompatibilityPercentage: finalScore * 100,
        donorDetails: donor.rawData,
      ));
    }

    results.sort((a, b) => b.finalCompatibilityPercentage.compareTo(a.finalCompatibilityPercentage));
    return results.take(5).toList();
  }
}