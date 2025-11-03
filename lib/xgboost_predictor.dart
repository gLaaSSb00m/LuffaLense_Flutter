import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class XGBoostPredictor {
  static const String apiUrl =
      'https://Abid1012-luffa-disease-api.hf.space/predict';

  Future<String> predict(List<double> features, String category) async {
    if (features.length != 10) {
      throw Exception(
        'Exactly 10 feature values are required. Got ${features.length}',
      );
    }

    if (category != 'Smooth' && category != 'Spoonge') {
      throw Exception('Invalid category. Use "Smooth" or "Spoonge".');
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'features': features, 'category': category}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return data['prediction'];
      } else {
        throw Exception('API returned error: ${data['status']}');
      }
    } else {
      throw Exception(
        'Failed to get prediction from API: ${response.statusCode}',
      );
    }
  }

  Future<String> predictFromImage(File imageFile, String category) async {
    try {
      final url = Uri.parse(
        'https://Abid1012-luffa-disease-api.hf.space/predict/image?category=$category',
      );

      var request = http.MultipartRequest('POST', url);
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['prediction'] ?? 'Unknown';
      } else {
        throw Exception(
          'Failed to get prediction: ${response.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      throw Exception('Image prediction failed: $e');
    }
  }
}
