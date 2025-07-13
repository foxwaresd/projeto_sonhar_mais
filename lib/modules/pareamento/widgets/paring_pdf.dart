import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Assuming these imports are correctly pointing to your model classes
import '../models/donor.dart';
import '../models/reciver.dart';

/// Helper function to load image from URL.
/// Returns a [pw.MemoryImage] if successful, otherwise null.
Future<pw.MemoryImage?> _loadImageFromUrl(String? url) async {
  if (url == null || url.isEmpty) {
    return null;
  }
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return pw.MemoryImage(response.bodyBytes);
    } else {
      print('Falha ao carregar imagem da URL: ${response.statusCode} - ${response.reasonPhrase}');
      return null;
    }
  } catch (e) {
    print('Erro ao carregar imagem da URL: $e');
    return null;
  }
}

/// Generates a PDF document for donor matching.
///
/// This function creates a detailed PDF report for a given [donor],
/// including personal, physical, lifestyle, family, and health history,
/// along with a compatibility [matchPercentage].
/// The [receiver] object is currently not used in the PDF content but is
/// kept in the signature as per the original code.
Future<void> generateDonorMatchPdf(Donor donor, Receiver receiver, double matchPercentage) async {
  final pdf = pw.Document();

  // --- Fetch Logo URL from Firebase ---
  String? logoUrl;
  try {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('configuracoes')
        .doc('logo')
        .get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data()!;
      if (data.containsKey('url') && data['url'] is String) {
        logoUrl = data['url'];
      }
    }
  } catch (e) {
    print('Erro ao buscar URL da logo no Firebase: $e');
  }

  pw.MemoryImage? logoImage = await _loadImageFromUrl(logoUrl);
  pw.MemoryImage? donorSignatureImage = await _loadImageFromUrl(donor.rawData?['assinatura'] as String?);

  final now = DateTime.now();
  final formatter = DateFormat('dd/MM/yyyy - HH:mm\'h\'');
  final formattedTimestamp = formatter.format(now);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logoImage != null)
                pw.Image(logoImage, height: 50, width: 50)
              else
                pw.SizedBox(width: 50, height: 50),
              pw.Text(
                'ID da Doadora: ${donor.id}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.SizedBox(height: 10),

          // Main Title
          pw.Header(
            level: 0,
            child: pw.Center(
              child: pw.Text(
                'Ficha da Doadora para Pareamento',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ),
          pw.SizedBox(height: 10),

          // Match Percentage
          pw.Center(
            child: pw.Text(
              'Porcentagem de Compatibilidade: ${matchPercentage.toStringAsFixed(0)}%',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green700),
            ),
          ),
          pw.SizedBox(height: 15),

          // --- Seção: Informações Pessoais ---
          _buildSection(
            'Informações Pessoais',
            [

              _buildTwoColumnRow([
                _buildInfoField('Idade', donor.idade),
                _buildInfoField('Data de Nascimento', donor.dob),
              ]),

              _buildTwoColumnRow([
                _buildInfoField('Cidade', donor.cidade),
                _buildInfoField('Estado', donor.estado),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Estado Civil', donor.estadoCivil),
                _buildInfoField('Profissão', donor.profissao),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Escolaridade', donor.escolaridade),
                _buildInfoField('Idioma', donor.idioma),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Óvulos Disponíveis', donor.ovulos?.toString()),
              ]),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Seção: Dados Físicos e Fenotípicos ---
          _buildSection(
            'Dados Físicos e Fenotípicos',
            [
              _buildTwoColumnRow([
                _buildInfoField('Peso', donor.pesoKg != null ? '${donor.pesoKg} kg' : null),
                _buildInfoField('Altura', donor.alturaCm != null ? '${donor.alturaCm} cm' : null),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Tipo Sanguíneo', donor.tipoSanguineo),
                _buildInfoField('Cor dos Olhos', donor.corOlhos),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Cor do Cabelo', donor.corCabelo),
                _buildInfoField('Tipo de Cabelo', donor.tipoCabelo),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Raça', donor.raca),
                _buildInfoField('Cor da Pele (Fitzpatrick)', donor.corPeleFitzpatrick),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Formato do Rosto', donor.formatoRosto),
                _buildInfoField('Signo', donor.signo),
              ]),
              _buildInfoField('Características Adicionais', donor.caracteristicas1),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Seção: Estilo de Vida e Interesses ---
          _buildSection(
            'Estilo de Vida e Interesses',
            [
              _buildTwoColumnRow([
                _buildInfoField('Hobbies', donor.hobby),
                _buildInfoField('Atividade Física', donor.atividadeFisica),
              ]),
              _buildInfoField('Qualidades', donor.qualidades),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Seção: Histórico Familiar ---
          _buildSection(
            'Histórico Familiar',
            [
              _buildTwoColumnRow([
                _buildInfoField('Filhos', donor.filhos),
                _buildInfoField('Irmãos', donor.irmaos),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Filha Adotiva', donor.filhaAdotiva),
                _buildInfoField('Gêmeos na Família', donor.gemeos),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Autismo', donor.historicoFamiliarAutismo),
                _buildInfoField('Depressão', donor.historicoFamiliarDepressao),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Esquizofrenia', donor.historicoFamiliarEsquizofrenia),
                _buildInfoField('Anemia Falciforme', donor.historicoFamiliarAnemiaFalciforme),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Talassemia', donor.historicoFamiliarTalassemia),
                _buildInfoField('Fibrose Cística', donor.historicoFamiliarFibroseCistica),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Diabetes Mellitus', donor.historicoFamiliarDiabetesMelittus),
                _buildInfoField('Epilepsia', donor.historicoFamiliarEpilepsia),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Hipertensão', donor.historicoFamiliarHipertensao),
                _buildInfoField('Distrofia Muscular', donor.historicoFamiliarDistrofiaMuscular),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Atrofia Muscular', donor.historicoFamiliarAtrofiaMuscular),
                _buildInfoField('Doença Isquêmica', donor.historicoFamiliarDoencaIsquemica),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Neoplasia', donor.historicoFamiliarNeoplasia),
                _buildInfoField('Deficiência Física', donor.historicoFamiliarDeficienciaFisica),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Deficiência Mental', donor.historicoFamiliarDeficienciaMental),
                _buildInfoField('Doença Genética', donor.historicoFamiliarDoencaGenetica),
              ]),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Seção: Histórico de Saúde da Doadora ---
          _buildSection(
            'Histórico de Saúde da Doadora',
            [
              _buildTwoColumnRow([
                _buildInfoField('Audição', donor.historicoSaudeAudicao),
                _buildInfoField('Visão', donor.historicoSaudeVisao),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Alergia', donor.historicoSaudeAlergia),
                _buildInfoField('Asma', donor.historicoSaudeAsma),
              ]),
              _buildInfoField('Doença Crônica', donor.historicoSaudeDoencaCronica),
              _buildTwoColumnRow([
                _buildInfoField('Fumante', donor.historicoSaudeFumante),
                _buildInfoField('Uso de Drogas', donor.historicoSaudeDrogas),
              ]),
              _buildInfoField('Consumo de Álcool', donor.saudeAlcool),
              pw.SizedBox(height: 10),
              pw.Text('Doenças ou Condições Médicas da Doadora:'),
              _buildTwoColumnRow([
                _buildInfoField('Epilepsia', donor.historicoDoadoraEpilepsia),
                _buildInfoField('Hipertensão', donor.historicoDoadoraHipertensao),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Diabetes Mellitus', donor.historicoDoadoraDiabetesMellitus),
                _buildInfoField('Deficiência Física', donor.historicoDoadoraDeficienciaFisica),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Doenças Genéticas', donor.historicoDoadoraDoencasGeneticas),
                _buildInfoField('Neoplasias', donor.historicoDoadorasNeoplasias),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Lábio Leporino', donor.historicoDoadoraLabioLeporino),
                _buildInfoField('Espinha Bífida', donor.historicoDoadoraEspinhaBifida),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Deficiência Mental', donor.historicoDoadoraDeficienciaMental),
                _buildInfoField('Malformação Cardíaca', donor.historicoDoadoraMalFormacaoCardica),
              ]),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Seção: Exames Realizados ---
          _buildSection(
            'Exames Realizados',
            [
              _buildInfoField('Lista de Exames', donor.exames != null && donor.exames!.isNotEmpty ? donor.exames!.join(', ') : null),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Seção: Informações da Clínica ---
          _buildSection(
            'Informações da Clínica',
            [
              _buildInfoField('Clínica', donor.rawData?['clinica'] as String?),
              _buildInfoField('Médico Assistente', donor.medicoAssistente),
              _buildInfoField('Motivo', donor.motivo),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Seção: Declaração e Observações ---
          _buildSection(
            'Declaração e Observações',
            [
              _buildInfoField('Declaração de Veracidade', donor.declaroVeracidade),
              _buildInfoField('Observação Geral', donor.observacao),
            ],
          ),
          pw.SizedBox(height: 15),


        ];
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

// --- Helper Functions ---

/// Builds a section with a title and content.
pw.Widget _buildSection(String title, List<pw.Widget> content) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Divider(),
      pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey800,
        ),
      ),
      pw.SizedBox(height: 10),
      ...content,
    ],
  );
}

/// Builds a single information field with a label and a value.
/// Displays 'N/A' if the value is null or empty.
pw.Widget _buildInfoField(String label, String? value) {
  return pw.RichText(
    text: pw.TextSpan(
      children: [
        pw.TextSpan(
          text: '$label: ',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
        ),
        pw.TextSpan(
          text: (value != null && value.isNotEmpty) ? value : 'N/A',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    ),
  );
}

/// Builds a row with two columns, distributing space evenly.
pw.Widget _buildTwoColumnRow(List<pw.Widget> fields) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: fields.map((field) => pw.Expanded(child: field)).toList(),
  );
}

/// Builds a grid of photos with labels.
/// This function is provided but not called in the main PDF generation.
/// You can integrate it into your `generateDonorMatchPdf` if you need to display photos.
List<pw.Widget> _buildPhotoGrid(Map<String, pw.MemoryImage?> photos) {
  final List<pw.Widget> photoWidgets = [];

  final Map<String, String> photoLabels = {
    'fotoPrimeiraInfancia': 'Primeira Infância',
    'fotoInfanciaIntermediaria': 'Infância Intermediária',
    'fotoFaseAtual': 'Fase Atual',
    'fotoAdultoInicial': 'Adulto (Inicial)',
    'fotoAdolescenciaInicial': 'Adolescência (Inicial)',
    'fotoAdolescenciaMedia': 'Adolescência (Média)',
    'fotoAdolescenciaFinal': 'Adolescência (Final)',
    'fotoAdultoIntermediario': 'Adulto (Intermediário)',
    'fotoAdulto': 'Adulto (Final)',
    'fotoRecente': 'Mais Recente',
  };

  final List<String> orderedKeys = [
    'fotoPrimeiraInfancia',
    'fotoInfanciaIntermediaria',
    'fotoAdolescenciaInicial',
    'fotoAdolescenciaMedia',
    'fotoAdolescenciaFinal',
    'fotoAdultoInicial',
    'fotoAdultoIntermediario',
    'fotoAdulto',
    'fotoFaseAtual',
    'fotoRecente',
  ];

  for (final key in orderedKeys) {
    final image = photos[key];
    final label = photoLabels[key] ?? key;

    if (image != null) {
      photoWidgets.add(
        pw.Expanded(
          child: pw.Column(
            children: [
              pw.Container(
                height: 120,
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 1),
                  color: PdfColors.grey100,
                ),
                child: pw.Image(
                  image,
                  fit: pw.BoxFit.contain,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                label,
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 10),
            ],
          ),
        ),
      );
    }
  }

  final List<pw.Widget> rows = [];
  for (int i = 0; i < photoWidgets.length; i += 2) {
    if (i + 1 < photoWidgets.length) {
      rows.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            photoWidgets[i],
            pw.SizedBox(width: 10),
            photoWidgets[i + 1],
          ],
        ),
      );
    } else {
      rows.add(
        pw.Row(
          children: [
            photoWidgets[i],
            pw.Spacer(),
          ],
        ),
      );
    }
    rows.add(pw.SizedBox(height: 10));
  }

  return rows;
}