import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // For Uint8List

class UploadLogoPage extends StatefulWidget {
  const UploadLogoPage({super.key});

  @override
  State<UploadLogoPage> createState() => _UploadLogoPageState();
}

class _UploadLogoPageState extends State<UploadLogoPage> {
  XFile? _imageFile;
  Uint8List? _imageBytes; // For displaying newly picked image on web
  String? _currentLogoUrl; // To store the URL of the previously uploaded logo
  bool _loading = false;
  String? _errorMessage;
  bool _fetchingLogo = true; // To indicate if we are fetching the existing logo

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCurrentLogo(); // Fetch the logo when the widget initializes
  }

  Future<void> _fetchCurrentLogo() async {
    setState(() {
      _fetchingLogo = true;
    });
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('configuracoes')
          .doc('logo')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        if (data.containsKey('url') && data['url'] is String) {
          setState(() {
            _currentLogoUrl = data['url'];
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar logo existente: ${e.toString()}';
      });
      debugPrint('Error fetching current logo: $e');
    } finally {
      setState(() {
        _fetchingLogo = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = pickedFile;
          _imageBytes = bytes; // Store bytes for display
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao selecionar imagem: $e';
        _imageBytes = null;
      });
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      setState(() {
        _errorMessage = 'Por favor, selecione uma imagem primeiro.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final Uint8List? imageData = await _imageFile!.readAsBytes();

      if (imageData == null) {
        throw Exception('Não foi possível ler os dados da imagem.');
      }

      final fileName = 'logos/${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.name}';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      await ref.putData(imageData);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('configuracoes').doc('logo').set({
        'url': url,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logo enviado com sucesso!')),
      );

      setState(() {
        _currentLogoUrl = url; // Update the current logo URL
        _imageFile = null;
        _imageBytes = null; // Clear newly picked image after successful upload
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao enviar logo: ${e.toString()}';
      });
      debugPrint('Error uploading image: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageDisplayWidget;

    if (_fetchingLogo) {
      // Show loading indicator while fetching existing logo
      imageDisplayWidget = const CircularProgressIndicator();
    } else if (_imageBytes != null) {
      // Show newly picked image
      imageDisplayWidget = Image.memory(_imageBytes!, height: 150);
    } else if (_currentLogoUrl != null && _currentLogoUrl!.isNotEmpty) {
      // Show previously uploaded logo from URL
      imageDisplayWidget = Image.network(_currentLogoUrl!, height: 150);
    } else {
      // Show "Nenhuma imagem selecionada" if no image is picked and no previous logo exists
      imageDisplayWidget = Container(
        height: 150,
        width: 150,
        color: Colors.grey[200],
        child: Center(
          child: Text(
            'Nenhuma imagem selecionada',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Selecionar Imagem'),
            onPressed: _pickImage,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SizedBox(
              height: 150,
              width: 150, // Ensure fixed size for consistent display
              child: Center(child: imageDisplayWidget),
            ),
          ),
          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _uploadImage,
            child: const Text('Enviar Logo'),
          ),
        ],
      ),
    );
  }
}