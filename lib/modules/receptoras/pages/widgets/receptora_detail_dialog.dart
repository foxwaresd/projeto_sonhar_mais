import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:projeto_sonhar_mais/modules/receptoras/pages/receptora_list_page.dart'; // Ensure Receptora class is accessible
import 'package:projeto_sonhar_mais/modules/receptoras/pages/widgets/receptora_pdf_generator.dart';
import '../../../../core/theme/app_colors.dart'; // Ensure AppColors is accessible

class ReceptoraDetailDialog extends StatefulWidget {
  final Receptora receptora;
  const ReceptoraDetailDialog({required this.receptora, Key? key}) : super(key: key);

  @override
  State<ReceptoraDetailDialog> createState() => _ReceptoraDetailDialogState();
}

class _ReceptoraDetailDialogState extends State<ReceptoraDetailDialog> {
  late TextEditingController nomeController;
  late TextEditingController ovulosController;
  late TextEditingController idadeController;
  late TextEditingController observacaoController;
  late TextEditingController pesoController;
  late TextEditingController alturaController;
  late TextEditingController tipoSanguineoController;
  late TextEditingController olhosController;
  late TextEditingController cabeloCorController;
  late TextEditingController cabeloTexturaController;
  late TextEditingController racaController;
  late TextEditingController pesoCompanheiroController;
  late TextEditingController alturaCompanheiroController;
  late TextEditingController tipoSanguineoCompanheiroController;
  late TextEditingController olhosCompanheiroController;
  late TextEditingController cabeloCorCompanheiroController;
  late TextEditingController cabeloTexturaCompanheiroController;
  late TextEditingController racaCompanheiroController;

  // NOVOS CONTROLLERS PARA DADOS DE CONTATO
  late TextEditingController cepController;
  late TextEditingController telefoneController;
  late TextEditingController cidadeController;
  late TextEditingController enderecoController;
  late TextEditingController estadoController;
  late TextEditingController cpfController;
  late TextEditingController emailController;


  String? newPhotoUrl; // For the main profile photo
  bool isSaving = false;
  bool _isGeneratingPdf = false; // New state variable for PDF generation

  String? _selectedStatus;
  final List<String> _statusOptions = [
    'Iniciando a ficha',
    'Primeira consulta concluída',
    'Aguardando encontrar doadoras',
    'Doadora encontrada',
    'Aguardando aprovação da paciente',
  ];

  final Map<String, String> _photoTimelineFields = {
    'fotoPrimeiraInfancia': 'Primeira Infância',
    'fotoInfanciaIntermediaria': 'Infância Intermediária',
    'fotoAdolescenciaInicial': 'Adolescência Inicial',
    'fotoAdolescenciaMedia': 'Adolescência Média',
    'fotoAdolescenciaFinal': 'Adolescência Final',
    'fotoAdultoInicial': 'Adulto Inicial',
    'fotoAdultoIntermediario': 'Adulto Intermediário',
    'fotoAdulto': 'Adulto',
    'fotoRecente': 'Recente',
    'fotoFaseAtual': 'Fase Atual',
  };

  late Map<String, String> _currentTimelinePhotoUrls;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeStatus();
    _initializeTimelinePhotos();
  }

  void _initializeControllers() {
    nomeController = TextEditingController(text: widget.receptora.nomeCompleto);
    ovulosController = TextEditingController(text: widget.receptora.ovulos);
    idadeController = TextEditingController(text: widget.receptora.idade);
    observacaoController = TextEditingController(text: widget.receptora.observacao);
    pesoController = TextEditingController(text: widget.receptora.peso1Kg?.toString() ?? '');
    alturaController = TextEditingController(text: widget.receptora.altura1Cm?.toString() ?? '');
    tipoSanguineoController = TextEditingController(text: widget.receptora.tipoSanguineo1);
    olhosController = TextEditingController(text: widget.receptora.corOlhos1);
    cabeloCorController = TextEditingController(text: widget.receptora.corCabelo1);
    cabeloTexturaController = TextEditingController(text: widget.receptora.tipoCabelo1);
    racaController = TextEditingController(text: widget.receptora.raca1);

    pesoCompanheiroController = TextEditingController(text: widget.receptora.peso2Kg?.toString() ?? '');
    alturaCompanheiroController = TextEditingController(text: widget.receptora.altura2Cm?.toString() ?? '');
    tipoSanguineoCompanheiroController = TextEditingController(text: widget.receptora.tipoSanguineo2);
    olhosCompanheiroController = TextEditingController(text: widget.receptora.corOlhos2);
    cabeloCorCompanheiroController = TextEditingController(text: widget.receptora.corCabelo2);
    cabeloTexturaCompanheiroController = TextEditingController(text: widget.receptora.tipoCabelo2);
    racaCompanheiroController = TextEditingController(text: widget.receptora.raca2);

    // INICIALIZAÇÃO DOS NOVOS CONTROLLERS DE CONTATO
    cepController = TextEditingController(text: widget.receptora.cep);
    telefoneController = TextEditingController(text: widget.receptora.telefone);
    cidadeController = TextEditingController(text: widget.receptora.cidade);
    enderecoController = TextEditingController(text: widget.receptora.endereco);
    estadoController = TextEditingController(text: widget.receptora.estado);
    cpfController = TextEditingController(text: widget.receptora.cpf);
    emailController = TextEditingController(text: widget.receptora.email);
  }

  void _initializeStatus() {
    _selectedStatus = widget.receptora.status.isNotEmpty ? widget.receptora.status : _statusOptions.first;
  }

  void _initializeTimelinePhotos() {
    _currentTimelinePhotoUrls = {};
    _photoTimelineFields.forEach((firebaseKey, displayName) {
      String? url;
      switch (firebaseKey) {
        case 'fotoPrimeiraInfancia': url = widget.receptora.fotoPrimeiraInfancia; break;
        case 'fotoInfanciaIntermediaria': url = widget.receptora.fotoInfanciaIntermediaria; break;
        case 'fotoFaseAtual': url = widget.receptora.fotoFaseAtual; break;
        case 'fotoAdultoInicial': url = widget.receptora.fotoAdultoInicial; break;
        case 'fotoAdolescenciaInicial': url = widget.receptora.fotoAdolescenciaInicial; break;
        case 'fotoAdolescenciaMedia': url = widget.receptora.fotoAdolescenciaMedia; break;
        case 'fotoAdultoIntermediario': url = widget.receptora.fotoAdultoIntermediario; break;
        case 'fotoAdulto': url = widget.receptora.fotoAdulto; break;
        case 'fotoRecente': url = widget.receptora.fotoRecente; break;
        case 'fotoAdolescenciaFinal': url = widget.receptora.fotoAdolescenciaFinal; break;
      }
      if (url != null && url.isNotEmpty) {
        _currentTimelinePhotoUrls[firebaseKey] = url;
      }
    });
  }

  @override
  void dispose() {
    nomeController.dispose();
    ovulosController.dispose();
    idadeController.dispose();
    observacaoController.dispose();
    pesoController.dispose();
    alturaController.dispose();
    tipoSanguineoController.dispose();
    olhosController.dispose();
    cabeloCorController.dispose();
    cabeloTexturaController.dispose();
    racaController.dispose();

    pesoCompanheiroController.dispose();
    alturaCompanheiroController.dispose();
    tipoSanguineoCompanheiroController.dispose();
    olhosCompanheiroController.dispose();
    cabeloCorCompanheiroController.dispose();
    cabeloTexturaCompanheiroController.dispose();
    racaCompanheiroController.dispose();

    // DISPOSE DOS NOVOS CONTROLLERS DE CONTATO
    cepController.dispose();
    telefoneController.dispose();
    cidadeController.dispose();
    enderecoController.dispose();
    estadoController.dispose();
    cpfController.dispose();
    emailController.dispose();

    super.dispose();
  }

  Future<void> pickNewPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final file = await picked.readAsBytes();
        final storageRef = FirebaseStorage.instance.ref().child('receptora/${widget.receptora.id}/perfil_foto_${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putData(file);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          newPhotoUrl = downloadUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar a foto: $e')),
      );
    }
  }

  Future<void> pickAndUploadTimelinePhoto(String firebaseFieldName) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final fileBytes = await picked.readAsBytes();
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('receptora/${widget.receptora.id}/timeline_photos/${firebaseFieldName}_${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putData(fileBytes);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _currentTimelinePhotoUrls[firebaseFieldName] = downloadUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto de ${_photoTimelineFields[firebaseFieldName]} atualizada!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar foto da linha do tempo: $e')),
      );
    }
  }

  void _showImageDialog(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma foto disponível para esta fase.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          const Text('Não foi possível carregar a imagem.'),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: AppColors.primary),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> saveChanges() async {
    setState(() => isSaving = true);
    try {
      final docRef = FirebaseFirestore.instance.collection('receptora').doc(widget.receptora.id);

      final Map<String, dynamic> updateData = {
        'nomeCompleto': nomeController.text,
        'idade': idadeController.text,
        'observacao': observacaoController.text,
        'peso1': pesoController.text,
        'altura1': alturaController.text,
        'tipoSanguineo1': tipoSanguineoController.text,
        'corOlhos1': olhosController.text,
        'corCabelo1': cabeloCorController.text,
        'tipoCabelo1': cabeloTexturaController.text,
        'raca1': racaController.text,
        'peso2': pesoCompanheiroController.text,
        'altura2': alturaCompanheiroController.text,
        'tipoSanguineo2': tipoSanguineoCompanheiroController.text,
        'corOlhos2': olhosCompanheiroController.text,
        'corCabelo2': cabeloCorCompanheiroController.text,
        'tipoCabelo2': cabeloTexturaCompanheiroController.text,
        'raca2': racaCompanheiroController.text,
        if (newPhotoUrl != null) 'foto': newPhotoUrl,
        'status': _selectedStatus,
        // NOVOS DADOS DE CONTATO NO updateData
        'cep': cepController.text,
        'telefone': telefoneController.text,
        'cidade': cidadeController.text,
        'endereco': enderecoController.text,
        'estado': estadoController.text,
        'cpf': cpfController.text,
        'email': emailController.text,
      };

      _currentTimelinePhotoUrls.forEach((firebaseKey, url) {
        updateData[firebaseKey] = url;
      });

      await docRef.update(updateData);

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar alterações: $e')),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> deleteDoadora() async {
    try {
      await FirebaseFirestore.instance.collection('receptora').doc(widget.receptora.id).delete();
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar: $e')),
      );
    }
  }

  Widget buildSection(String title, List<Widget> fields) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: fields.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: e,
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: _selectedStatus,
                    items: _statusOptions.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    },
                    isExpanded: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showImageDialog(context, newPhotoUrl ?? widget.receptora.fotoPerfil),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          newPhotoUrl ?? widget.receptora.fotoPerfil,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 250, height: 250,
                            color: Colors.grey[200],
                            child: Icon(Icons.person, size: 100, color: Colors.grey[400]),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 250, height: 250,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: pickNewPhoto,
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Alterar Foto de Perfil'),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      TextField(controller: nomeController,
                          decoration: const InputDecoration(labelText: 'Nome Completo')),
                      TextField(controller: ovulosController,
                          decoration: const InputDecoration(labelText: 'Óvulos Desejados')),
                      TextField(controller: observacaoController,
                          maxLines: null,
                          decoration: const InputDecoration(labelText: 'Observação')),
                    ].map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: e,
                    )).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text("Timeline de fotos", style: TextStyle(fontSize: 18),),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120, // Height for the entire timeline section (circles + labels)
              child: Stack(
                children: [
                  // Background timeline bar - positioned behind only the circles
                  Positioned(
                    left: 20, // Match horizontal padding of the SingleChildScrollView
                    right: 20, // Match horizontal padding of the SingleChildScrollView
                    top: 25, // Adjust this value to vertically center it behind the circles (approx. half of circle height - half of bar height)
                    child: Container(
                      height: 20, // Height as requested
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Light grey color
                        borderRadius: BorderRadius.circular(100), // Circular border radius
                      ),
                    ),
                  ),
                  // Scrollable list of photo dots and labels
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 0), // No horizontal padding here, let Row manage spacing
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start, // Align contents to the start (left)
                      crossAxisAlignment: CrossAxisAlignment.start, // Align contents to the top
                      children: _photoTimelineFields.keys.map((firebaseKey) {
                        final displayName = _photoTimelineFields[firebaseKey]!;
                        final imageUrl = _currentTimelinePhotoUrls[firebaseKey];

                        return Container( // Transparent container for each item
                          width: 100, // Adjusted width for readability
                          color: Colors.transparent, // Make it transparent
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0), // Smaller padding within the 100px width
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center, // Center text horizontally
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (imageUrl != null && imageUrl.isNotEmpty) {
                                      _showImageDialog(context, imageUrl);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Nenhuma foto para ${displayName}. Toque e segure para adicionar!'),
                                          action: SnackBarAction(
                                            label: 'Adicionar',
                                            onPressed: () => pickAndUploadTimelinePhoto(firebaseKey),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  onLongPress: () => pickAndUploadTimelinePhoto(firebaseKey),
                                  child: Container(
                                    width: 70, // Smaller circle for aesthetic within 100px width
                                    height: 70, // Smaller circle
                                    decoration: BoxDecoration(
                                      color: imageUrl != null && imageUrl.isNotEmpty ? Colors.transparent : Colors.grey[300],
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primary, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: imageUrl != null && imageUrl.isNotEmpty
                                          ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Icon(Icons.broken_image, size: 35, color: Colors.grey[400]),
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      )
                                          : Icon(Icons.add_a_photo, size: 35, color: Colors.grey[400]),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4), // Reduced spacing
                                Text(
                                  displayName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 10, color: Colors.grey[700]), // Smaller font size
                                  maxLines: 2, // Allow text to wrap if needed
                                  overflow: TextOverflow.ellipsis, // Add ellipsis if it still overflows
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 24),

            buildSection("Dados Pessoais da Receptora", [
              TextField(controller: idadeController,
                  decoration: const InputDecoration(labelText: 'Idade')),
              TextField(controller: pesoController,
                  decoration: const InputDecoration(labelText: 'Peso (Kg)')),
              TextField(controller: alturaController,
                  decoration: const InputDecoration(labelText: 'Altura (cm)')),
              TextField(controller: tipoSanguineoController,
                  decoration: const InputDecoration(labelText: 'Tipo Sanguíneo')),
              TextField(controller: olhosController,
                  decoration: const InputDecoration(labelText: 'Cor dos Olhos')),
              TextField(controller: cabeloCorController,
                  decoration: const InputDecoration(labelText: 'Cor do Cabelo')),
              TextField(controller: cabeloTexturaController,
                  decoration: const InputDecoration(labelText: 'Textura do Cabelo')),
              TextField(controller: racaController,
                  decoration: const InputDecoration(labelText: 'Raça')),
            ]),

            buildSection("Dados Pessoais do Companheiro", [
              TextField(controller: pesoCompanheiroController,
                  decoration: const InputDecoration(labelText: 'Peso (Kg)')),
              TextField(controller: alturaCompanheiroController,
                  decoration: const InputDecoration(labelText: 'Altura (cm)')),
              TextField(controller: tipoSanguineoCompanheiroController,
                  decoration: const InputDecoration(labelText: 'Tipo Sanguíneo')),
              TextField(controller: olhosCompanheiroController,
                  decoration: const InputDecoration(labelText: 'Cor dos Olhos')),
              TextField(controller: cabeloCorCompanheiroController,
                  decoration: const InputDecoration(labelText: 'Cor do Cabelo')),
              TextField(controller: cabeloTexturaCompanheiroController,
                  decoration: const InputDecoration(labelText: 'Textura do Cabelo')),
              TextField(controller: racaCompanheiroController,
                  decoration: const InputDecoration(labelText: 'Raça')),
            ]),

            // SEÇÃO NOVOS DADOS DE CONTATO
            buildSection("Dados de Contato", [
              TextField(controller: cepController,
                  decoration: const InputDecoration(labelText: 'CEP')),
              TextField(controller: telefoneController,
                  decoration: const InputDecoration(labelText: 'Telefone')),
              TextField(controller: cidadeController,
                  decoration: const InputDecoration(labelText: 'Cidade')),
              TextField(controller: enderecoController,
                  decoration: const InputDecoration(labelText: 'Endereço')),
              TextField(controller: estadoController,
                  decoration: const InputDecoration(labelText: 'Estado')),
              TextField(controller: cpfController,
                  decoration: const InputDecoration(labelText: 'CPF')),
              TextField(controller: emailController,
                  decoration: const InputDecoration(labelText: 'E-mail')),
            ]),

            const SizedBox(height: 24),

            if (isSaving) const CircularProgressIndicator() else Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Confirmar exclusão'),
                        content: const Text('Tem certeza que deseja deletar esta receptora?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await deleteDoadora();
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.white,),
                  label: const Text('Deletar', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      // Disable the button while PDF is being generated
                      onPressed: _isGeneratingPdf ? null : () async {
                        setState(() {
                          _isGeneratingPdf = true; // Set loading state to true
                        });
                        try {
                          await generateReceptoraPdf(widget.receptora);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao gerar PDF: $e')),
                          );
                        } finally {
                          setState(() {
                            _isGeneratingPdf = false; // Set loading state to false
                          });
                        }
                      },
                      icon: _isGeneratingPdf
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.picture_as_pdf),
                      label: Text(_isGeneratingPdf ? 'Gerando...' : 'Gerar PDF'),
                    ),
                    const SizedBox(width: 10,),
                    ElevatedButton.icon(
                      onPressed: saveChanges,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}