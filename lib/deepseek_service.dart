
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepSeekService {
  // IMPORTANT: Replace this with your actual DeepSeek API key.
  // For production apps, it's crucial to store this key securely and not hardcode it here.
  // Consider using environment variables or a secure vault.
  final String _apiKey = 'YOUR_DEEPSEEK_API_KEY';
  final String _apiUrl = 'https://api.deepseek.com/chat/completions';

  Future<String> getChatResponse(String message, {String model = 'deepseek-chat'}) async {
    if (_apiKey == 'YOUR_DEEPSEEK_API_KEY') {
      return "Please update the _apiKey in lib/deepseek_service.dart with your actual DeepSeek API key.";
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': model, // 'deepseek-chat' or 'deepseek-coder'
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant.'},
            {'role': 'user', 'content': message},
          ],
          // You can add other parameters here, like 'temperature', 'max_tokens', etc.
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Extract the content from the first choice in the response.
        return data['choices'][0]['message']['content'].trim();
      } else {
        // Handle API errors
        print('API Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return 'Error: Failed to get response from API. Status code: ${response.statusCode}';
      }
    } catch (e) {
      // Handle network or other exceptions
      print('Exception: $e');
      return 'Error: An exception occurred while trying to communicate with the API.';
    }
  }
}
