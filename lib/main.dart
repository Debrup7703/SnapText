import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Text Extractor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TextExtractorScreen(),
    );
  }
}

class TextExtractorScreen extends StatefulWidget {
  const TextExtractorScreen({super.key});

  @override
  State<TextExtractorScreen> createState() => _TextExtractorScreenState();
}

class _TextExtractorScreenState extends State<TextExtractorScreen> {
  File? _imageFile;
  String _extractedText = '';
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the specified source (gallery or camera).
  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isProcessing = true;
      _imageFile = null;
      _extractedText = '';
    });

    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      await _extractTextFromImage(_imageFile!);
    }
    
    setState(() {
      _isProcessing = false;
    });
  }

  /// Extracts text from the provided image file using Google ML Kit.
  Future<void> _extractTextFromImage(File imageFile) async {
    try {
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      setState(() {
        _extractedText = recognizedText.text;
      });
      
      textRecognizer.close();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error extracting text: $e')),
      );
      setState(() {
        _extractedText = 'Failed to extract text.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Text Extractor'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Image Preview Area ---
            Container(
              height: 250,
              margin: const EdgeInsets.only(bottom: 20.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade100, width: 2),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Select or capture an image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),

            // --- Action Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // --- Extracted Text Area ---
            const Text(
              'Extracted Text:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _extractedText.isEmpty
                      ? 'Text will appear here...'
                      : _extractedText,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

