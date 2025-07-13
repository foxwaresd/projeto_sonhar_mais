class Donor {
  final String id; // ID do documento no Firestore
  final String nomeCompleto; // Corresponds to 'nome' in your PDF snippet
  final String? fotoPerfilUrl; // Corresponds to 'foto'
  final String? observacao;
  final String? idade; // You're using String, so keeping it
  final double? pesoKg; // Changed to double?
  final double? alturaCm; // Changed to double?
  final String? tipoSanguineo; // Corresponds to 'tipoSanguineo'
  final String? corOlhos; // Corresponds to 'olhos'
  final String? corCabelo; // Corresponds to 'cabeloCor'
  final String? tipoCabelo; // Corresponds to 'cabeloTextura'
  final String? raca; // Corresponds to 'raca'
  final String? signo;
  final String? corPeleFitzpatrick; // Corresponds to 'fitzpatrick'
  final String? formatoRosto;
  final String? profissao;
  final String? hobby; // Corresponds to 'hobbies' in rawData
  final String? atividadeFisica; // Corresponds to 'atividadesFisicas' in rawData
  final String? escolaridade;
  final String? estadoCivil;
  final String? filhos;
  final String? irmaos;
  final String? filhaAdotiva;
  final String? gemeos;
  final String? qualidades;

  // Historico Saude fields
  final String? historicoSaudeAudicao;
  final String? historicoSaudeVisao;
  final String? historicoSaudeAlergia;
  final String? historicoSaudeAsma;
  final String? historicoSaudeDoencaCronica;
  final String? historicoSaudeFumante;
  final String? historicoSaudeDrogas;
  final String? saudeAlcool;

  // Historico Familiar fields
  final String? historicoFamiliarAutismo;
  final String? historicoFamiliarDepressao;
  final String? historicoFamiliarEsquizofrenia;
  final String? historicoFamiliarAnemiaFalciforme;
  final String? historicoFamiliarTalassemia;
  final String? historicoFamiliarFibroseCistica;
  final String? historicoFamiliarDiabetesMelittus;
  final String? historicoFamiliarEpilepsia;
  final String? historicoFamiliarHipertensao;
  final String? historicoFamiliarDistrofiaMuscular;
  final String? historicoFamiliarAtrofiaMuscular;
  final String? historicoFamiliarDoencaIsquemica;
  final String? historicoFamiliarNeoplasia;
  final String? historicoFamiliarDeficienciaFisica;
  final String? historicoFamiliarDeficienciaMental;
  final String? historicoFamiliarDoencaGenetica;

  // Historico Doadora fields
  final String? historicoDoadoraEpilepsia;
  final String? historicoDoadoraHipertensao;
  final String? historicoDoadoraDiabetesMellitus;
  final String? historicoDoadoraDeficienciaFisica;
  final String? historicoDoadoraDoencasGeneticas;
  final String? historicoDoadorasNeoplasias;
  final String? historicoDoadoraLabioLeporino;
  final String? historicoDoadoraEspinhaBifida;
  final String? historicoDoadoraDeficienciaMental;
  final String? historicoDoadoraMalFormacaoCardica;
  final String? historicoDoadoraGeral; // Renamed to avoid clash with specific field

  final List<String> exames;
  final String? status;

  // New fields from your Doadora class in previous messages
  final String? assinatura;
  final String? email;
  final String? telefone;
  final String? cpf;
  final String? rg;
  final String? cep;
  final String? endereco;
  final String? cidade;
  final String? estado;
  final String? dob; // Date of Birth
  final String? medicoAssistente;
  final String? motivo;
  final String? declaroVeracidade;
  final String? caracteristicas1;
  final String? idioma;
  final String? ovulos; // Now included as a direct field
  final Map<String, dynamic> rawData; // Still useful for unmapped fields or debugging

  final List<double>? faceEmbedding;

  Donor({
    required this.id,
    required this.nomeCompleto,
    this.fotoPerfilUrl,
    this.observacao,
    this.idade,
    this.pesoKg,
    this.alturaCm,
    this.tipoSanguineo,
    this.corOlhos,
    this.corCabelo,
    this.tipoCabelo,
    this.raca,
    this.signo,
    this.corPeleFitzpatrick,
    this.formatoRosto,
    this.profissao,
    this.hobby,
    this.atividadeFisica,
    this.escolaridade,
    this.estadoCivil,
    this.filhos,
    this.irmaos,
    this.filhaAdotiva,
    this.gemeos,
    this.qualidades,
    this.historicoSaudeAudicao,
    this.historicoSaudeVisao,
    this.historicoSaudeAlergia,
    this.historicoSaudeAsma,
    this.historicoSaudeDoencaCronica,
    this.historicoSaudeFumante,
    this.historicoSaudeDrogas,
    this.saudeAlcool,
    this.historicoFamiliarAutismo,
    this.historicoFamiliarDepressao,
    this.historicoFamiliarEsquizofrenia,
    this.historicoFamiliarAnemiaFalciforme,
    this.historicoFamiliarTalassemia,
    this.historicoFamiliarFibroseCistica,
    this.historicoFamiliarDiabetesMelittus,
    this.historicoFamiliarEpilepsia,
    this.historicoFamiliarHipertensao,
    this.historicoFamiliarDistrofiaMuscular,
    this.historicoFamiliarAtrofiaMuscular,
    this.historicoFamiliarDoencaIsquemica,
    this.historicoFamiliarNeoplasia,
    this.historicoFamiliarDeficienciaFisica,
    this.historicoFamiliarDeficienciaMental,
    this.historicoFamiliarDoencaGenetica,
    this.historicoDoadoraEpilepsia,
    this.historicoDoadoraHipertensao,
    this.historicoDoadoraDiabetesMellitus,
    this.historicoDoadoraDeficienciaFisica,
    this.historicoDoadoraDoencasGeneticas,
    this.historicoDoadorasNeoplasias,
    this.historicoDoadoraLabioLeporino,
    this.historicoDoadoraEspinhaBifida,
    this.historicoDoadoraDeficienciaMental,
    this.historicoDoadoraMalFormacaoCardica,
    this.historicoDoadoraGeral,
    this.exames = const [], // Default to empty list
    this.status,
    this.assinatura,
    this.email,
    this.telefone,
    this.cpf,
    this.rg,
    this.cep,
    this.endereco,
    this.cidade,
    this.estado,
    this.dob,
    this.medicoAssistente,
    this.motivo,
    this.declaroVeracidade,
    this.caracteristicas1,
    this.idioma,
    this.ovulos,
    this.faceEmbedding,
    required this.rawData,
  });

  // dentro da classe Donor
  factory Donor.fromMap(Map<String, dynamic> data, {required String id}) {
    // Sua função auxiliar
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        try {
          return double.tryParse(value.replaceAll(',', '.'));
        } catch (e) {
          print('Erro ao parsear double "$value": $e');
          return null;
        }
      }
      return null;
    }

    // --- LÓGICA DE PARSE ROBUSTA E COM DEPURAÇÃO ---
    List<double>? embedding;
    if (data['faceEmbedding'] != null && data['faceEmbedding'] is List) {
      print('[DEBUG Donor ID: $id] Campo "faceEmbedding" encontrado. Tentando converter...');
      List<dynamic> rawList = data['faceEmbedding'];
      List<double> tempList = [];
      bool parseSuccess = true;

      for (int i = 0; i < rawList.length; i++) {
        var element = rawList[i];
        if (element is num) {
          tempList.add(element.toDouble());
        } else {
          // Este log nos dirá se algum item do array tem o tipo errado
          print('[DEBUG ERRO DE TIPO no Donor ID: $id] Elemento no índice $i não é um número! Tipo: ${element.runtimeType}, Valor: $element');
          parseSuccess = false;
          break; // Para a conversão se encontrar um erro
        }
      }

      if (parseSuccess) {
        embedding = tempList;
        print('[DEBUG Donor ID: $id] Conversão do embedding bem-sucedida. Tamanho: ${embedding.length}');
      } else {
        print('[DEBUG Donor ID: $id] Falha ao converter o embedding devido a tipo de dado inválido no array.');
        embedding = null; // Garante que será nulo se a conversão falhar
      }
    }

    return Donor(
      id: id,
      nomeCompleto: data['nomeCompleto'] ?? 'Doadora Desconhecida',
      fotoPerfilUrl: data['fotoPerfil'],
      observacao: data['observacao'],
      idade: data['idade'],
      pesoKg: parseDouble(data['peso1']),
      alturaCm: parseDouble(data['altura1']),
      tipoSanguineo: data['tipoSanguineo1'],
      corOlhos: data['corOlhos1'],
      corCabelo: data['corCabelo1'],
      tipoCabelo: data['tipoCabelo1'],
      raca: data['raca1'],
      signo: data['signo'],
      corPeleFitzpatrick: data['fitzpatrick'],
      formatoRosto: data['formatoRosto'],
      profissao: data['profissao'],
      hobby: data['hobbies'],
      atividadeFisica: data['atividadesFisicas'],
      escolaridade: data['escolaridade'],
      estadoCivil: data['estadoCivil'],
      filhos: data['filhos'],
      irmaos: data['irmaos'],
      filhaAdotiva: data['filhaAdotiva'],
      gemeos: data['gemeos'],
      qualidades: data['qualidades'],
      historicoSaudeAudicao: data['historicoSaudeAudicao'],
      historicoSaudeVisao: data['historicoSaudeVisao'],
      historicoSaudeAlergia: data['historicoSaudeAlergia'],
      historicoSaudeAsma: data['historicoSaudeAsma'],
      historicoSaudeDoencaCronica: data['historicoSaudeDoencaCronica'],
      historicoSaudeFumante: data['historicoSaudeFumante'],
      historicoSaudeDrogas: data['historicoSaudeDrogas'],
      saudeAlcool: data['historicoSaudeAlcool'],
      historicoFamiliarAutismo: data['historicoFamiliarAutismo'],
      historicoFamiliarDepressao: data['historicoFamiliarDepressao'],
      historicoFamiliarEsquizofrenia: data['historicoFamiliarEsquizofrenia'],
      historicoFamiliarAnemiaFalciforme: data['historicoFamiliarAnemiaFalciforme'],
      historicoFamiliarTalassemia: data['historicoFamiliarTalassemia'],
      historicoFamiliarFibroseCistica: data['historicoFamiliarFibroseCistica'],
      historicoFamiliarDiabetesMelittus: data['historicoFamiliarDiabetesMelittus'],
      historicoFamiliarEpilepsia: data['historicoFamiliarEpilepsia'],
      historicoFamiliarHipertensao: data['historicoFamiliarHipertensao'],
      historicoFamiliarDistrofiaMuscular: data['historicoFamiliarDistrofiaMuscular'],
      historicoFamiliarAtrofiaMuscular: data['historicoFamiliarAtrofiaMuscular'],
      historicoFamiliarDoencaIsquemica: data['historicoFamiliarDoencaIsquemica'],
      historicoFamiliarNeoplasia: data['historicoFamiliarNeoplasia'],
      historicoFamiliarDeficienciaFisica: data['historicoFamiliarDeficienciaFisica'],
      historicoFamiliarDeficienciaMental: data['historicoFamiliarDeficienciaMental'],
      historicoFamiliarDoencaGenetica: data['historicoFamiliarDoençaGenetica'],
      historicoDoadoraEpilepsia: data['historicoDoadoraEpilepsia'], // Assuming specific fields exist
      historicoDoadoraHipertensao: data['historicoDoadoraHipertensao'],
      historicoDoadoraDiabetesMellitus: data['historicoDoadoraDiabetesMellitus'],
      historicoDoadoraDeficienciaFisica: data['historicoDoadoraDeficienciaFisica'],
      historicoDoadoraDoencasGeneticas: data['historicoDoadoraDoencasGeneticas'],
      historicoDoadorasNeoplasias: data['historicoDoadorasNeoplasias'],
      historicoDoadoraLabioLeporino: data['historicoDoadoraLabioLeporino'],
      historicoDoadoraEspinhaBifida: data['historicoDoadoraEspinhaBifida'],
      historicoDoadoraDeficienciaMental: data['historicoDoadoraDeficienciaMental'],
      historicoDoadoraMalFormacaoCardica: data['historicoDoadoraMalFormacaoCardica'],
      historicoDoadoraGeral: data['historicoDoadora'], // General field
      exames: (data['examesFeitos'] as String?)?.split(', ').toList() ?? [],
      status: data['status'] == '' ? 'Pendente Punção' : data['status'],
      assinatura: data['assinatura'],
      email: data['email'],
      telefone: data['telefone'],
      cpf: data['cpf'],
      rg: data['rg'],
      cep: data['cep'],
      endereco: data['endereco'],
      cidade: data['cidade'],
      estado: data['estado'],
      dob: data['dob'],
      medicoAssistente: data['medicoAssistente'],
      motivo: data['motivo'],
      declaroVeracidade: data['declaroVeracidade'],
      caracteristicas1: data['caracteristicas1'],
      idioma: data['idioma'],
      ovulos: data['ovulos'],
      faceEmbedding: embedding,
      rawData: data, // Keep rawData for any unmapped fields
    );
  }
}