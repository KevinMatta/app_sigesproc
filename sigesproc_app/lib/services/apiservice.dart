class ApiService {
  static const String apiUrl = 'http://www.backsigespro.somee.com/api';
  static const String apiKey = '4b567cb1c6b24b51ab55248f8e66e5cc';

  static Map<String, String> getHttpHeaders() {
    return {
      'XApiKey': apiKey,
    };
  }
}
