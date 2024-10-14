import 'package:google_generative_ai/google_generative_ai.dart';

class geminiApiValidate {
  final String apiKey;

  geminiApiValidate(this.apiKey);

  Future<Map<String, dynamic>> apiValidate() async {
    final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );

    // Prepare the prompt
    final content = [
      Content.multi([
        TextPart('Hello!'),
      ])
    ];

    try {
      final response = await model.generateContent(content);
      // Return success status and generated code
      return {
        'success': true,
        'generatedCode': response.text,
      };
    } catch (error) {
      print('Error generating code: $error');
      // Return failure status and error message
      return {
        'success': false,
        'error': 'Error generating code: $error',
      };
    }
  }

}