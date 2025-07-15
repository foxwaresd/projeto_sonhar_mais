import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../doadora_list_page.dart'; // Or the correct path to your model

Future<void> generateDoadoraPdf(Doadora doadora) async {
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
    // Consider adding a default placeholder or showing an error message in UI
  }

  // --- Load Logo Image from URL (if available) ---
  pw.MemoryImage? logoImage;
  if (logoUrl != null && logoUrl.isNotEmpty) {
    try {
      final response = await http.get(Uri.parse(logoUrl));
      if (response.statusCode == 200) {
        logoImage = pw.MemoryImage(response.bodyBytes);
      } else {
        print('Falha ao carregar a imagem da URL da logo: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar a imagem da logo da URL: $e');
    }
  }

  // --- Load Signature Image from URL (if available) ---
  pw.MemoryImage? signatureImage;
  if (doadora.assinatura.isNotEmpty) { // Assuming doadora.assinatura holds the URL
    try {
      final response = await http.get(Uri.parse(doadora.assinatura));
      if (response.statusCode == 200) {
        signatureImage = pw.MemoryImage(response.bodyBytes);
      } else {
        print('Falha ao carregar a imagem da URL da assinatura: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar a imagem da assinatura da URL: $e');
    }
  }

  // --- Get current timestamp ---
  final now = DateTime.now();
  // Using 'dd/MM/yyyy - HH:mm\'h\'' for 24-hour format with 'h' suffix
  final formatter = DateFormat('dd/MM/yyyy - HH:mm\'h\'');
  final formattedTimestamp = formatter.format(now);


  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          // Header Row for Logo and Patient ID
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo on the top left
              if (logoImage != null)
                pw.Image(
                  logoImage,
                  height: 50,
                  width: 50,
                )
              else
                pw.SizedBox(width: 50, height: 50), // Placeholder if logo not found/loaded

              // Patient ID (document ID) on the top right
              pw.Text(
                'ID da Paciente: ${doadora.id}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.SizedBox(height: 10), // Spacing between header elements and main title

          // Main Document Title
          pw.Header(
            level: 0,
            child: pw.Center(
              child:
              pw.SizedBox(
                height: 40,
                child: pw.Text(
                'Ficha Médica da Doadora',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              ),
            ),
          ),
          pw.SizedBox(height: 10), // Reduced space after main title

          // Doadora Status - Centered below main title
          pw.Center(
            child: pw.Text(
              'Status: ${doadora.status}', // Correctly display status as a simple text
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey, // You can choose a color
              ),
            ),
          ),
          pw.SizedBox(height: 15), // Space after status

          // --- Dados Pessoais ---
          _buildSection(
            'Dados Pessoais',
            [
              _buildTwoColumnRow([
                _buildInfoField('Nome', doadora.nome),
                _buildInfoField('Idade', doadora.idade),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Data de Nascimento', doadora.dob),
                _buildInfoField('CPF', doadora.cpf),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('RG', doadora.rg),
                _buildInfoField('Email', doadora.email),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Telefone', doadora.telefone),
                _buildInfoField('CEP', doadora.cep),
              ]),
              _buildInfoField('Endereço', doadora.endereco),
              _buildTwoColumnRow([
                _buildInfoField('Cidade', doadora.cidade),
                _buildInfoField('Estado', doadora.estado),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Peso', '${doadora.peso} kg'),
                _buildInfoField('Altura', '${doadora.altura} m'),
              ]),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Dados Fenotípicos ---
          _buildSection(
            'Dados Fenotípicos',
            [
              _buildTwoColumnRow([
                _buildInfoField('Tipo Sanguíneo', doadora.tipoSanguineo),
                _buildInfoField('Olhos', doadora.olhos),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Cor do Cabelo', doadora.cabeloCor),
                _buildInfoField('Textura do Cabelo', doadora.cabeloTextura),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Raça', doadora.raca),
                _buildInfoField('Signo', doadora.signo),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Escala Fitzpatrick', doadora.fitzpatrick),
                _buildInfoField('Formato do Rosto', doadora.formatoRosto),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Idioma', doadora.idioma),
                _buildInfoField('Características Adicionais', doadora.caracteristicas1),
              ]),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Contexto Social e Estilo de Vida ---
          _buildSection(
            'Contexto Social e Estilo de Vida',
            [
              _buildTwoColumnRow([
                _buildInfoField('Profissão', doadora.profissao),
                _buildInfoField('Hobby', doadora.hobby),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Atividade Física', doadora.atividadeFisica),
                _buildInfoField('Escolaridade', doadora.escolaridade),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Estado Civil', doadora.estadoCivil),
                _buildInfoField('Filhos', doadora.filhos),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Irmãos', doadora.irmaos),
                _buildInfoField('Filha Adotiva', doadora.filhaAdotiva),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Gêmeos na Família', doadora.gemeos),
              ]),
              _buildInfoField('Qualidades Pessoais', doadora.qualidades),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Histórico de Saúde Pessoal ---
          _buildSection(
            'Histórico de Saúde Pessoal',
            [
              _buildTwoColumnRow([
                _buildInfoField('Saúde Auditiva', doadora.historicoSaudeAudicao),
                _buildInfoField('Saúde Visual', doadora.historicoSaudeVisao),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Alergias', doadora.historicoSaudeAlergia),
                _buildInfoField('Asma', doadora.historicoSaudeAsma),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Doença Crônica', doadora.historicoSaudeDoencaCronica),
                _buildInfoField('Fumante', doadora.historicoSaudeFumante),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Uso de Drogas', doadora.historicoSaudeDrogas),
                _buildInfoField('Uso de Álcool', doadora.saudeAlcool),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Epilepsia (Doadora)', doadora.historicoDoadoraEpilepsia),
                _buildInfoField('Hipertensão (Doadora)', doadora.historicoDoadoraHipertensao),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Diabetes Mellitus (Doadora)', doadora.historicoDoadoraDiabetesMellitus),
                _buildInfoField('Deficiência Física (Doadora)', doadora.historicoDoadoraDeficienciaFisica),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Doenças Genéticas (Doadora)', doadora.historicoDoadoraDoencasGeneticas),
                _buildInfoField('Neoplasias (Doadora)', doadora.historicoDoadorasNeoplasias),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Lábio Leporino (Doadora)', doadora.historicoDoadoraLabioLeporino),
                _buildInfoField('Espinha Bífida (Doadora)', doadora.historicoDoadoraEspinhaBifida),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Deficiência Mental (Doadora)', doadora.historicoDoadoraDeficienciaMental),
                _buildInfoField('Malformação Cardíaca (Doadora)', doadora.historicoDoadoraMalFormacaoCardica),
              ]),
              _buildInfoField('Observações Gerais de Saúde', doadora.observacao),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Histórico Familiar de Doenças ---
          _buildSection(
            'Histórico Familiar de Doenças',
            [
              _buildInfoField('Doenças Genéticas na Família', doadora.historicoFamiliarDoencaGenetica),
              _buildTwoColumnRow([
                _buildInfoField('Autismo na Família', doadora.historicoFamiliarAutismo),
                _buildInfoField('Depressão na Família', doadora.historicoFamiliarDepressao),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Esquizofrenia na Família', doadora.historicoFamiliarEsquizofrenia),
                _buildInfoField('Anemia Falciforme na Família', doadora.historicoFamiliarAnemiaFalciforme),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Talassemia na Família', doadora.historicoFamiliarTalassemia),
                _buildInfoField('Fibrose Cística na Família', doadora.historicoFamiliarFibroseCistica),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Diabetes Mellitus na Família', doadora.historicoFamiliarDiabetesMelittus),
                _buildInfoField('Epilepsia na Família', doadora.historicoFamiliarEpilepsia),
              ]),
              pw.SizedBox(height: 5),
              _buildTwoColumnRow([
                _buildInfoField('Hipertensão na Família', doadora.historicoFamiliarHipertensao),
                _buildInfoField('Distrofia Muscular na Família', doadora.historicoFamiliarDistrofiaMuscular),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Atrofia Muscular na Família', doadora.historicoFamiliarAtrofiaMuscular),
                _buildInfoField('Doença Isquêmica na Família', doadora.historicoFamiliarDoencaIsquemica),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Neoplasia na Família', doadora.historicoFamiliarNeoplasia),
                _buildInfoField('Deficiência Física na Família', doadora.historicoFamiliarDeficienciaFisica),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Deficiência Mental na Família', doadora.historicoFamiliarDeficienciaMental),
              ]),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Informações Adicionais e Administrativas ---
          _buildSection(
            'Informações Adicionais e Administrativas',
            [
              _buildInfoField('Exames Realizados', doadora.exames.join(', ')),
              _buildTwoColumnRow([
                _buildInfoField('Médico Assistente', doadora.medicoAssistente),
                _buildInfoField('Motivo da Doação', doadora.motivo),
              ]),
              _buildInfoField('Declaração de Veracidade', doadora.declaroVeracidade),
            ],
          ),
        ];
      },
      // --- Footer for Timestamp (on all pages) and Signature (only on last page) ---
      footer: (pw.Context context) {
        return pw.Column(
          children: [
            // Only show signature, divider, and name on the last page
            if (context.pageNumber == context.pagesCount)
              pw.Column(
                children: [
                  pw.SizedBox(height: 5), // Space between timestamp and signature
                  if (signatureImage != null)
                    pw.Center(
                      child: pw.Image(
                        signatureImage,
                        height: 80,
                        width: 200,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  pw.Divider(),
                  pw.Center(
                    child: pw.Text(
                      doadora.nome,
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(height: 5), // Space below the name
                  pw.Center(
                    child: pw.Text(
                      formattedTimestamp, // Display the formatted timestamp
                      style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                    ),
                  ),
                ],
              ),
            pw.SizedBox(height: 10), // Space at the very bottom
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

// Helper functions remain the same
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

pw.Widget _buildInfoField(String label, String value) {
  return pw.RichText(
    text: pw.TextSpan(
      children: [
        pw.TextSpan(
          text: '$label: ',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
        ),
        pw.TextSpan(
          text: value.isNotEmpty ? value : 'N/A',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    ),
  );
}

pw.Widget _buildTwoColumnRow(List<pw.Widget> fields) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: fields.map((field) => pw.Expanded(child: field)).toList(),
  );
}