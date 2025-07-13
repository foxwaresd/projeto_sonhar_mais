class Receiver {
  final String id;
  final String nomeCompleto;
  final String? fotoPerfilUrl;
  final String? tipoSanguineo1; // Preferência 1
  final String? tipoSanguineo2; // Preferência 2
  final String? raca1;
  final String? raca2;
  final String? corPeleFitzpatrick1;
  final String? corPeleFitzpatrick2;
  final String? corOlhos1;
  final String? corOlhos2;
  final String? corCabelo1;
  final String? corCabelo2;
  final String? tipoCabelo1;
  final String? tipoCabelo2;
  final double? altura1Cm; // Convertido para double, em cm
  final double? altura2Cm; // Convertido para double, em cm
  final List<double>? faceEmbedding;
  final Map<String, dynamic> rawData; // Para acessar outros campos

  Receiver({
    required this.id,
    required this.nomeCompleto,
    this.fotoPerfilUrl,
    this.tipoSanguineo1,
    this.tipoSanguineo2,
    this.raca1,
    this.raca2,
    this.corPeleFitzpatrick1,
    this.corPeleFitzpatrick2,
    this.corOlhos1,
    this.corOlhos2,
    this.corCabelo1,
    this.corCabelo2,
    this.tipoCabelo1,
    this.tipoCabelo2,
    this.altura1Cm,
    this.altura2Cm,
    this.faceEmbedding,
    required this.rawData,
  });

  factory Receiver.fromMap(Map<String, dynamic> data, {required String id}) {
    print('[DEBUG Receiver ID: $id] Campos recebidos: ${data.keys.toList()}');
    double? parseDouble(String? value) {
      if (value == null || value.isEmpty) return null;
      try {
        return double.tryParse(value.replaceAll(',', '.'));
      } catch (e) {
        print('Erro ao parsear double "$value": $e');
        return null;
      }
    }

    // --- LÓGICA DE PARSE ROBUSTA E COM DEPURAÇÃO ---
    List<double>? embedding;
    if (data['faceEmbedding'] != null && data['faceEmbedding'] is List) {
      print('[DEBUG Receiver ID: $id] Campo "faceEmbedding" encontrado. Tentando converter...');
      List<dynamic> rawList = data['faceEmbedding'];
      List<double> tempList = [];
      bool parseSuccess = true;

      for (int i = 0; i < rawList.length; i++) {
        var element = rawList[i];
        if (element is num) {
          tempList.add(element.toDouble());
        } else {
          print('[DEBUG ERRO DE TIPO no Receiver ID: $id] Elemento no índice $i não é um número! Tipo: ${element.runtimeType}, Valor: $element');
          parseSuccess = false;
          break;
        }
      }

      if (parseSuccess) {
        embedding = tempList;
        print('[DEBUG Receiver ID: $id] Conversão do embedding bem-sucedida. Tamanho: ${embedding.length}');
      } else {
        print('[DEBUG Receiver ID: $id] Falha ao converter o embedding devido a tipo de dado inválido no array.');
        embedding = null;
      }
    }

    return Receiver(
      id: id,
      nomeCompleto: data['nomeCompleto'] ?? 'Receptora Desconhecida',
      fotoPerfilUrl: data['fotoPerfil'],
      tipoSanguineo1: data['tipoSanguineo1'],
      tipoSanguineo2: data['tipoSanguineo2'],
      raca1: data['raca1'],
      raca2: data['raca2'],
      corPeleFitzpatrick1: data['fitzpatrick'], // O nome do campo é 'fitzpatrick'
      corPeleFitzpatrick2: data['fitzpatrick2'], // O nome do campo é 'fitzpatrick2'
      corOlhos1: data['corOlhos1'],
      corOlhos2: data['corOlhos2'],
      corCabelo1: data['corCabelo1'],
      corCabelo2: data['corCabelo2'],
      tipoCabelo1: data['tipoCabelo1'],
      tipoCabelo2: data['tipoCabelo2'],
      altura1Cm: parseDouble(data['altura1']),
      altura2Cm: parseDouble(data['altura2']),
      rawData: data,
    );
  }
}