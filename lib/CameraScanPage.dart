import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'AnimalInfoPage.dart';

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({Key? key}) : super(key: key);

  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  String _recognizedResult = 'Scan result will appear here';
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(
        _cameras.first,
        ResolutionPreset.high,
      );
      await _cameraController.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _analyzeImage(File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      if (_cameraController.value.isInitialized) {
        final image = await _cameraController.takePicture();
        setState(() {
          _selectedImage = File(image.path);
        });
        await _analyzeImage(File(image.path));
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  Future<void> _analyzeImage(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final imageLabeler = GoogleMlKit.vision.imageLabeler();
      final labels = await imageLabeler.processImage(inputImage);

      if (labels.isNotEmpty) {
        setState(() {
          _recognizedResult = labels
              .map((label) =>
          '${label.label} (${(label.confidence * 100).toStringAsFixed(1)}%)')
              .join('\n');
        });

        // Send the first tag passed to AnimalInfoPage
        final firstLabel = labels.first.label;
        _navigateToInfoPage(firstLabel);
      } else {
        setState(() {
          _recognizedResult = 'No recognizable items found.';
        });
      }

      imageLabeler.close();
    } catch (e) {
      print('Error analyzing image: $e');
      setState(() {
        _recognizedResult = 'Error analyzing image.';
      });
    }
  }

  void _navigateToInfoPage(String animalType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalInfoPage(animalType: animalType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Scan'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedImage == null
                ? (_isCameraInitialized
                ? CameraPreview(_cameraController)
                : const Center(child: CircularProgressIndicator()))
                : Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[200],
            width: double.infinity,
            child: Text(
              _recognizedResult,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera),
                  label: const Text('Take Photo'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo),
                  label: const Text('Select from Gallery'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}