import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:sehatsathi/features/chatbot_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import 'package:sehatsathi/util/colors.dart';

class PrescriptionScanner extends StatefulWidget {
  const PrescriptionScanner({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PrescriptionScannerState createState() => _PrescriptionScannerState();
}

class _PrescriptionScannerState extends State<PrescriptionScanner> {
  File? _image;
  String _extractedText = "";
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _processImage();
    }
  }

  Future<void> _processImage() async {
    if (_image == null) return;

    final inputImage = InputImage.fromFile(_image!);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    setState(() {
      _extractedText = recognizedText.text;
    });

    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Medical Report Scanner",
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: maingreen,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _image != null
                  ? Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Image.network(
                            height: 50,
                            'https://cdn-icons-png.flaticon.com/128/3945/3945467.png'),
                      ),
                    ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGradientButton("Camera", Icons.camera_alt,
                      () => _pickImage(ImageSource.camera)),
                  const SizedBox(width: 10),
                  _buildGradientButton("Gallery", Icons.image,
                      () => _pickImage(ImageSource.gallery)),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                "Scan your medical report",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 100),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: maingreen, width: 1),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                    )
                  ],
                ),
                child: Text(
                  _extractedText.isEmpty ? "No report scanned" : _extractedText,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 20),

              // ➡️ Button to Send Text to Chatbot
              if (_extractedText.isNotEmpty)
                _buildGradientButton("Send", Icons.send, () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (_, __, ___) =>
                          ChatBotPage(initialText: _extractedText),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: maingreen,
          // gradient: const LinearGradient(
          //   colors: [Colors.blueAccent, Colors.red],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: maingreen.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
