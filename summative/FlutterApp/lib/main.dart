import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(home: PredictionPage()));
}

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final String apiUrl = 'https://restaurant-visitors-api.onrender.com/predict';

  final Map<String, String> fieldLabels = {
    'air_genre_name': 'Restaurant genre (e.g. Izakaya)',
    'latitude': 'Latitude (24 to 46)',
    'longitude': 'Longitude (122 to 146)',
    'day_of_week': 'Day of week (e.g. Monday)',
    'holiday_flg': 'Holiday (0 = no, 1 = yes)',
    'reserve_visitors': 'Reserved visitors (0 to 2000)',
    'prefecture': 'Prefecture (e.g. Tokyo-to)',
    'month': 'Month (1 to 12)',
    'visitors_last_week': 'Visitors same day last week (0 to 1000)',
  };

  final List<String> textFields = [
    'air_genre_name',
    'day_of_week',
    'prefecture',
  ];

  final Map<String, TextEditingController> controllers = {};

  String result = 'Enter the values and press Predict';

  @override
  void initState() {
    super.initState();
    for (final field in fieldLabels.keys) {
      controllers[field] = TextEditingController();
    }
  }

  Future<void> predict() async {
    final Map<String, dynamic> body = {};
    for (final field in fieldLabels.keys) {
      final value = controllers[field]!.text.trim();
      if (value.isEmpty) continue;
      if (textFields.contains(field)) {
        body[field] = value;
      } else {
        body[field] = num.tryParse(value) ?? value;
      }
    }

    setState(() {
      result = 'Predicting...';
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);

      setState(() {
        if (response.statusCode == 200) {
          result = 'Predicted visitors: ${data['predicted_visitors']}';
        } else {
          final errors = data['detail'] as List;
          result = errors
              .map((error) => 'Error in ${error['loc'].last}: ${error['msg']}')
              .join('\n');
        }
      });
    } catch (e) {
      setState(() {
        result = 'Could not reach the API. Check your internet and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Visitor Prediction')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final field in fieldLabels.keys)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: controllers[field],
                decoration: InputDecoration(
                  labelText: fieldLabels[field],
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ElevatedButton(onPressed: predict, child: const Text('Predict')),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Text(result, style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
