import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/services.dart'; // Import for Clipboard functionality
import 'dart:io';

class ImageToTextConverter extends StatefulWidget {
  const ImageToTextConverter({super.key});

  @override
  _ImageToTextConverterState createState() => _ImageToTextConverterState();
}

class _ImageToTextConverterState extends State<ImageToTextConverter> {
  File? _selectedImage;
  String _extractedText = "";
  bool _isProcessing = false;

  final ImagePicker _imagePicker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _extractedText = "";
      });
      _processImage();
    }
  }

  // Function to capture an image using the camera
  Future<void> _captureImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _extractedText = "";
      });
      _processImage();
    }
  }

  // Function to process the selected or captured image
  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final inputImage = InputImage.fromFile(_selectedImage!);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();

      final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text;
      });

      await textRecognizer.close();
    } catch (e) {
      setState(() {
        _extractedText = "Error: $e";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Function to copy text to clipboard
  void _copyToClipboard() {
    if (_extractedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _extractedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Copied to clipboard!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFe84132),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          children: [
            Icon(Icons.document_scanner),
            SizedBox(width: 8,),
            Text(
              'TextLens ||||||||||||||||||||||||||||||',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          if (_selectedImage != null)
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _extractedText = "";
                });
              },
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display selected image or a placeholder
            _selectedImage == null
                ? Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 200,
              color: Colors.black12,
              child: const Text(
                'Pick an image.. or Capture',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : Expanded(
              child: ListView(
                children: [
                  Image.file(
                    _selectedImage!,
                    height: 600,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Buttons for selecting or capturing an image
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  onPressed: _pickImage,
                  icon: const Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Pick Image',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  onPressed: _captureImage,
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Capture Image',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Show a loading indicator while processing
            _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_extractedText.isNotEmpty)
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 34,
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.grey),
                            ),
                            onPressed: _copyToClipboard,
                            icon: const Icon(Icons.copy, color: Colors.white),
                            label: const Text(
                              "Copy Text",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    _extractedText.isEmpty
                        ? Container(
                      padding: const EdgeInsets.all(5),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black12,
                          child: const Text(
                            "Extracted text will appear here.",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                        : SelectableText(
                      _extractedText,
                      style: const TextStyle(fontSize: 16),
                      toolbarOptions: const ToolbarOptions(
                        copy: true,
                        selectAll: true,
                      ),
                      showCursor: true,
                      cursorColor: Colors.redAccent,
                      cursorWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
