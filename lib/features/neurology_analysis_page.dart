import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sehatsathi/util/colors.dart';

class NeurologyAnalysisPage extends StatefulWidget {
  const NeurologyAnalysisPage({super.key});

  @override
  _NeurologyAnalysisPageState createState() => _NeurologyAnalysisPageState();
}

class _NeurologyAnalysisPageState extends State<NeurologyAnalysisPage> {
  final TextEditingController meanAmplitudeController = TextEditingController();
  final TextEditingController peakToPeakController = TextEditingController();
  final TextEditingController psdController = TextEditingController();
  final TextEditingController entropyController = TextEditingController();
  final TextEditingController deltaPowerController = TextEditingController();
  final TextEditingController thetaPowerController = TextEditingController();
  final TextEditingController alphaPowerController = TextEditingController();
  final TextEditingController betaPowerController = TextEditingController();
  final TextEditingController gammaPowerController = TextEditingController();

  String? predictionResult;
  bool isLoading = false;

  Future<void> makePrediction() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://egg-7aj1.onrender.com/predict');
    final Map<String, dynamic> requestBody = {
      "Mean_Amplitude": double.tryParse(meanAmplitudeController.text) ?? 0.0,
      "Peak_to_Peak": double.tryParse(peakToPeakController.text) ?? 0.0,
      "PSD": double.tryParse(psdController.text) ?? 0.0,
      "Entropy": double.tryParse(entropyController.text) ?? 0.0,
      "Delta_Power": double.tryParse(deltaPowerController.text) ?? 0.0,
      "Theta_Power": double.tryParse(thetaPowerController.text) ?? 0.0,
      "Alpha_Power": double.tryParse(alphaPowerController.text) ?? 0.0,
      "Beta_Power": double.tryParse(betaPowerController.text) ?? 0.0,
      "Gamma_Power": double.tryParse(gammaPowerController.text) ?? 0.0,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          predictionResult = responseData['prediction'];
        });
      } else {
        setState(() {
          predictionResult = "Error: Unable to get prediction";
        });
      }
    } catch (e) {
      setState(() {
        predictionResult = "Error: Network issue or invalid input";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Neurological Predictor",
          style: GoogleFonts.josefinSans(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: maingreen,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Enter Signal Data",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              buildTextField("Mean Amplitude", meanAmplitudeController),
              buildTextField("Peak to Peak", peakToPeakController),
              buildTextField("PSD", psdController),
              buildTextField("Entropy", entropyController),
              buildTextField("Delta Power", deltaPowerController),
              buildTextField("Theta Power", thetaPowerController),
              buildTextField("Alpha Power", alphaPowerController),
              buildTextField("Beta Power", betaPowerController),
              buildTextField("Gamma Power", gammaPowerController),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: makePrediction,
                      child: Text(
                        "Predict Condition",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
              SizedBox(height: 20),
              predictionResult != null
                  ? Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Prediction: $predictionResult",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
