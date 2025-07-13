import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Import your Receptora model
// Make sure this path is correct for your project!
import '../receptora_list_page.dart'; // Assuming Receptora class is defined here
// If Receptora is in a separate model file, change this to:
// import '../models/receptora.dart';

// Helper function to load image from URL
Future<pw.MemoryImage?> _loadImageFromUrl(String? url) async {
  if (url == null || url.isEmpty) {
    return null;
  }
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return pw.MemoryImage(response.bodyBytes);
    } else {
      print('Falha ao carregar imagem da URL: ${response.statusCode} - $url');
      return null;
    }
  } catch (e) {
    print('Erro ao carregar imagem da URL: $e - $url');
    return null;
  }
}

Future<void> generateReceptoraPdf(Receptora receptora) async {
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

  // --- Load Logo Image from URL (if available) ---
  // Using the new helper function
  pw.MemoryImage? logoImage = await _loadImageFromUrl(logoUrl);

  // --- Load Signature Image from URL (if available) ---
  // Using the new helper function
  pw.MemoryImage? signatureImage = await _loadImageFromUrl(receptora.assinatura);

  // --- Load Profile Picture (fotoPerfil) if available ---
  // Using the new helper function
  pw.MemoryImage? profileImage = await _loadImageFromUrl(receptora.fotoPerfil);

  // --- Load all additional photos ---
  final Map<String, pw.MemoryImage?> additionalPhotos = {
    'fotoPrimeiraInfancia': await _loadImageFromUrl(receptora.fotoPrimeiraInfancia),
    'fotoInfanciaIntermediaria': await _loadImageFromUrl(receptora.fotoInfanciaIntermediaria),
    'fotoFaseAtual': await _loadImageFromUrl(receptora.fotoFaseAtual),
    'fotoAdultoInicial': await _loadImageFromUrl(receptora.fotoAdultoInicial),
    'fotoAdolescenciaInicial': await _loadImageFromUrl(receptora.fotoAdolescenciaInicial),
    'fotoAdolescenciaMedia': await _loadImageFromUrl(receptora.fotoAdolescenciaMedia),
    'fotoAdultoIntermediario': await _loadImageFromUrl(receptora.fotoAdultoIntermediario),
    'fotoAdulto': await _loadImageFromUrl(receptora.fotoAdulto),
    'fotoRecente': await _loadImageFromUrl(receptora.fotoRecente),
    'fotoAdolescenciaFinal': await _loadImageFromUrl(receptora.fotoAdolescenciaFinal),
  };

  // --- Get current timestamp ---
  final now = DateTime.now();
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
                pw.SizedBox(width: 50, height: 50),

              // Patient ID (document ID) on the top right
              pw.Text(
                'ID da Paciente: ${receptora.id}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.SizedBox(height: 10),

          // Main Document Title
          pw.Header(
            level: 0,
            child: pw.Center(
              child: pw.Text(
                'Ficha Médica da Receptora',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 10),

          // Receptora Status - Moved inside the basic info column for compactness
          // pw.Center(
          //   child: pw.Text(
          //     'Status: ${receptora.status}',
          //     style: pw.TextStyle(
          //       fontSize: 14,
          //       fontWeight: pw.FontWeight.bold,
          //       color: PdfColors.blueGrey800,
          //     ),
          //   ),
          // ),
          // pw.SizedBox(height: 15),

          // --- Profile Picture and Basic Info Row ---
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Profile Picture on the left
              if (profileImage != null)
                pw.Container(
                  height: 100,
                  width: 100,
                  margin: const pw.EdgeInsets.only(right: 20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300, width: 1),
                    shape: pw.BoxShape.circle,
                    image: pw.DecorationImage(
                      image: profileImage,
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                )
              else
                pw.Container(
                  height: 100,
                  width: 100,
                  margin: const pw.EdgeInsets.only(right: 20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300, width: 1),
                    shape: pw.BoxShape.circle,
                    color: PdfColors.grey100,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'Sem Foto',
                      style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                    ),
                  ),
                ),

              // Basic Info on the right
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoField('Nome Completo', receptora.nomeCompleto),
                    _buildInfoField('Idade', receptora.idade),
                    _buildInfoField('Email', receptora.email),
                    _buildInfoField('Telefone', receptora.telefone),
                    _buildInfoField('CPF', receptora.cpf),
                    _buildInfoField('RG', receptora.rg),
                    _buildInfoField('Status', receptora.status), // Added status here
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // --- Dados de Contato e Endereço ---
          _buildSection(
            'Dados de Contato e Endereço',
            [
              _buildInfoField('Endereço', receptora.endereco),
              _buildTwoColumnRow([
                _buildInfoField('CEP', receptora.cep),
                _buildInfoField('Cidade', receptora.cidade),
              ]),
              _buildInfoField('Estado', receptora.estado),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Dados Físicos ---
          _buildSection(
            'Dados Físicos',
            [
              _buildTwoColumnRow([
                _buildInfoField('Peso Original', '${receptora.pesoOriginal ?? 'N/A'} kg'),
                _buildInfoField('Altura Original', '${receptora.alturaOriginal ?? 'N/A'} m'),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Peso Ideal (kg)', _formatDouble(receptora.peso1Kg)),
                _buildInfoField('Peso Máximo (kg)', _formatDouble(receptora.peso2Kg)),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Altura Mínima (cm)', _formatDouble(receptora.altura1Cm, append: ' cm')),
                _buildInfoField('Altura Máxima (cm)', _formatDouble(receptora.altura2Cm, append: ' cm')),
              ]),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Preferências para Pareamento ---
          _buildSection(
            'Preferências para Pareamento',
            [
              _buildTwoColumnRow([
                _buildInfoField('Tipo Sanguíneo', receptora.tipoSanguineo1 ?? 'N/A'),
                _buildInfoField('Tipo Sanguíneo Cônjuge', receptora.tipoSanguineo2 ?? 'N/A'),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Cor dos Olhos', receptora.corOlhos1 ?? 'N/A'),
                _buildInfoField('Cor dos Olhos Cônjuge', receptora.corOlhos2 ?? 'N/A'),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Cor do Cabelo', receptora.corCabelo1 ?? 'N/A'),
                _buildInfoField('Cor do Cabelo Cônjuge', receptora.corCabelo2 ?? 'N/A'),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Tipo de Cabelo', receptora.tipoCabelo1 ?? 'N/A'),
                _buildInfoField('Tipo de Cabelo Cônjuge', receptora.tipoCabelo2 ?? 'N/A'),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Raça', receptora.raca1 ?? 'N/A'),
                _buildInfoField('Raça Cônjuge', receptora.raca2 ?? 'N/A'),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Cor da Pele Fitzpatrick', receptora.corPeleFitzpatrick1 ?? 'N/A'),
                _buildInfoField('Cor da Pele Fitzpatrick Cônjuge', receptora.corPeleFitzpatrick2 ?? 'N/A'),
              ]),
              _buildTwoColumnRow([
                _buildInfoField('Características Adicionais', receptora.caracteristicas1),
                _buildInfoField('Características Adicionais Cônjuge', receptora.caracteristicas2),
              ]),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Photos Section ---
          if (additionalPhotos.values.any((image) => image != null)) // Only show section if there's at least one photo
            _buildSection(
              'Fotos da Receptora em Diferentes Fases',
              _buildPhotoGrid(additionalPhotos),
            ),
          pw.SizedBox(height: 15),

          // --- Informações Administrativas e Detalhes da Doação ---
          _buildSection(
            'Informações Administrativas e Detalhes da Doação',
            [
              _buildInfoField('Clínica', receptora.clinica),
              _buildInfoField('Médico Assistente', receptora.medicoAssistente),
              _buildInfoField('Óvulos Coletados', receptora.ovulos),
              _buildInfoField('Declaração de Veracidade', receptora.declaroVeracidade),
            ],
          ),
          pw.SizedBox(height: 15),

          // --- Observações Gerais ---
          _buildSection(
            'Observações Gerais',
            [
              _buildInfoField('Observação', receptora.observacao),
            ],
          ),
        ];
      },
      // --- Footer for Signature (only on last page) and Timestamp (on all pages) ---
      footer: (pw.Context context) {
        return pw.Column(
          children: [
            // Only show signature, divider, and name on the last page
            if (context.pageNumber == context.pagesCount)
              pw.Column(
                children: [
                  pw.SizedBox(height: 15), // Space above signature section on last page
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
                      receptora.nomeCompleto, // Use nomeCompleto for signature line
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(height: 5), // Space below the name
                  pw.Center(
                    child: pw.Text(
                      formattedTimestamp,
                      style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                    ),
                  ),
                  pw.SizedBox(height: 10), // Space before timestamp
                ],
              ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

// --- Helper Functions (keep these outside the main function) ---

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

// Helper to format double values, handling nulls and adding optional suffix
String _formatDouble(double? value, {String append = ''}) {
  if (value == null) {
    return 'N/A';
  }
  // Format to one decimal place if it's a whole number, otherwise two.
  if (value == value.toInt()) {
    return '${value.toInt()}$append';
  }
  return '${value.toStringAsFixed(1)}$append';
}

// New helper function to build the photo grid
List<pw.Widget> _buildPhotoGrid(Map<String, pw.MemoryImage?> photos) {
  final List<pw.Widget> photoWidgets = [];

  // Define a mapping from photo field names to user-friendly labels
  final Map<String, String> photoLabels = {
    'fotoPrimeiraInfancia': 'Primeira Infância',
    'fotoInfanciaIntermediaria': 'Infância Intermediária',
    'fotoFaseAtual': 'Fase Atual',
    'fotoAdultoInicial': 'Adulto (Inicial)',
    'fotoAdolescenciaInicial': 'Adolescência (Inicial)',
    'fotoAdolescenciaMedia': 'Adolescência (Média)',
    'fotoAdultoIntermediario': 'Adulto (Intermediário)',
    'fotoAdulto': 'Adulto (Final)', // Assuming 'fotoAdulto' is the final adult photo
    'fotoRecente': 'Mais Recente',
    'fotoAdolescenciaFinal': 'Adolescência (Final)',
  };

  // Order the photos logically for display
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
    final label = photoLabels[key] ?? key; // Fallback to key if label not found

    if (image != null) {
      photoWidgets.add(
        pw.Expanded(
          child: pw.Column(
            children: [
              pw.Container(
                height: 120, // Fixed height for photos
                width: double.infinity, // Take available width
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 1),
                  color: PdfColors.grey100,
                ),
                child: pw.Image(
                  image,
                  fit: pw.BoxFit.contain, // Use contain to show whole image
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                label,
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 10), // Space after each photo column
            ],
          ),
        ),
      );
    }
  }

  // Group photos into rows (2 per row)
  final List<pw.Widget> rows = [];
  for (int i = 0; i < photoWidgets.length; i += 2) {
    if (i + 1 < photoWidgets.length) {
      // Two photos in a row
      rows.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            photoWidgets[i],
            pw.SizedBox(width: 10), // Space between photos in a row
            photoWidgets[i + 1],
          ],
        ),
      );
    } else {
      // Last photo, if it's an odd number
      rows.add(
        pw.Row(
          children: [
            photoWidgets[i],
            pw.Spacer(), // Push the single photo to the left
          ],
        ),
      );
    }
    rows.add(pw.SizedBox(height: 10)); // Space between rows
  }

  return rows;
}