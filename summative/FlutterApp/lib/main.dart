import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AgasekeApp());
}

class AgasekeApp extends StatelessWidget {
  const AgasekeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agaseke Savings Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F5F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B6E4F),
          primary: const Color(0xFF0B6E4F),
          secondary: const Color(0xFFC79A3D),
        ),
        fontFamily: 'Roboto',
      ),
      home: const PredictionScreen(),
    );
  }
}

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _ageController = TextEditingController();
  final _incomeController = TextEditingController();
  final _expensesController = TextEditingController();
  final _debtRatioController = TextEditingController();

  String? _gender;
  String? _education;
  String? _employment;
  String? _hasLoan;
  String? _region;

  bool _loading = false;
  String? _result;
  bool _isError = false;

  final List<String> _genderOptions = ['Female', 'Male', 'Other'];
  final List<String> _educationOptions = [
    'High School',
    'Bachelor',
    'Master',
    'PhD',
    'Other',
  ];
  final List<String> _employmentOptions = [
    'Employed',
    'Self-employed',
    'Student',
    'Unemployed',
  ];
  final List<String> _loanOptions = ['Yes', 'No'];
  final List<String> _regionOptions = [
    'Africa',
    'Asia',
    'Europe',
    'North America',
    'Other',
  ];

  Future<void> _predict() async {
    if (_ageController.text.isEmpty ||
        _incomeController.text.isEmpty ||
        _expensesController.text.isEmpty ||
        _debtRatioController.text.isEmpty ||
        _gender == null ||
        _education == null ||
        _employment == null ||
        _hasLoan == null ||
        _region == null) {
      setState(() {
        _isError = true;
        _result = 'Please fill in every field before predicting.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final url = Uri.parse(
        'https://linear-regression-model-ambx.onrender.com/predict',
      );

      final body = jsonEncode({
        "age": int.parse(_ageController.text),
        "gender": _gender,
        "education_level": _education,
        "employment_status": _employment,
        "monthly_income_usd": double.parse(_incomeController.text),
        "monthly_expenses_usd": double.parse(_expensesController.text),
        "has_loan": _hasLoan,
        "debt_to_income_ratio": double.parse(_debtRatioController.text),
        "region": _region,
      });

      final response = await http
          .post(url, headers: {"Content-Type": "application/json"}, body: body)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final value = (data['predicted_savings_usd'] as num).toStringAsFixed(2);
        setState(() {
          _isError = false;
          _result = value;
        });
      } else {
        setState(() {
          _isError = true;
          _result = 'The values entered are out of range or invalid.';
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _result = 'Could not reach the prediction service. Please try again.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0B6E4F), width: 2),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: _fieldDecoration(label),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<String> options,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: _fieldDecoration(label),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B6E4F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.savings_rounded,
                      color: Color(0xFFC79A3D),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Agaseke Savings Predictor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Estimate expected monthly savings from a few quick details.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _numberField('Age', _ageController),
                    _dropdown(
                      'Gender',
                      _genderOptions,
                      _gender,
                      (v) => setState(() => _gender = v),
                    ),
                    _dropdown(
                      'Education Level',
                      _educationOptions,
                      _education,
                      (v) => setState(() => _education = v),
                    ),
                    _dropdown(
                      'Employment Status',
                      _employmentOptions,
                      _employment,
                      (v) => setState(() => _employment = v),
                    ),
                    _numberField('Monthly Income (USD)', _incomeController),
                    _numberField('Monthly Expenses (USD)', _expensesController),
                    _dropdown(
                      'Has Loan',
                      _loanOptions,
                      _hasLoan,
                      (v) => setState(() => _hasLoan = v),
                    ),
                    _numberField('Debt to Income Ratio', _debtRatioController),
                    _dropdown(
                      'Region',
                      _regionOptions,
                      _region,
                      (v) => setState(() => _region = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _predict,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B6E4F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Predict',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              if (_result != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _isError
                        ? const Color(0xFFFDEDED)
                        : const Color(0xFFEAF6F0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isError
                          ? const Color(0xFFE07A7A)
                          : const Color(0xFF0B6E4F),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isError
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        color: _isError
                            ? const Color(0xFFB33A3A)
                            : const Color(0xFF0B6E4F),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isError
                            ? Text(
                                _result!,
                                style: const TextStyle(
                                  color: Color(0xFFB33A3A),
                                  fontSize: 14,
                                ),
                              )
                            : RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Color(0xFF1F2933),
                                    fontSize: 14,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Predicted Savings\n'),
                                    TextSpan(
                                      text: '\$$_result',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0B6E4F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
