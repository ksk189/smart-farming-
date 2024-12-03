import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiApi {
  static Future<String> analyzeImage({required File imageFile, required String prompt}) async {
    final uri = Uri.parse('AIzaSyC2jVovsvh1X_IjuI68B38QhzA6rN13oNY'); // Replace with actual API URL
    final request = http.MultipartRequest('POST', uri)
      ..fields['prompt'] = prompt
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      return responseData.body; // Assuming the API returns a plain text response
    } else {
      throw Exception("Failed to analyze image");
    }
  }
}