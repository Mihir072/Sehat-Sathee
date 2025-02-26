import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class DiabetesPredictionPage extends StatefulWidget {
  const DiabetesPredictionPage({super.key});

  @override
  State<DiabetesPredictionPage> createState() => _DiabetesPredictionPageState();
}

class _DiabetesPredictionPageState extends State<DiabetesPredictionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController pregnanciesController = TextEditingController();
  final TextEditingController glucoseController = TextEditingController();
  final TextEditingController bloodPressureController = TextEditingController();
  final TextEditingController skinThicknessController = TextEditingController();
  final TextEditingController insulinController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController dpfController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String? predictionResult;
  bool isLoading = false;

  Future<void> predictDiabetes() async {
    setState(() => isLoading = true);
    final String apiUrl = "https://diabetics-94b6.onrender.com/predict";

    Map<String, dynamic> requestBody = {
      "pregnancies": int.tryParse(pregnanciesController.text) ?? 0,
      "glucose": int.tryParse(glucoseController.text) ?? 0,
      "blood_pressure": int.tryParse(bloodPressureController.text) ?? 0,
      "skin_thickness": int.tryParse(skinThicknessController.text) ?? 0,
      "insulin": int.tryParse(insulinController.text) ?? 0,
      "bmi": double.tryParse(bmiController.text) ?? 0.0,
      "diabetes_pedigree_function": double.tryParse(dpfController.text) ?? 0.0,
      "age": int.tryParse(ageController.text) ?? 0,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          predictionResult = responseData["prediction"];
        });
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        setState(() {
          predictionResult = "Error: ${errorData["error"]}";
        });
      }
    } catch (e) {
      setState(() {
        predictionResult = "Request failed: $e";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    pregnanciesController.dispose();
    glucoseController.dispose();
    bloodPressureController.dispose();
    skinThicknessController.dispose();
    insulinController.dispose();
    bmiController.dispose();
    dpfController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFcad2c5),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Diabetes Prediction",
          style: GoogleFonts.josefinSans(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff354f52),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter Your Health Data:",
                  style: GoogleFonts.josefinSans(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                buildInputField("Pregnancies", pregnanciesController),
                buildInputField("Glucose Level", glucoseController),
                buildInputField("Blood Pressure", bloodPressureController),
                buildInputField("Skin Thickness", skinThicknessController),
                buildInputField("Insulin Level", insulinController),
                buildInputField("BMI", bmiController),
                buildInputField("Diabetes Pedigree Function", dpfController),
                buildInputField("Age", ageController),
                const SizedBox(height: 20),
                Center(
                  child: isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: predictDiabetes,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Predict",
                            style: GoogleFonts.josefinSans(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                if (predictionResult != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        predictionResult!,
                        style: GoogleFonts.josefinSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: GoogleFonts.josefinSans(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              GoogleFonts.josefinSans(fontSize: 16, color: Colors.black87),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff354f52)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff354f52), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
