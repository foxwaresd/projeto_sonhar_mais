import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;
import 'dart:js_util' as js_util;
import 'package:js/js.dart' as js;

// TODO: Verifique se este é o caminho correto para o seu arquivo de cores.
import '../../../../core/theme/app_colors.dart';


class CustomWebCameraPage extends StatefulWidget {
  final String appBarTitle;
  final bool centerTitle;

  const CustomWebCameraPage({
    Key? key,
    this.appBarTitle = "Centralize seu Rosto",
    this.centerTitle = true,
  }) : super(key: key);

  @override
  _CustomWebCameraPageState createState() => _CustomWebCameraPageState();
}

class _CustomWebCameraPageState extends State<CustomWebCameraPage> {
  SimpleWebCameraController? _cameraController;
  bool _isCameraInitialized = false;
  String _errorMessage = '';
  Uint8List? _capturedImageBytes;
  bool _isFaceCentralized = false;
  Color _ovalBorderColor = AppColors.primary;
  String _feedbackMessage = 'Posicione seu rosto na oval';

  @override
  void initState() {
    super.initState();
    _initializeAndListen();
  }

  void _handleFaceDetectionEvent(html.Event event) {
    if (!mounted) return;

    final customEvent = event as html.CustomEvent;
    final detail = customEvent.detail;

    setState(() {
      switch (detail) {
        case 1: // Rosto centralizado
          _isFaceCentralized = true;
          _ovalBorderColor = Colors.green;
          _feedbackMessage = 'Rosto centralizado!';
          break;
        case 0: // Rosto não centralizado
          _isFaceCentralized = false;
          _ovalBorderColor = AppColors.primary;
          _feedbackMessage = 'Posicione seu rosto na oval';
          break;
        case -1: // Erro na inicialização do JS
          _isFaceCentralized = false;
          _ovalBorderColor = Colors.red;
          _feedbackMessage = 'Erro ao iniciar detecção.';
          _errorMessage = 'Falha ao carregar os modelos de detecção facial. Verifique o console do navegador.';
          break;
      }
    });
  }

  void _initializeAndListen() {
    _cameraController = SimpleWebCameraController(
      onVideoReady: _onVideoElementReady,
    );
    _initializeCamera();

    final eventTarget = js_util.getProperty(html.window, '_flutter_face_detection_channel');
    js_util.callMethod(eventTarget, 'addEventListener', [
      'message',
      js.allowInterop(_handleFaceDetectionEvent),
    ]);
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Falha ao iniciar a câmera: ${e.toString()}';
        });
      }
    }
  }

  void _onVideoElementReady(String videoId) {
    js_util.callMethod(html.window, 'startFaceDetection', [videoId]);
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized || !_isFaceCentralized) return;

    try {
      final imageBytes = await _cameraController!.takePicture();
      if (imageBytes != null) {
        setState(() {
          _capturedImageBytes = imageBytes;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao capturar a imagem: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    js_util.callMethod(html.window, 'stopFaceDetection', []);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.appBarTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (!_isCameraInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.appBarTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        centerTitle: widget.centerTitle,
        actions: [
          if (_capturedImageBytes != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => Navigator.pop(context, _capturedImageBytes),
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Câmera no fundo, ocupando toda a tela
          if (_capturedImageBytes == null)
            Positioned.fill(
              child: HtmlElementView(viewType: _cameraController!.viewId),
            ),

          // 2. MÁSCARA BRANCA COM RECORTE OVAL
          // O ClipPath cria um "buraco" em um container branco, revelando a câmera por baixo.
          ClipPath(
            clipper: InvertedOvalClipper(),
            child: Container(
              color: Colors.white,
            ),
          ),

          // 3. BORDA GUIA DESENHADA SOBRE A MÁSCARA
          // Usamos IgnorePointer para que a borda não bloqueie toques
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: OvalBorderPainter(borderColor: _ovalBorderColor),
            ),
          ),

          if (_capturedImageBytes != null)
            Positioned.fill(
              child: Image.memory(_capturedImageBytes!, fit: BoxFit.cover),
            ),

          // 4. UI de feedback e botão
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _feedbackMessage,
                      style: TextStyle(
                        color: _isFaceCentralized ? Colors.green : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: _isFaceCentralized ? _takePicture : null,
                    backgroundColor: _isFaceCentralized ? AppColors.primary : Colors.grey.withOpacity(0.8),
                    child: _isFaceCentralized
                        ? const Icon(Icons.camera_alt, color: Colors.white)
                        : const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleWebCameraController extends ValueNotifier<bool> {
  html.MediaStream? _mediaStream;
  html.VideoElement? _videoElement;
  final String _viewId = 'camera_view_${DateTime.now().microsecondsSinceEpoch}';
  Function(String videoId)? onVideoReady;

  SimpleWebCameraController({this.onVideoReady}) : super(false);

  Future<void> initialize() async {
    try {
      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({'video': {'facingMode': 'user'}});
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..srcObject = _mediaStream
        ..id = _viewId
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      _videoElement!.setAttribute('playsinline', 'true');
      _videoElement!.setAttribute('webkit-playsinline', 'true');

      ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) => _videoElement!);

      await _videoElement!.onLoadedData.first;
      value = true;
      onVideoReady?.call(_viewId);

    } catch (e) {
      value = false;
      rethrow;
    }
  }

  Future<Uint8List?> takePicture() async {
    if (_videoElement == null || !value) return null;

    final canvas = html.CanvasElement(width: _videoElement!.videoWidth, height: _videoElement!.videoHeight);
    canvas.context2D.drawImage(_videoElement!, 0, 0);
    final dataUrl = canvas.toDataUrl('image/jpeg', 0.90);

    return base64Decode(dataUrl.split(',')[1]);
  }

  @override
  void dispose() {
    _mediaStream?.getTracks().forEach((track) => track.stop());
    super.dispose();
  }

  String get viewId => _viewId;
}

// NOVO CLIPPER para criar um "buraco" oval em um widget
class InvertedOvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Define o retângulo do oval que será o "buraco"
    final ovalRect = Rect.fromCenter(center: size.center(Offset.zero), width: 250, height: 350);

    // Path.combine não funciona bem para clipping, então usamos a regra evenOdd
    return Path()
    // Adiciona o retângulo de toda a área
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
    // Adiciona o oval que será o nosso buraco
      ..addOval(ovalRect)
    // A regra evenOdd cria um buraco onde os caminhos se sobrepõem
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// NOVO PAINTER que desenha APENAS a borda, para ficar sobre a máscara
class OvalBorderPainter extends CustomPainter {
  final Color borderColor;
  const OvalBorderPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final ovalRect = Rect.fromCenter(center: size.center(Offset.zero), width: 250, height: 350);

    // Desenha apenas a borda do oval
    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = borderColor
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant OvalBorderPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}