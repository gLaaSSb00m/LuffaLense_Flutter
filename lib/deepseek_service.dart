
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepSeekService {
  // IMPORTANT: Replace this with your actual DeepSeek API key.
  // For production apps, it's crucial to store this key securely and not hardcode it here.
  // Consider using environment variables or a secure vault.
  final String _apiKey = 'sk-7172c04d20b24bad9dfd9f69f5d2d0e1';
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
            {'role': 'system', 'content': 'You are a specialized assistant for Luffa plant information. You can only provide information about Luffa plants, their cultivation, diseases, health, and related topics. If the user asks about anything else, politely decline and redirect the conversation back to Luffa plants.'},
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

        // Handle specific error cases
        if (response.statusCode == 402) {
          return 'Sorry, the API balance is insufficient. Please check your DeepSeek account credits or contact support.';
        } else if (response.statusCode == 401) {
          return 'Authentication failed. Please check your API key configuration.';
        } else if (response.statusCode == 429) {
          return 'Too many requests. Please wait a moment before trying again.';
        } else {
          return 'Sorry, I\'m having trouble connecting to the service right now. Please try again later.';
        }
      }
    } catch (e) {
      // Handle network or other exceptions
      print('Exception: $e');
      return 'Error: An exception occurred while trying to communicate with the API.';
    }
  }
}
