class ApiService {

  // static const String apiUrl = 'http://apisigesproc.somee.com/api';
  // static const String apiUrl = 'http://nuevobackendsiges.somee.com/api';

  static const String apiUrl = 'http://apisigesproc.somee.com/api';

  static const String googleApiKey = 'AIzaSyAOiZCVZgs7nw1PHRUFhEMm995sK4nlsD4';
    // static const String apiUrl = 'http://apisigesprocMindy.somee.com/api';

  static const String apiKey = '4b567cb1c6b24b51ab55248f8e66e5cc';

  static Map<String, String> getHttpHeaders() {
    return {
      'XApiKey': apiKey,
    };
  }
  
}
