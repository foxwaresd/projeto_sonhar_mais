// core/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modules/pareamento/models/donor.dart';
import '../../modules/pareamento/models/matching_results.dart';
import '../../modules/pareamento/models/reciver.dart';
import '../../modules/pareamento/service/match_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String donorsCollection = 'doadoras';
  static const String receiversCollection = 'receptora'; // Coleção correta

  final MatchingService _matchingService = MatchingService();

  // --- NEW: Method to get a single Donor by ID ---
  Future<Donor?> getDonorById(String donorId) async {
    try {
      final docSnapshot = await _firestore.collection(donorsCollection).doc(donorId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return Donor.fromMap(docSnapshot.data()!, id: docSnapshot.id);
      }
      return null; // Donor not found
    } catch (e) {
      print('Erro ao buscar doadora por ID ($donorId): $e');
      return null;
    }
  }
  // --- END NEW ---

  Future<List<Receiver>> searchReceiversByName(String query) async {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();

    final allReceiversSnapshot = await _firestore.collection(receiversCollection).get();
    final allReceivers = allReceiversSnapshot.docs
        .map((doc) => Receiver.fromMap(doc.data(), id: doc.id))
        .toList();

    return allReceivers.where((receiver) {
      final receiverName = receiver.nomeCompleto.toLowerCase();
      return receiverName.contains(queryLower);
    }).toList();
  }

  Future<Receiver?> getReceiverById(String receiverId) async {
    final docSnapshot = await _firestore.collection(receiversCollection).doc(receiverId).get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      return Receiver.fromMap(docSnapshot.data()!, id: docSnapshot.id);
    }
    return null;
  }

  Future<List<Donor>> getAllDonors() async {
    final querySnapshot = await _firestore.collection(donorsCollection).get();
    return querySnapshot.docs.map((doc) => Donor.fromMap(doc.data(), id: doc.id)).toList();
  }

  Future<List<MatchingResult>> getCompatibleDonors({
    required String receiverId,
  }) async {
    final receiver = await getReceiverById(receiverId);
    if (receiver == null) {
      throw Exception('Receptora com ID "$receiverId" não encontrada.');
    }

    final allDonors = await getAllDonors();

    // This is where MatchingService takes over and should create MatchingResult
    // objects including the rawData of the donor.
    return _matchingService.findTopDonors(receiver, allDonors);
  }
}