import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HeartDiseasePage extends StatefulWidget {
  @override
  _HeartDiseasePageState createState() => _HeartDiseasePageState();
}

class _HeartDiseasePageState extends State<HeartDiseasePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _physicalHealthController =
      TextEditingController();
  final TextEditingController _mentalHealthController = TextEditingController();
  final TextEditingController _sleepTimeController = TextEditingController();
  String? _predictionResult;
  bool _isLoading = false;

  // Dropdown options
  final List<String> _categories = [
    "Underweight",
    "Normal",
    "Overweight",
    "Obese"
  ];
  final List<String> _yesNoOptions = ["Yes", "No"];
  final List<String> _genders = ["Male", "Female"];
  final List<String> _ageCategories = [
    "18-24",
    "25-29",
    "30-34",
    "35-39",
    "40-44",
    "45-49",
    "50-54",
    "55-59",
    "60-64",
    "65-69",
    "70-74",
    "75-79",
    "80+"
  ];
  final List<String> _raceCategories = [
    "White",
    "Black",
    "Asian",
    "Hispanic",
    "Other"
  ];
  final List<String> _genHealthOptions = [
    "Excellent",
    "Very good",
    "Good",
    "Fair",
    "Poor"
  ];

  String? _bmiCategory,
      _smoking,
      _alcohol,
      _stroke,
      _diffWalking,
      _sex,
      _ageCategory,
      _race,
      _diabetic,
      _physicalActivity,
      _genHealth,
      _asthma,
      _kidneyDisease,
      _skinCancer;

  Future<void> _makePrediction() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final url = Uri.parse('https://heart-disease-ax0i.onrender.com/predict');
    final Map<String, dynamic> requestBody = {
      "BMICategory": _bmiCategory,
      "Smoking": _smoking,
      "AlcoholDrinking": _alcohol,
      "Stroke": _stroke,
      "PhysicalHealth": int.tryParse(_physicalHealthController.text) ?? 0,
      "MentalHealth": int.tryParse(_mentalHealthController.text) ?? 0,
      "DiffWalking": _diffWalking,
      "Sex": _sex,
      "AgeCategory": _ageCategory,
      "Race": _race,
      "Diabetic": _diabetic,
      "PhysicalActivity": _physicalActivity,
      "GenHealth": _genHealth,
      "SleepTime": int.tryParse(_sleepTimeController.text) ?? 0,
      "Asthma": _asthma,
      "KidneyDisease": _kidneyDisease,
      "SkinCancer": _skinCancer,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);
      setState(() {
        _predictionResult = responseData['Heart Disease Prediction'] ??
            "Error: Invalid response";
      });
    } catch (e) {
      setState(() {
        _predictionResult = "Error: Network issue or invalid input";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildDropdown(
      String label, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Required' : null,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Heart Disease Predictor")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildDropdown(
                  "BMI Category", _categories, (val) => _bmiCategory = val),
              _buildDropdown("Smoking", _yesNoOptions, (val) => _smoking = val),
              _buildDropdown(
                  "Alcohol Drinking", _yesNoOptions, (val) => _alcohol = val),
              _buildDropdown("Stroke", _yesNoOptions, (val) => _stroke = val),
              _buildTextField(
                  "Physical Health (days)", _physicalHealthController),
              _buildTextField("Mental Health (days)", _mentalHealthController),
              _buildDropdown("Difficulty Walking", _yesNoOptions,
                  (val) => _diffWalking = val),
              _buildDropdown("Gender", _genders, (val) => _sex = val),
              _buildDropdown(
                  "Age Category", _ageCategories, (val) => _ageCategory = val),
              _buildDropdown("Race", _raceCategories, (val) => _race = val),
              _buildDropdown(
                  "Diabetic", _yesNoOptions, (val) => _diabetic = val),
              _buildDropdown("Physical Activity", _yesNoOptions,
                  (val) => _physicalActivity = val),
              _buildDropdown("General Health", _genHealthOptions,
                  (val) => _genHealth = val),
              _buildTextField("Sleep Time (hours)", _sleepTimeController),
              _buildDropdown("Asthma", _yesNoOptions, (val) => _asthma = val),
              _buildDropdown("Kidney Disease", _yesNoOptions,
                  (val) => _kidneyDisease = val),
              _buildDropdown(
                  "Skin Cancer", _yesNoOptions, (val) => _skinCancer = val),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _makePrediction,
                      child: Text("Predict"),
                    ),
              SizedBox(height: 20),
              if (_predictionResult != null)
                Text("Prediction: $_predictionResult",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
