class Gogleeservice {

  static const String googleApiKey = 'AIzaSyAOiZCVZgs7nw1PHRUFhEMm995sK4nlsD4';

  static Map<String, String> getHttpHeaders() {
    return {
      'XApiKey': googleApiKey,
    };
  }

  static Map<String, String> getGoogleApiHeaders() {
    return {
      'Authorization': 'Bearer $googleApiKey',
    };
  }
}
